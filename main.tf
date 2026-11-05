

terraform {
  required_version = ">= 1.16.6"

  cloud {
    organization = "DE01_CR460"

    workspaces {
      name = "CR460-Azure"
    }
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}


provider "azurerm" {
  features {}
}


variable "location" {
  description = "Region Azure"
  type        = string
  default     = "canadacentral"
}

resource "azurerm_resource_group" "cr460" {
  name     = "rg-cr460-devoir"
  location = var.location

  tags = {
    Projet        = "CR460"
    Environnement = "Devoir"
    Gestion       = "Terraform"
  }
}

output "resource_group_name" {
  value = azurerm_resource_group.cr460.name
}
