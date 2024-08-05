resource "azurerm_servicebus_namespace" "sb_ns" {
  name                = "sb-ns-${var.project_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Basic"
}

resource "azurerm_servicebus_queue" "sb_q_ingress" {
  name         = "sb-q-ingress-${var.project_name}"
  namespace_id = azurerm_servicebus_namespace.sb_ns.id
}

resource "azurerm_servicebus_queue_authorization_rule" "sb_q_ingress_ar_send" {
  name     = "sb-q-ingress-ar-send-${var.project_name}"
  queue_id = azurerm_servicebus_queue.sb_q_ingress.id

  send   = true
}

resource "azurerm_servicebus_queue" "sb_q_sms-egress" {
  name         = "sb-q-sms-egress-${var.project_name}"
  namespace_id = azurerm_servicebus_namespace.sb_ns.id
}

resource "azurerm_servicebus_queue_authorization_rule" "sb_q_sms-egress_ar_listen" {
  name     = "sb-q-sms-egress-ar-listen-${var.project_name}"
  queue_id = azurerm_servicebus_queue.sb_q_sms-egress.id

  listen   = true
}