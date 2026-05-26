# AMBA AVM Subscription Exemptions

This repository contains a single Terraform file, exemptions.tf, that adds subscription-level policy exemptions for Azure Monitor Baseline Alerts (AMBA) when using the Azure Verified Modules (AVM) ALZ Terraform pattern.

The purpose is to keep AMBA deployed broadly while excluding selected subscriptions (typically dev/test) from AMBA policy assignments.

Important: this repository is the host/source for exemptions.tf. The file is intended to be copied into the repository where you deploy AMBA, and Terraform should be run from that AMBA deployment working directory.

## What this gives you

- A self-contained exemption implementation in one file.
- A single input variable:
  - monitoring_excluded_subscription_ids
- The landing zone management group is resolved dynamically from your ALZ architecture definition — no manual input required.
- No need to spread exemption logic across multiple Terraform files.

## Prerequisites

- You are deploying AMBA with the official AVM Terraform pattern:
  - https://azure.github.io/azure-monitor-baseline-alerts/patterns/alz/HowTo/deploy/Deploy-with-Terraform/
- Your deployment already includes the AMBA module and related ALZ locals expected by exemptions.tf (for example module.amba_policy and management group naming locals).

## How to use

1. Follow the AVM AMBA deployment guide and prepare your Terraform configuration.
2. Download or copy exemptions.tf from this repository into the same Terraform working directory where your AMBA deployment files are located.
3. Provide the input variable in your .tfvars file.
4. Run terraform plan and terraform apply as usual.

### Example tfvars

```hcl
monitoring_excluded_subscription_ids = [
  "00000000-0000-0000-0000-000000000000",
  "11111111-1111-1111-1111-111111111111"
]
```

### Optional: download directly from GitHub

PowerShell:

```powershell
Invoke-WebRequest -Uri https://raw.githubusercontent.com/Forsmans/amba-avm-exemptions/main/exemptions.tf -OutFile exemptions.tf
```

## What the file does internally

- Builds subscription scopes from monitoring_excluded_subscription_ids.
- Resolves the landing zone management group dynamically by reading your ALZ architecture definition (`lib/custom.alz_architecture_definition.json`) and finding the management group with the `amba_landing_zones` archetype.
- Finds AMBA policy assignments under the relevant management group hierarchy.
- Creates one Microsoft.Authorization/policyExemptions resource per assignment/subscription combination.
- Uses stable, short resource names based on a hash.

## Scope and limitations

- This solution supports exemptions for landing zones only.
- Exemptions targeting platform or sandbox hierarchies are out of scope.
- Sandbox subscriptions are intentionally not targeted by this approach.
- If AMBA module structure or naming changes, exemptions.tf may need updates.
- If native exemption support is added to AVM AMBA (or if EPAC is adopted), this file should be re-evaluated.

## Repository contents

- exemptions.tf: reusable Terraform exemption logic
