output "acr_name" {
  value = var.acr_name
}

output "acr_password" {
  sensitive = true
  value     = azurerm_container_registry.acr.admin_password
}

output "rg_name" {
  value = azurerm_resource_group.rg.name
}

output "web_app_name" {
  value = azurerm_linux_web_app.app.name
}
