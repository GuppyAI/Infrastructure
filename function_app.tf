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
  os_type             = "Windows"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "fa" {
  name                = "fa-${var.project_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  storage_account_name       = azurerm_storage_account.sa_fa.name
  storage_account_access_key = azurerm_storage_account.sa_fa.primary_access_key
  service_plan_id            = azurerm_service_plan.sp_fa.id

  zip_deploy_file = var.function_deploy_zip

  app_settings = {
    "INGRESS_QUEUE" : azurerm_servicebus_queue.sb_q_ingress.name
    "SERVICEBUS_CONNECTION_INGRESS" : azurerm_servicebus_queue_authorization_rule.sb_q_ingress_ar_listen.primary_connection_string
    "EGRESS_QUEUE" : azurerm_servicebus_queue.sb_q_sms-egress.name
    "SERVICEBUS_CONNECTION_EGRESS" : azurerm_servicebus_queue_authorization_rule.sb_q_sms-egress_ar_send.primary_connection_string
    "COSMOSDB_CONNECTION" : azurerm_cosmosdb_account.cdb_a.primary_sql_connection_string
    "COSMOSDB_DATABASE" : azurerm_cosmosdb_sql_database.cdb_sqldb.name
    "COSMOSDB_CONTAINER" : azurerm_cosmosdb_sql_container.cdb_sqldb_c_chats.name
    "OPENAI_ENDPOINT" : azurerm_cognitive_account.ca.endpoint
    "OPENAI_KEY" : azurerm_cognitive_account.ca.primary_access_key
    "OPENAI_VERSION" : "2024-05-01-preview"
    "OPENAI_DEPLOYMENT" : azurerm_cognitive_deployment.cd.name
    "OPENAI_SYSTEM_PROMPT" : var.system_promt
    "OPENAI_MAX_TOKENS" : 50
    "WEBSITE_RUN_FROM_PACKAGE" : var.function_deploy_zip != null? "1" : "0"
    "RESET_MESSAGE" : var.reset_message
  }

  site_config {
    application_stack {
      node_version = "20"
    }
  }
}
