resource "azurerm_firewall_policy" "main" {
  name                = "policy-${var.name_prefix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}
