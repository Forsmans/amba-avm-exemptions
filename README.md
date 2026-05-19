# AMBA AVM Subscription Exemptions

This repository contains a single Terraform file, exemptions.tf, that adds subscription-level policy exemptions for Azure Monitor Baseline Alerts (AMBA) when using the Azure Verified Modules (AVM) ALZ Terraform pattern.

The purpose is to keep AMBA deployed broadly while excluding selected subscriptions (typically dev/test) from AMBA policy assignments.

## What this gives you

- A self-contained exemption implementation in one file.
- Two input variables:
  - monitoring_excluded_subscription_ids
  - alz_root_management_group_name
- No need to spread exemption logic across multiple Terraform files.

## Prerequisites

- You are deploying AMBA with the official AVM Terraform pattern:
  - https://azure.github.io/azure-monitor-baseline-alerts/patterns/alz/HowTo/deploy/Deploy-with-Terraform/
- Your deployment already includes the AMBA module and related ALZ locals expected by exemptions.tf (for example module.amba_policy and management group naming locals).

## How to use

1. Follow the AVM AMBA deployment guide and prepare your Terraform configuration.
2. Copy exemptions.tf into the same Terraform working directory where your AMBA deployment files are located.
3. Provide both input variables in your .tfvars file.
4. Run terraform plan and terraform apply as usual.

### Example tfvars

```hcl
monitoring_excluded_subscription_ids = [
  "00000000-0000-0000-0000-000000000000",
  "11111111-1111-1111-1111-111111111111"
]

alz_root_management_group_name = "alz"
```

### Optional: download directly from GitHub

PowerShell:

```powershell
Invoke-WebRequest -Uri https://raw.githubusercontent.com/Forsmans/amba-avm-exemptions/main/exemptions.tf -OutFile exemptions.tf
```

## What the file does internally

- Builds subscription scopes from monitoring_excluded_subscription_ids.
- Finds AMBA policy assignments under the relevant management group hierarchy.
- Creates one Microsoft.Authorization/policyExemptions resource per assignment/subscription combination.
- Uses stable, short resource names based on a hash.

## Scope and limitations

- Intended for Corp landing zone subscriptions under the og-landing-zones hierarchy.
- Sandbox subscriptions are intentionally not targeted by this approach.
- If AMBA module structure or naming changes, exemptions.tf may need updates.
- If native exemption support is added to AVM AMBA (or if EPAC is adopted), this file should be re-evaluated.

## Repository contents

- exemptions.tf: reusable Terraform exemption logic
