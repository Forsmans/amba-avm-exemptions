variable "monitoring_excluded_subscription_ids" {
  type        = list(string)
  default     = []
  description = "Subscription IDs excluded from AMBA monitoring by creating policy exemptions for AMBA policy assignments."
}

locals {
  monitoring_excluded_not_scopes = [
    for subscription_id in var.monitoring_excluded_subscription_ids :
    format("/subscriptions/%s", subscription_id)
  ]
  landing_zones_policy_assignment_resource_ids = {
    for key, resource_id in module.amba_policy.policy_assignment_resource_ids :
    key => resource_id
    if startswith(key, format("%s/", local.landing_zones_management_group_name))
  }
  amba_policy_assignment_resource_ids = {
    for key, resource_id in module.amba_policy.policy_assignment_resource_ids :
    key => resource_id
    if strcontains(key, "/Deploy-AMBA-") && (
      startswith(key, format("%s/", local.effective_root_management_group_name)) ||
      startswith(key, format("%s/", local.landing_zones_management_group_name))
    )
  }
  amba_policy_assignment_subscription_exemptions = {
    for combination in setproduct(
      toset(keys(local.amba_policy_assignment_resource_ids)),
      toset(var.monitoring_excluded_subscription_ids)
    ) :
    format("%s|%s", combination[0], combination[1]) => {
      assignment_key  = combination[0]
      assignment_id   = local.amba_policy_assignment_resource_ids[combination[0]]
      subscription_id = combination[1]
    }
  }
}

resource "azapi_resource" "monitoring_policy_exemptions" {
  for_each = local.amba_policy_assignment_subscription_exemptions

  type      = "Microsoft.Authorization/policyExemptions@2022-07-01-preview"
  name      = format("amba-excl-%s", substr(md5(each.key), 0, 16))
  parent_id = format("/subscriptions/%s", each.value.subscription_id)
  body = {
    properties = {
      exemptionCategory  = "Waiver"
      policyAssignmentId = each.value.assignment_id
      description = format(
        "Exclude subscription %s from AMBA policy assignment %s",
        each.value.subscription_id,
        each.value.assignment_key
      )
      displayName = format(
        "AMBA exclusion %s",
        each.value.assignment_key
      )
    }
  }

  depends_on = [module.amba_policy]
}
