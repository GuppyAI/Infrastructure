# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.114.0"
    }
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

variable "project_name" {
  type    = string
  default = "guppyai"
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project_name}"
  location = "northeurope"
}
