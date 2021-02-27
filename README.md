# PlantUML-AzureIcons
This project is completely reworked "fork" of [RicardoNiepel/Azure-PlantUML](https://github.com/RicardoNiepel/Azure-PlantUML). Some documentation from there still applies also to this project and the box styles are the same.

There are several important changes.

- It uses the ['CDS' Azure Icons Set](https://github.com/benc-uk/icon-collection) from the [benc-uk/icon-collection](https://github.com/benc-uk/icon-collection) repository which is much more complete icon collection than the other sources.

- The code in [`AzureCommon.yaml`](https://github.com/czmirek/PlantUML-AzureIcons/blob/main/AzureCommon.puml) is mostly the same from the [original](https://github.com/plantuml-stdlib/Azure-PlantUML) file but all other options were removed/reworked.

## Usage
Put this into your PUML to include add support for all images.

```puml
!define AzurePuml https://raw.githubusercontent.com/czmirek/PlantUML-AzureIcons/main/dist
!include AzurePuml/AzureCommon.puml
!include AzurePuml/all.puml
```
Then look into the [macro table](https://github.com/czmirek/PlantUML-AzureIcons/blob/main/table.md) and find whatever you want to add into your PUML in same manner as from the former official library. 

## BEWARE: The macros are different!
The macros are [COMPLETELY different](https://github.com/plantuml-stdlib/Azure-PlantUML/blob/master/AzureSymbols.md#azure-symbols) from the original RicardoNiepel/Azure-PlantUML repository! You cannot just replace the header, you need to replace the individual boxes with different calls as well

> *This is because the macros are automatically generated from the image names from the [image repository](https://github.com/benc-uk/icon-collection/tree/master/azure-cds), they are not hand written into a configuration file.*

But the macros signature are still the same, therefore a project wide string replace should make it.

### Example macros:
| Image   | Original macro      | New macro  |
|----------|-------------|------|
| [AzureComputeFunctionApps](dist/AzureComputeFunctionApps_tbg.png) |  `AzureFunction` | `AzureComputeFunctionApps` |

