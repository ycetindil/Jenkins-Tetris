terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.50.0"
    }
    github = {
      source  = "integrations/github"
      version = "5.20.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "ycetindil"
    storage_account_name = "ycetindil"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
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