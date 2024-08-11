resource "azurerm_cosmosdb_account" "cdb_a" {
    name = "cdb-a-${var.project_name}"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    offer_type = "Standard"
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
    name = "cdb-sqldb-c-chats-${var.project_name}"
    resource_group_name = azurerm_resource_group.rg.name
    account_name = azurerm_cosmosdb_account.cdb_a.name
    database_name = azurerm_cosmosdb_sql_database.cdb_sqldb.name
    partition_key_paths = [ "/id" ]
}