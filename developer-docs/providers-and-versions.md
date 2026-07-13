# Providers and versions

## Consumer floors (`required_providers`)

- **Root floor** — [`versions.tf`](../versions.tf) declares the **minimum AWS provider version required to use the root module** (today: `aws >= 6.0.0`, `null >= 3.3.0`; `rhcs` Renovate-managed).
- **Submodule floors** — match root **unless that submodule needs a different minimum**; raise the floor **only in that submodule’s `versions.tf`**. Submodule-only consumers (for example `ocm-role`) may stay at a lower floor when their graph does not include the root cluster module.
- **Customer impact** — Bump consumer floors **only when HCL or a pinned registry module truly requires it**. Do not raise floors because of transitive registry drift or Renovate churn.

| Submodule / use case | Typical `aws` floor | Notes |
|----------------------|---------------------|--------|
| Root module (includes `rosa-cluster-classic`) | `>= 6.0.0` | Uses `data.aws_region.current.region` (AWS provider 6.0+) |
| `oidc-config-and-provider`, `vpc`, `shared-vpc-policy-and-hosted-zone` | `>= 6.0.0` | Same `.region` attribute |
| Submodule-only (`ocm-role`, `account-iam-resources`, …) | `>= 4.67.0` | When used without the full root cluster graph |

- MUST: Confirm new AWS resources/data sources exist in the **aws** provider range declared in the relevant `versions.tf`.
- Provider floor changes are **minor** semver events for the module (see release notes).

Registry module pins under `modules/**` (for example `terraform-aws-modules/s3-bucket`) are **exact versions**, bumped **manually**, so upstream module releases do not force customer AWS provider upgrades unrelated to this module.

## Renovate

| Target | Renovate behavior |
|--------|-------------------|
| **Root `versions.tf` — rhcs** | Auto-bump `required_providers` floor |
| **Root `versions.tf` — aws, null, …** | **Disabled** — manual only |
| **`examples/**/versions.tf` — aws, rhcs** | Auto-**pin** and bump exact versions (`rangeStrategy: pin`) |
| **`modules/**` — providers and module pins** | **Disabled** — manual only |

WHEN a provider or registry module bump would raise the customer-facing floor, treat it as a deliberate maintainer decision with release-note impact — not something Renovate should do silently.

## CI verification

| Pass | What `make verify` does |
|------|-------------------------|
| **Pinned** | Each example `versions.tf` exact pins → `terraform init` + `validate` |
| **Floor** | Same example with AWS constraint temporarily set to `examples/*/.aws-provider-floor` → `init` + `validate` |

- Each example **must** have `examples/<name>/.aws-provider-floor` (one line, e.g. `6.0.0` or `4.67.0` for `ocm-role`).
- Floor values document the **minimum AWS version that example’s graph needs**.
- Lock files are **not** committed (gitignored; ephemeral in CI).
- **Prow `run-example`** uses the example’s pinned providers from `examples/**/versions.tf`.

GitHub Actions **`verify-min-terraform.yml`** runs `make verify` at Terraform **1.5.7** (module minimum).

WHEN a feature is OpenShift version-gated:

- MUST: Document minimum OpenShift version in variable `description` and README.

**See:** [`submodules.md`](submodules.md)
