resource "azurerm_cognitive_account" "ca" {
  name                = "ca-${var.project_name}"
  location            = "francecentral"
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "OpenAI"
  sku_name            = "S0"
  public_network_access_enabled = true
  custom_subdomain_name = var.project_name
}

resource "azurerm_cognitive_deployment" "cd" {
  name                 = "cd-${var.project_name}"
  cognitive_account_id = azurerm_cognitive_account.ca.id
  model {
    format  = "OpenAI"
    name    = "gpt-35-turbo"
    version = "0301"
  }

  scale {
    type = "Standard"
  }
}