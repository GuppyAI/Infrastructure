module "openai" {
  source  = "Azure/openai/azurerm"
  version = "0.1.3"

  resource_group_name = azurerm_resource_group.rg.name
  location = "francecentral"
  account_name = "acc-oai-${var.project_name}"
  application_name = "app-oai-${var.project_name}"
  custom_subdomain_name = var.project_name
  dynamic_throttling_enabled = true

  private_endpoint = {
    "pe-${var.project_name}" = {
      private_dns_entry_enabled       = true
      dns_zone_virtual_network_link   = "dns_zone_link"
      is_manual_connection            = false
      name                            = "pe_one"
      private_service_connection_name = "pe_one_connection"
      subnet_name                     = azurerm_subnet.sn.name
      vnet_name                       = azurerm_virtual_network.vn.name
      vnet_rg_name                    = azurerm_virtual_network.vn.resource_group_name
    }
  }

  deployment = {
    "oai-d-${var.project_name}" = {
      name = "oai-d-${var.project_name}"
      model_format = "OpenAI"
      model_name = "gpt-35-turbo"
      model_version = "0301"
      scale_type = "Standard"
      capacity = 1
      version_upgrade_option = "OnceNewDefaultVersionAvailable"
    }
  }

  depends_on = [
    azurerm_resource_group.rg,
    azurerm_virtual_network.vn,
    azurerm_subnet.sn,
    var.project_name
  ]
}