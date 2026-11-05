
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

# Sous-réseau pour la VM
resource "azurerm_subnet" "vm" {
  name                 = "snet-cr460-vm"
  resource_group_name  = azurerm_resource_group.cr460.name
  virtual_network_name = azurerm_virtual_network.cr460.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Résultats du déploiement réseau
output "virtual_network_name" {
  value = azurerm_virtual_network.cr460.name
}

output "subnet_id" {
  value = azurerm_subnet.vm.id
}


# Clé SSH publique configurée dans HCP Terraform
variable "ssh_public_key" {
  description = "Cle SSH publique pour la VM Ubuntu"
  type        = string
}

# Taille de la machine virtuelle
variable "vm_size" {
  description = "Taille de la machine virtuelle Azure"
  type        = string
  default     = "Standard_B2s"
}

# Interface réseau de la machine virtuelle
resource "azurerm_network_interface" "vm" {
  name                = "nic-cr460-linux"
  location            = azurerm_resource_group.cr460.location
  resource_group_name = azurerm_resource_group.cr460.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    Projet        = "CR460"
    Environnement = "Devoir"
    Gestion       = "Terraform"
  }
}

# Machine virtuelle Ubuntu Server 22.04
resource "azurerm_linux_virtual_machine" "cr460" {
  name                = "vm-cr460-linux"
  resource_group_name = azurerm_resource_group.cr460.name
  location            = azurerm_resource_group.cr460.location
  size                = var.vm_size

  admin_username                  = "azureuser"
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.vm.id
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    Projet        = "CR460"
    Environnement = "Devoir"
    Gestion       = "Terraform"
  }
}

# Résultats du déploiement VM
output "vm_name" {
  value = azurerm_linux_virtual_machine.cr460.name
}

output "vm_private_ip" {
  value = azurerm_network_interface.vm.private_ip_address
}
