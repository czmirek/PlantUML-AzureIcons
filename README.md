# Azure Icons for PlantUML
Azure icons provided by [benc-uk/icon-collection](https://github.com/benc-uk/icon-collection) parsed and converted into PUML boxes using the
macros from [RicardoNiepel/Azure-PlantUML](https://github.com/RicardoNiepel/Azure-PlantUML).

- CDS Azure Icons Set
  - [Macro table](https://github.com/czmirek/PlantUML-AzureIcons/tree/main/dist/azure-cds)
  - [Source](https://github.com/benc-uk/icon-collection/tree/master/azure-cds)
  - Macros are prefixed with CDS
- Azure Patterns
  - [Macro table](https://github.com/czmirek/PlantUML-AzureIcons/tree/main/dist/azure-patterns)
  - [Source](https://github.com/benc-uk/icon-collection/tree/master/azure-patterns)
  - Macros are prefixed with AP

## Usage
Put this into your PUML to add support for all images.

```puml
!define AzurePuml https://raw.githubusercontent.com/czmirek/PlantUML-AzureIcons/main/dist
!include AzurePuml/AzureCommon.puml
```

Then look into the macro table of your choice (currently "CDS" and "Azure Patterns" are supported)
and pick either an individual picture, whole category or complete collection.

```puml
!include AzurePuml/azure-cds/all.puml 'Loading whole collection significantly increases your PUML rendering time
!include AzurePuml/azure-cds/Compute/all.puml 'Loading category
!include AzurePuml/azure-cds/Compute/CDSComputeServiceFabricClusters.puml 'Loading specific icon only
```

## Variants
There are two variants for each icon:
- Colored transparent png image
- Monochromatic sprite

### Colored image
This is the default to use, it loads the png image from the internet.

Macro:
```
CDSComputeFunctionApps(functionAlias, "Label", "Technology", "Optional Description")
```
Render:

![img](docs/coloredfunction.png)

If you wish to use this locally, download this repo and change `IMAGE_SOURCE` in the `AzureCommon.puml` file.

### Monochromatic sprite
This uses generated monochromatic sprites if you wish to use these instead of images.

Macro:
```
CDSComputeFunctionApps_m(functionAlias, "Label", "Technology", "Optional Description")
```
![img](docs/monochromfunction.png)

If you wish to use monochromatic sprites locally, it's enough to download just [AzureCommon.yaml](https://github.com/czmirek/PlantUML-AzureIcons/blob/main/AzureCommon.puml) and [all.yaml](https://github.com/czmirek/PlantUML-AzureIcons/blob/main/dist/all.puml).

## Building
If you want to rebuild the image collection yourself, you need:
- Powershell core
- svgexport `npm install svgexport -g`
- Java

Then:
- Delete contents of dist/azure-cds and dist/azure-patterns
- Run `./scripts/build-all.ps1`


