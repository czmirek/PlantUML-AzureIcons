param(
    [int] $targetHeight = 70
)
$sourceCollection = "https://github.com/benc-uk/icon-collection"
$iconFolder = "icon-collection"
$iconPath = "$($iconFolder)/azure-cds/*.svg"

if(!(Test-Path $iconFolder)) {
    git clone $sourceCollection $iconFolder
}

Get-ChildItem $iconPath | ForEach-Object -Parallel {
    $dist = "dist"
    $fileName = $_
    $fullPath = $_.FullName
    $noext = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
    $split = $noext -split "-"
    
    $ti = (Get-Culture).TextInfo
    $category = $ti.ToTitleCase($split[0])
    $serviceId = @($category, ($split[2..$split.length] -join "")) -join ""
    $serviceId = ($serviceId -replace "\(", "_") -replace "\)", ""    
    $serviceId = "CDS" + $serviceId

    $outputFolder = "$($dist)/azure-cds/$($category)"
    
    if(!(Test-Path $outputFolder)) {
        New-Item $outputFolder -ItemType "directory"
    }

    $pngWbg = "$($serviceId)_wbg.png"
    $pngTbg = "$($serviceId)_tbg.png"
    $pngWbgPath = "$($outputFolder)/$($pngWbg)"
    $pngTbgPath = "$($outputFolder)/$($pngTbg)"
    $pumlOutput = "$($outputFolder)/$($serviceId).puml"

    Write-Host $serviceId
    
    if(!((Test-Path $pngWbgPath) -and (Test-Path $pngTbgPath))) {
        $targetHeight = $using:targetHeight
        svgexport "$($fullPath)" "$($pngWbgPath)" "$($targetHeight):$($targetHeight)" "svg{background:white;}"
        svgexport "$($fullPath)" "$($pngTbgPath)" "$($targetHeight):$($targetHeight)"
    }

    $coloredMacro = $serviceId
    $monochromaticMacro = $serviceId + "_m"
    $spriteId = "$($serviceId)SPRITE"
    $sprite = ((java -jar "lib/plantuml.jar" -encodesprite 16z "$($pngWbgPath)") | Out-String) -replace "`r", ""
    $sprite = $sprite -replace "$($serviceId)_wbg", "$($spriteId)"
    
    $sourcePath = "IMAGE_SOURCE/azure-cds/$($category)/$($pngTbg)"
    $puml = $sprite
    $puml += "AzureEntityColoring($($coloredMacro))`n"
    $puml += "!define $($coloredMacro)(e_alias, e_label, e_techn) AzureImage(e_alias, e_label, e_techn, $($sourcePath), $($coloredMacro))`n"
    $puml += "!define $($coloredMacro)(e_alias, e_label, e_techn, e_descr) AzureImage(e_alias, e_label, e_techn, e_descr, $($sourcePath), $($coloredMacro))`n"
    
    $puml += "AzureEntityColoring($($monochromaticMacro))`n"
    $puml += "!define $($monochromaticMacro)(e_alias, e_label, e_techn) AzureEntity(e_alias, e_label, e_techn, AZURE_SYMBOL_COLOR, $($spriteId), $($monochromaticMacro))`n"
    $puml += "!define $($monochromaticMacro)(e_alias, e_label, e_techn, e_descr) AzureEntity(e_alias, e_label, e_techn, e_descr, AZURE_SYMBOL_COLOR, $($spriteId), $($monochromaticMacro))`n`n"

    $puml | Out-File $pumlOutput -NoNewLine   
} -ThrottleLimit 8


$allPuml = ""
$markdownList = "Category | Macro | Image`n"
$markdownList += "| --- | --- | ---`n"

Get-ChildItem ("dist/azure-cds") -directory | ForEach-Object { 
    $category = $_.Name
    $categoryPuml = ""

    Get-ChildItem ("dist/azure-cds/$($category)/*.puml") | ForEach-Object { 
        $fileName = $_.Name
        if($fileName -eq "all.puml" -or $fileName -eq "AzureCommon.puml") {
            return
        }
        $serviceId = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
        $markdownList += "$($category) | ``$($serviceId)``<br>``$($serviceId)_m`` | ![$($serviceId)]($($category)/$($serviceId)_tbg.png) |`n"
        
        $content = Get-Content $_.FullName -Raw

        $categoryPuml += $content
        $allPuml += $content
    }

    $categoryPuml | Out-File "dist/azure-cds/$($category)/all.puml"
}

$allPuml | Out-File "dist/azure-cds/all.puml" -NoNewLine

'# Azure CDS macro table
List of PUML macros for the Azure CDS image repository.
See [README.md](README.md) for more info.

## Colored image 
```
CDSAzureComputeFunctionApps(functionAlias, "Label", "Technology", "Optional description")
```
## Monochromatic sprite
```
CDSAzureComputeFunctionApps_m(functionAlias, "Label", "Technology", "Optional description")
```

You may need to CTRL+F here, the list is not sorted.

## List of macros
' + $markdownList | Out-File "dist/azure-cds/table.md" -NoNewLine




Copy-Item "AzureCommon.puml" "dist/AzureCommon.puml"