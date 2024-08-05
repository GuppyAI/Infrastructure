resource "azurerm_cosmosdb_account" "cdb_a" {
    name = "cdb-a-${var.project_name}"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    offer_type = "Standard"
    public_network_access_enabled = false
    capacity {
      total_throughput_limit = 1000
    }
    consistency_policy {
      consistency_level = "Session"
    }
    geo_location {
      location = azurerm_resource_group.rg.location
      failover_priority = 0
    }
    free_tier_enabled = true
    local_authentication_disabled = true
    backup {
      type = "Periodic"
      interval_in_minutes = 240
      retention_in_hours = 8
    }
}

resource "azurerm_cosmosdb_sql_database" "cdb_sqldb" {
    name = "cdb-sqldb-${var.project_name}"
    resource_group_name = azurerm_resource_group.rg.name
    account_name = azurerm_cosmosdb_account.cdb_a.name
}

resource "azurerm_cosmosdb_sql_container" "cdb_sqldb_c_chats" {
    name = "cdb-sqldb-c-chats${var.project_name}"
    resource_group_name = azurerm_resource_group.rg.name
    account_name = azurerm_cosmosdb_account.cdb_a.name
    database_name = azurerm_cosmosdb_sql_database.cdb_sqldb.name
    partition_key_paths = [ "/user_id" ]
    unique_key {
        paths = ["/user_id"]
    }
}

resource "azurerm_private_endpoint" "pe_cdb" {
  name                = "pe-cdb-${var.project_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.sn.id


  private_service_connection {
    name                           = "pe-con-cdb-${var.project_name}"
    private_connection_resource_id = azurerm_cosmosdb_account.cdb_a.id
    subresource_names              = ["account"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.pdnsz_cdb.id]
  }
}

resource "azurerm_private_dns_zone" "pdnsz_cdb" {
  name                = "cosmosdb.${var.project_name}.internal"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "pndsz_vnl_cdb" {
  name                  = "pdnsz-vnl-cdb-${var.project_name}"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.pdnsz_cdb.name
  virtual_network_id    = azurerm_virtual_network.vn.id
}