resource "azurerm_ip_group" "onprem" {
  name                = "onprem"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  cidrs               = ["10.99.0.0/16", "192.168.0.0/18"]
}

resource "azurerm_ip_group" "projects" {
  for_each            = yamldecode(file("../rules/metadata.yaml"))["projects"]
  name                = each.key
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  cidrs               = each.value["ranges"]
}




# for_each         = fileset(path.module, "subscriptions/*.yaml")
