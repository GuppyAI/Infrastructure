resource "azurerm_storage_account" "sa_fa" {
  name                     = "safa${var.project_name}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "sp_fa" {
  name                = "sp-fa-${var.project_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "fa" {
  name                = "fa-${var.project_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  storage_account_name       = azurerm_storage_account.sa_fa.name
  storage_account_access_key = azurerm_storage_account.sa_fa.primary_access_key
  service_plan_id            = azurerm_service_plan.sp_fa.id

  site_config {
    application_stack {
        node_version=20
    }
  }
}


resource "azurerm_private_endpoint" "pe_fa" {
  name                = "pe-fa-${var.project_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.sn.id


  private_service_connection {
    name                           = "pe-con-fa-${var.project_name}"
    private_connection_resource_id = azurerm_service_plan.sp_fa.id
    subresource_names              = ["account"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.pdnsz_fa.id]
  }
}

resource "azurerm_private_dns_zone" "pdnsz_fa" {
  name                = "cloudfunction.${var.project_name}.internal"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "pndsz_vnl_fa" {
  name                  = "pdnsz-vnl-fa-${var.project_name}"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.pdnsz_fa.name
  virtual_network_id    = azurerm_virtual_network.vn.id
}