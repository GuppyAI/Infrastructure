resource "azurerm_cognitive_account" "ca" {
  name                = "ca-${var.project_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "OpenAI"
  sku_name            = "S0"
  public_network_access_enabled = false
  custom_subdomain_name = var.project_name
}

resource "azurerm_cognitive_deployment" "cd" {
  name                 = "cd-${var.project_name}"
  cognitive_account_id = azurerm_cognitive_account.ca.id
  model {
    format  = "OpenAI"
    name    = "gpt-35-turbo"
  }

  scale {
    type = "Standard"
  }
}

resource "azurerm_private_endpoint" "pe_oai" {
  name                = "pe-oai-${var.project_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.sn.id


  private_service_connection {
    name                           = "pe-con-oai-${var.project_name}"
    private_connection_resource_id = azurerm_cognitive_account.ca.id
    subresource_names              = ["account"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.pdnsz_oai.id]
  }
}

resource "azurerm_private_dns_zone" "pdnsz_oai" {
  name                = "openai.${var.project_name}.internal"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "pndsz_vnl_oai" {
  name                  = "pdnsz-vnl-oai-${var.project_name}"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.pdnsz_oai.name
  virtual_network_id    = azurerm_virtual_network.vn.id
}