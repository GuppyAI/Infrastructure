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

resource "azurerm_private_endpoint" "pe_sb" {
  name                = "pe-sb-${var.project_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.sn.id


  private_service_connection {
    name                           = "pe-con-sb-${var.project_name}"
    private_connection_resource_id = azurerm_servicebus_namespace.sb_ns.id
    subresource_names              = ["account"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.pdnsz_sb.id]
  }
}

resource "azurerm_private_dns_zone" "pdnsz_sb" {
  name                = "servicebus.${var.project_name}.internal"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "pndsz_vnl_sb" {
  name                  = "pdnsz-vnl-sb-${var.project_name}"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.pdnsz_sb.name
  virtual_network_id    = azurerm_virtual_network.vn.id
}