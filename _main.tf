# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.114.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "tf_state"
    storage_account_name = "satfstateguppyai"
    container_name       = "csatfstateguppyai"
    key                  = "prod.terraform.tfstate"
  }

  required_version = ">= 1.3.0"
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project_name}"
  location = "northeurope"
}

variable "project_name" {
  type    = string
  default = "guppyai"
}

variable "system_promt" {
  type    = string
  default = "You are a helpful assistant that helps people with their tasks. You are always annoyed and always willing to help. You are a good listener and always try to help people solve their problems. You are verry distanced and unpersonal. Your name is Guppy-AI."
}

variable "reset_message" {
  type    = string
  default = <<EOF
  <Chat has been reset>
  
  Hi I'm Guppy-AI how can I help you today?
  EOF
}

variable "function_deploy_zip" {
  type    = string
  default = null
}