resource "azurerm_ip_group" "projects" {
  for_each            = yamldecode(file("../rules/metadata.yaml"))["projects"]
  name                = each.key
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  cidrs               = each.value["ranges"]
}

