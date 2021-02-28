Push-Location "../"

$sourceCollection = "https://github.com/benc-uk/icon-collection"
$iconFolder = "icon-collection"
if(!(Test-Path $iconFolder)) {
    git clone $sourceCollection $iconFolder
}


./scripts/build-cds.ps1 "$($iconFolder)/azure-cds/*.svg" 70
./scripts/build-patterns.ps1 "$($iconFolder)/azure-patterns/*.svg" 70

Copy-Item "AzureCommon.puml" "dist/AzureCommon.puml"

Pop-Location