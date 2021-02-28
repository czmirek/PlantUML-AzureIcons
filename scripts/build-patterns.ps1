param(
    [string] $iconPath,
    [int] $targetHeight = 70
)

$manualCategories = @("alert", "app", "arrow", "azure", "book", "browser", "build", "building", "calculator", "calendar", "charts", "check", "circle", "clock", "cloud", "code", "computer", "data", "deploy",
 "devops", "document", "function", "gear", "geometry", "globe", "grid", "health", "iot", "machine-learning", "media", "messages", "monitor", "node", "object", "office", "phone", "pricing", "resources", 
 "scale", "security", "shield", "speech", "sql", "squares", "storage", "templates", "time", "ui", "user", "vehicle", "video",
 "audio", "avere", "bar", "bing", "blockchain", "bluesquare", "calender", "curlybrackets", "currency", "getstarted", "graph", "machinelearning", "parameter", "product", "science", "server", "speed", "webapp")

Get-ChildItem $iconPath | ForEach-Object -Parallel {
    $dist = "dist"
    $fileName = $_
    $fullPath = $_.FullName
    $noext = [System.IO.Path]::GetFileNameWithoutExtension($fileName)
    
    $serviceId = ""
    $ti = (Get-Culture).TextInfo
    $noext -split "-" | ForEach-Object { $serviceId += $ti.ToTitleCase($_) }
    
    
    $category = "Uncategorized"
    foreach ($manualCategory in $using:manualCategories) {
        if($serviceId.ToLowerInvariant().StartsWith($manualCategory)) {
            $category = $ti.ToTitleCase($manualCategory)
            break
        }
    }
    
    $serviceId = "AP" + $serviceId


    $outputFolder = "$($dist)/azure-patterns/$($category)"
    if(!(Test-Path $outputFolder)) {
        New-Item $outputFolder -ItemType "directory"
    }

    $pngWbg = "$($serviceId)_wbg.png"
    $pngTbg = "$($serviceId)_tbg.png"
    $pngWbgPath = "$($outputFolder)/$($pngWbg)"
    $pngTbgPath = "$($outputFolder)/$($pngTbg)"
    $pumlOutput = "$($outputFolder)/$($serviceId).puml"

    Write-Host $serviceId
    
    if(!(Test-Path $pngTbgPath)) {
        $targetHeight = $using:targetHeight
        svgexport "$($fullPath)" "$($pngTbgPath)" "$($targetHeight):$($targetHeight)"
    }

    if(!(Test-Path $pumlOutput)) {
        if(!(Test-Path $pngWbgPath)) {
            svgexport "$($fullPath)" "$($pngWbgPath)" "$($targetHeight):$($targetHeight)" "svg{background:white;}"
        }
        $coloredMacro = $serviceId
        $monochromaticMacro = $serviceId + "_m"
        $spriteId = "$($serviceId)SPRITE"
        $sprite = ((java -jar "lib/plantuml.jar" -encodesprite 16z "$($pngWbgPath)") | Out-String) -replace "`r", ""
        $sprite = $sprite -replace "$($serviceId)_wbg", "$($spriteId)"
        
        $sourcePath = "IMAGE_SOURCE/azure-patterns/$($pngTbg)"
        $puml = $sprite
        $puml += "AzureEntityColoring($($coloredMacro))`n"
        $puml += "!define $($coloredMacro)(e_alias, e_label, e_techn) AzureImage(e_alias, e_label, e_techn, $($sourcePath), $($coloredMacro))`n"
        $puml += "!define $($coloredMacro)(e_alias, e_label, e_techn, e_descr) AzureImage(e_alias, e_label, e_techn, e_descr, $($sourcePath), $($coloredMacro))`n"
        
        $puml += "AzureEntityColoring($($monochromaticMacro))`n"
        $puml += "!define $($monochromaticMacro)(e_alias, e_label, e_techn) AzureEntity(e_alias, e_label, e_techn, AZURE_SYMBOL_COLOR, $($spriteId), $($monochromaticMacro))`n"
        $puml += "!define $($monochromaticMacro)(e_alias, e_label, e_techn, e_descr) AzureEntity(e_alias, e_label, e_techn, e_descr, AZURE_SYMBOL_COLOR, $($spriteId), $($monochromaticMacro))`n`n"

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
$list += "!include AzurePuml/azure-patterns/all.puml`n"
$list += '```' + "`n"
$list += "# Categories`n`n"

$listTblHeader = "Image | Macro`n"
$listTblHeader += "| --- | ---`n"

Get-ChildItem ("dist/azure-patterns") -directory | ForEach-Object { 
    $category = $_.Name
    $categoryPuml = ""


    $list += "## $($category)`n`n"
    $list += "Macro for including this category`n"
    $list += '```' + "`n"
    $list += "!define AzurePuml https://raw.githubusercontent.com/czmirek/PlantUML-AzureIcons/main/dist`n"
    $list += "!include AzurePuml/AzureCommon.puml`n"
    $list += "!include AzurePuml/azure-patterns/all.puml`n"
    $list += '```' + "`n"
    $list += $listTblHeader

    Get-ChildItem ("dist/azure-patterns/$($category)/*.puml") | ForEach-Object { 
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

    $categoryPuml | Out-File "dist/azure-patterns/$($category)/all.puml"

    $list += "`n`n"
}

$allPuml | Out-File "dist/azure-patterns/all.puml" -NoNewLine

'# Azure Patterns macro table
List of PUML macros for the Azure Patterns image repository.
See [README.md](README.md) for more info.

## Colored image 
```
APSomeMacro(functionAlias, "Label", "Technology", "Optional description")
```
## Monochromatic sprite
```
APSomeMacro_m(functionAlias, "Label", "Technology", "Optional description")
```
' + $list | Out-File "dist/azure-patterns/README.md" -NoNewLine