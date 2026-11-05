
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

# Connexion à Microsoft Azure
provider "azurerm" {
  features {}
}

# Région Azure
variable "location" {
  description = "Region Azure"
  type        = string
  default     = "canadacentral"
}

# Étape 7 - Groupe de ressources
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

# Étape 8 - Réseau virtuel Azure
resource "azurerm_virtual_network" "cr460" {
  name                = "vnet-cr460-devoir"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.cr460.location
  resource_group_name = azurerm_resource_group.cr460.name

  tags = {
    Projet        = "CR460"
    Environnement = "Devoir"
    Gestion       = "Terraform"
  }
}

# Sous-réseau pour la future VM
resource "azurerm_subnet" "vm" {
  name                 = "snet-cr460-vm"
  resource_group_name  = azurerm_resource_group.cr460.name
  virtual_network_name = azurerm_virtual_network.cr460.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Résultats du déploiement
output "virtual_network_name" {
  value = azurerm_virtual_network.cr460.name
}

output "subnet_id" {
  value = azurerm_subnet.vm.id
}
