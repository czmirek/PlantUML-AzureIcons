param(
    [int] $targetHeight = 70,
    [string] $plantUmlPath = "C:\Users\lesar\Desktop\bin\plantuml.jar"
)
$sourceCollection = "https://github.com/benc-uk/icon-collection"
$iconFolder = "icon-collection"
$iconPath = "$($iconFolder)/azure-cds/*.svg"
$dist = "dist"

if(!(Test-Path $iconFolder)) {
    git clone $sourceCollection $iconFolder
}

Get-ChildItem $iconPath | ForEach-Object {
    
    $fileName = $_
    $fullPath = $_.FullName
    $noext = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
    $split = $noext -split "-"
    
    $ti = (Get-Culture).TextInfo
    $category = $ti.ToTitleCase($split[0])
    $serviceId = @($category, ($split[2..$split.length] -join "")) -join ""
    $serviceId = ($serviceId -replace "\(", "_") -replace "\)", ""    
    if(!$serviceId.StartsWith("Azure")) {
        $serviceId = "Azure" + $serviceId
    }

    $pngWbg = "$($serviceId)_wbg.png"
    $pngTbg = "$($serviceId)_tbg.png"
    $pngWbgPath = $dist + "/" + $pngWbg
    $pngTbgPath = $dist + "/" + $pngTbg
    $pumlOutput = $dist + "/$($serviceId).puml"

    if((Test-Path $pngWbgPath) -and (Test-Path $pngTbgPath) -and (Test-Path $pumlOutput)) {
        return
    }

    Write-Host ""
    Write-Host "--------------------------------------------"
    Write-Host $serviceId
    Write-Host "--------------------------------------------"
    
    inkscape --export-background="white" --export-type="png" -w $targetHeight -h $targetHeight "$($fullPath)" -o $pngWbgPath
    inkscape --export-type="png" -w $targetHeight -h $targetHeight "$($fullPath)" -o $pngTbgPath
    
    $colored = $serviceId
    $monochromatic = $serviceId + "_m"
    
    $spriteId = "$($serviceId)SPRITE"

    $sprite = ((java -jar "$($plantUmlPath)" -encodesprite "16z" "$($pngWbgPath)") | Out-String) -replace "`r", ""
    $sprite = $sprite -replace "$($serviceId)_wbg", "$($spriteId)"
    
    $puml = $sprite
    $puml += "AzureImage($($colored))`n"
    $puml += "!define $($colored)(e_alias, e_label, e_techn) AzureImage(e_alias, e_label, e_techn, IMAGE_SOURCE + ""$($pngTbg)"", $($colored))`n"
    $puml += "!define $($colored)(e_alias, e_label, e_techn, e_descr) AzureImage(e_alias, e_label, e_techn, e_descr, IMAGE_SOURCE + ""$($pngTbg)"", $($colored))`n"
    
    $puml += "AzureEntity($($monochromatic))`n"
    $puml += "!define $($monochromatic)(e_alias, e_label, e_techn) AzureEntity(e_alias, e_label, e_techn, AZURE_SYMBOL_COLOR, $($spriteId), $($monochromatic))`n"
    $puml += "!define $($monochromatic)(e_alias, e_label, e_techn, e_descr) AzureEntity(e_alias, e_label, e_techn, e_descr, AZURE_SYMBOL_COLOR, $($spriteId), $($monochromatic))`n`n"
    $puml | Out-File $pumlOutput -NoNewLine   
}
$allPuml = ""
$markdownList = "Macro (Name) | Image`n"
$markdownList += "--- | ---`n"

Get-ChildItem ($dist + "/*.puml") | ForEach-Object { 
    $fileName = $_.Name
    if($fileName -eq "all.puml" -or $fileName -eq "AzureCommon.puml") {
        return
    }
    $content = Get-Content $_ -Raw
    $allPuml += $content

    $serviceId = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
    $markdownList +="$($serviceId)<br>Monochrome: $($serviceId)_m | ![$($serviceId)](dist/$($serviceId)_tbg.png) |`n"
}
$allPuml | Out-File "dist/all.puml" -NoNewLine
$markdownList | Out-File "table.md" -NoNewLine

Copy-Item "AzureCommon.puml" "$($dist)/AzureCommon.puml"