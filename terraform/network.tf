resource "azurerm_virtual_network" "vn" {
  name                = "vn-${var.project_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
  encryption {
    enforcement = "AllowUnencrypted"
  }
}

resource "azurerm_subnet" "sn" {
  name = "sn-${var.project_name}"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes = [ "10.0.0.0/24" ]
}