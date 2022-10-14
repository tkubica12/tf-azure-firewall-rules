resource "azurerm_resource_group" "main" {
  name     = "tf-fw-${var.name_prefix}"
  location = var.location
}
