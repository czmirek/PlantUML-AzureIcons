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
    
    Write-Host "Processing $($serviceId)"

    $pngOutput = $dist + "/$($serviceId).png"
    $pumlOutput = $dist + "/$($serviceId).puml"
    
    inkscape --export-type="png" -w $targetHeight -h $targetHeight "$($fullPath)" -o $pngOutput

    $sprite = ((java -jar "$($plantUmlPath)" -encodesprite "16z" "$($pngOutput)") | Out-String) -replace "`r", ""
    $puml = $sprite
    $puml += "AzureEntityColoring($($serviceId))`n"
    $puml += "!define $($serviceId)(e_alias, e_label, e_techn) AzureEntity(e_alias, e_label, e_techn, AZURE_SYMBOL_COLOR, $($serviceId), $($serviceId))`n"
    $puml += "!define $($serviceId)(e_alias, e_label, e_techn, e_descr) AzureEntity(e_alias, e_label, e_techn, e_descr, AZURE_SYMBOL_COLOR, $($serviceId), $($serviceId))`n"
    $puml | Out-File $pumlOutput -NoNewLine
}

$allPuml = ""
Get-ChildItem ($dist + "/*.puml") | ForEach-Object { 
    if($_.Name -eq "all.puml") {
        return
    }
    $content = Get-Content $_ -Raw
    $allPuml += $content
}
$allPuml | Out-File "dist/all.puml" -NoNewLine

Copy-Item "AzureC4Integration.puml" "$($dist)/AzureC4Integration.puml"
Copy-Item "AzureCommon.puml" "$($dist)/AzureCommon.puml"
Copy-Item "AzureRaw.puml" "$($dist)/AzureRaw.puml"
Copy-Item "AzureSimplified.puml" "$($dist)/AzureSimplified.puml"

$markdownList = "Macro (Name) | Url`n"
$markdownList += "--- | ---`n"
Get-ChildItem ($dist + "/*.puml") | ForEach-Object { 
    $fileName = $_.Name
    if($fileName -eq "all.puml") {
        return
    }
    $serviceId = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
    $markdownList +="$($serviceId) | ![$($serviceId)](dist/$($serviceId).png) |`n"
}
$markdownList | Out-File "table.md" -NoNewLine