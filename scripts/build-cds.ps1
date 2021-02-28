param(
    [string] $iconPath,
    [int] $targetHeight = 70
)

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

    $targetHeight = $using:targetHeight
    Write-Host $serviceId

    if(!(Test-Path $pngTbgPath)) {
        svgexport "$($fullPath)" "$($pngTbgPath)" pad "$($targetHeight):$($targetHeight)"
    }

    if(!(Test-Path $pumlOutput)) {
        if(!(Test-Path $pngWbgPath)) {
            svgexport "$($fullPath)" "$($pngWbgPath)" pad "$($targetHeight):$($targetHeight)" "svg{background:white;}"
        }
        $coloredMacro = $serviceId
        $monochromaticMacro = $serviceId + "_m"
        $spriteId = "$($serviceId)SPRITE"
        $sprite = ((java -jar "lib/plantuml.jar" -encodesprite 16z "$($pngWbgPath)") | Out-String) -replace "`r", ""
        $sprite = $sprite -replace "$($serviceId)_wbg", "$($spriteId)"
        
        $stereo = $serviceId -replace "CDS", ""
        $sourcePath = "IMAGE_SOURCE/azure-cds/$($category)/$($pngTbg)"
        $puml = $sprite
        $puml += "AzureEntityColoring($($coloredMacro))`n"
        $puml += "!define $($coloredMacro)(e_alias, e_label, e_techn) AzureImage(e_alias, e_label, e_techn, $($sourcePath), $($stereo))`n"
        $puml += "!define $($coloredMacro)(e_alias, e_label, e_techn, e_descr) AzureImage(e_alias, e_label, e_techn, e_descr, $($sourcePath), $($stereo))`n"
        
        $puml += "AzureEntityColoring($($monochromaticMacro))`n"
        $puml += "!define $($monochromaticMacro)(e_alias, e_label, e_techn) AzureEntity(e_alias, e_label, e_techn, AZURE_SYMBOL_COLOR, $($spriteId), $($stereo))`n"
        $puml += "!define $($monochromaticMacro)(e_alias, e_label, e_techn, e_descr) AzureEntity(e_alias, e_label, e_techn, e_descr, AZURE_SYMBOL_COLOR, $($spriteId), $($stereo))`n`n"

        $puml | Out-File $pumlOutput -NoNewLine   
    }
} -ThrottleLimit 8


$allPuml = ""
$list = ""
$list += "## Include all sprites`n`n"
$list += "Your PUML might take long to render`n"
$list += '```' + "`n"
$list += "!define AzurePuml https://raw.githubusercontent.com/czmirek/PlantUML-AzureIcons/main/dist`n"
$list += "!include AzurePuml/AzureCommon.puml`n"
$list += "!include AzurePuml/azure-cds/$($category)/all.puml`n"
$list += '```' + "`n"
$list += "# Categories`n`n"

$listTblHeader = "Image | Macro`n"
$listTblHeader += "| --- | ---`n"

Get-ChildItem ("dist/azure-cds") -directory | ForEach-Object { 
    $category = $_.Name
    $categoryPuml = ""


    $list += "## $($category)`n`n"
    $list += "Macro for including this category`n"
    $list += '```' + "`n"
    $list += "!define AzurePuml https://raw.githubusercontent.com/czmirek/PlantUML-AzureIcons/main/dist`n"
    $list += "!include AzurePuml/AzureCommon.puml`n"
    $list += "!include AzurePuml/azure-cds/$($category)/all.puml`n"
    $list += '```' + "`n"
    $list += $listTblHeader

    Get-ChildItem ("dist/azure-cds/$($category)/*.puml") | ForEach-Object { 
        $fileName = $_.Name
        if($fileName -eq "all.puml" -or $fileName -eq "AzureCommon.puml") {
            return
        }
        $serviceId = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
        $list += "![$($serviceId)]($($category)/$($serviceId)_tbg.png) | ``$($serviceId)``<br>``$($serviceId)_m`` |`n"
        
        $content = Get-Content $_.FullName -Raw

        $categoryPuml += $content
        $allPuml += $content
    }

    $categoryPuml | Out-File "dist/azure-cds/$($category)/all.puml"

    $list += "`n`n"
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
' + $list | Out-File "dist/azure-cds/README.md" -NoNewLine