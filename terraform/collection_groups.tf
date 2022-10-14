locals {
  rules_path = "../rules"
}

resource "azurerm_firewall_policy_rule_collection_group" "main" {
  # for_each         = fileset(var.path, "/app-*.yaml")
  for_each           = yamldecode(file("${local.rules_path}/metadata.yaml"))["projects"]
  name               = each.key
  firewall_policy_id = azurerm_firewall_policy.main.id
  priority           = each.value["firewall_priority"]

  depends_on = [
    azurerm_ip_group.projects
  ]

  dynamic "application_rule_collection" {
    for_each = fileset("${local.rules_path}/${each.key}", "app-*.yaml")
    content {
      name     = yamldecode(file("${local.rules_path}/${each.key}/${application_rule_collection.value}"))["name"]
      priority = yamldecode(file("${local.rules_path}/${each.key}/${application_rule_collection.value}"))["priority"]
      action   = "Allow"

      dynamic "rule" {
        for_each = yamldecode(file("${local.rules_path}/${each.key}/${application_rule_collection.value}"))["rules"]
        content {
          name = rule.key

          dynamic "protocols" {
            for_each = rule.value["protocols"]
            content {
              type = protocols.key
              port = protocols.value["port"]
            }
          }

          source_ip_groups  = [azurerm_ip_group.projects[each.key].id]
          destination_fqdns = rule.value["destination_fqdns"]
        }
      }
    }
  }

  dynamic "network_rule_collection" {
    for_each = fileset("${local.rules_path}/${each.key}", "net-*.yaml")
    content {
      name     = yamldecode(file("${local.rules_path}/${each.key}/${network_rule_collection.value}"))["name"]
      priority = yamldecode(file("${local.rules_path}/${each.key}/${network_rule_collection.value}"))["priority"]
      action   = "Allow"

      dynamic "rule" {
        for_each = yamldecode(file("${local.rules_path}/${each.key}/${network_rule_collection.value}"))["group_rules"]
        content {
          name                  = rule.key
          protocols             = rule.value["protocols"]
          destination_ip_groups = [azurerm_ip_group.projects[each.key].id]
          source_ip_groups      = [for group in rule.value["source_ip_groups"] : azurerm_ip_group.projects[group].id]
          destination_ports     = rule.value["destination_ports"]
        }
      }

      dynamic "rule" {
        for_each = yamldecode(file("${local.rules_path}/${each.key}/${network_rule_collection.value}"))["ip_rules"]
        content {
          name                  = rule.key
          protocols             = rule.value["protocols"]
          destination_ip_groups = [azurerm_ip_group.projects[each.key].id]
          source_addresses      = rule.value["source_ranges"]
          destination_ports     = rule.value["destination_ports"]
        }
      }
    }
  }
}
