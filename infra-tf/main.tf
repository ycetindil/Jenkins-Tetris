terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.50.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "ycetindil"
    storage_account_name = "ycetindil"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    use_msi              = true
    subscription_id      = "453194c6-9b5a-46f8-bf6e-6b5a4133ee3a"
    tenant_id            = "1a93b615-8d62-418a-ac28-22501cf1f978"
  }
}

provider "azurerm" {
  features {}

  use_msi         = true
  subscription_id = "453194c6-9b5a-46f8-bf6e-6b5a4133ee3a"
  tenant_id       = "1a93b615-8d62-418a-ac28-22501cf1f978"
}

######################
### RESOURCE GROUP ###
######################
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}

###########
### ACR ###
###########
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = true
}

########################
### APP SERVICE PLAN ###
########################
resource "azurerm_service_plan" "asp" {
  name                = var.prefix
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "P1v2"
}

###############
### WEB APP ###
###############
resource "azurerm_linux_web_app" "app" {
  name                = var.web_app_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {}
}