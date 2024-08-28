# Infrastructure

This repository contains the Terraform code to create the infrastructure for GuppyAI.
The infrastructure is composed of the following resources:
- Azure Service Bus
- Azure Function App
- Cosmos DB
- Azure Cognitive Services

All ressources related to the main Services can be found in the respective Terraform files.
For CI/CD shared state is used with a separate Azure Blob Storage Account.

## Prerequisites
- Terraform installed
- Azure CLI installed and authenticated

## Usage

1. Clone the repository
2. Run `terraform init` to initialize the Terraform configuration
3. Run `terraform plan` to see the changes that will be applied
4. Run `terraform apply` to apply the changes
5. Run `terraform destroy` to destroy the infrastructure

## Configuration

The configuration is done via variables in the `_main.tf` file. The variables are:
- `project_name`: The name of the project
- `system_promt`: The system prompt for the Azure Cognitive Services deployment
- `reset_message`: The reset message that the Azure Function App will respond with on a reset request
- `function_deploy_zip`: The path to the zip file containing the Azure Function App code for the initial deployment

## CI/CD

The CI/CD pipeline is implemented with GitHub Actions and will be triggered on every push to the `main` branch. The pipeline will run the Terraform code and apply the changes to the infrastructure.

The pipeline can be configured with the following environment variables:
- RELEASE_FILE: Link to the latest release of the Azure Function App
- TF_VAR_RESET_MESSAGE: The reset message that the Azure Function App will respond with on a reset request
- TF_VAR_SYSTEM_PROMPT: The system prompt for the Azure Cognitive Services deployment

Additionally, the pipeline requires the following secrets:
- ARM_SAS_TOKEN: The SAS token for the Azure Blob Storage Account to store the Terraform state
- AZURE_CREDENTIALS: The Azure credentials to authenticate the Azure CLI