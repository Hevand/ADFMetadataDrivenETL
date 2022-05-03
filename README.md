# Azure Data Factory - Metadata driven ETL


# Deploy pipeline
[![Deploy To Azure](https://docs.microsoft.com/en-us/azure/templates/media/deploy-to-azure.svg)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FHevand%2FADFMetadataDrivenETL%2Fadf_publish%2Fhevandadfsample%2FARMTemplateForFactory.json)

Missing (to be created manually / scripted later):
- config database, containing the two stored procedures in [sql](./sql/)
- source databases, with SampleIncrement / SampleFull tables and some initial data
- target storage account with container


## Background
Database sharding offers a great way to scale a multi-tenant application, but it may complicate the ETL process. 

In this repository, we're using the [large-scale data copy pipeline with metadata](https://docs.microsoft.com/en-us/azure/data-factory/copy-data-tool-metadata-driven) as a starting point and tweak as follows: 
- The Azure Management API is used to iterate over all available databases
- The metadata configuration table is populated automatically
- A metadata configuration table is created per database
- Logic has been added to allow the *rowversion* watermark column type

## Disclaimer
Your mileage might vary. This repository represents the result of a discussion / POC, but *does not* represent the only way of approaching doing this.
