
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



# Étape 7 - Groupe de ressources
resource "azurerm_resource_group" "cr460" {
  name     = "rg-cr460-devoir"
  location = var.location

  tags = local.tags_communs
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

  tags = local.tags_communs
}

# Étape 10 - Déploiement d'un conteneur Docker dans Azure

resource "azurerm_container_group" "cr460" {
  name                = "aci-cr460-devoir"
  location            = azurerm_resource_group.cr460.location
  resource_group_name = azurerm_resource_group.cr460.name

  ip_address_type = "Public"
  os_type         = "Linux"

  container {
    name   = "nginx-cr460"
    image  = "nginx:alpine"
    cpu    = 0.5
    memory = 1.0

    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  exposed_port {
    port     = 80
    protocol = "TCP"
  }

  tags = local.tags_communs
}

output "container_ip" {
  value = azurerm_container_group.cr460.ip_address
}
variable "location" {
  description = "Region Azure"
  type        = string
  default     = "canadacentral"
}

variable "resource_group_name" {
  description = "Nom du groupe de ressources"
  type        = string
  default     = "rg-cr460-devoir"
}

variable "virtual_network_name" {
  description = "Nom du reseau virtuel"
  type        = string
  default     = "vnet-cr460-devoir"
}

variable "vm_name" {
  description = "Nom de la machine virtuelle"
  type        = string
  default     = "vm-cr460-linux"
}

variable "vm_size" {
  description = "Taille de la machine virtuelle Azure"
  type        = string
  default     = "Standard_B2s"
}

# Étape 12 - Azure Key Vault

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "cr460" {
  name                       = "kv-cr460-lab-2026"
  location                   = azurerm_resource_group.cr460.location
  resource_group_name        = azurerm_resource_group.cr460.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  enable_rbac_authorization  = true
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  tags = local.tags_communs
}

output "key_vault_id" {
  value = azurerm_key_vault.cr460.id
}

# Étape 13 - Tags de gestion des coûts
locals {
  tags_communs = {
    Projet        = "DevoirCR460"
    Environnement = "Devoir"
    Gestion       = "Terraform"
    CentreCout    = "Formation"
  }
}