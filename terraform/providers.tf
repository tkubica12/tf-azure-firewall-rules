terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3"
    }
  }
  backend "azurerm" {
    use_oidc = true
    use_azuread_auth = true
    storage_account_name = "tkubicastore"
    container_name = "tfstate"
    key = "tf-azure-firewall-rules.tfstate"
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
