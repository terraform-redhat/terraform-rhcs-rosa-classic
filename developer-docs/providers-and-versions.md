# Providers and versions

- MUST: Root `versions.tf` lists minimum **rhcs** and **aws** (and any other) provider versions for the **entire** tree (root + all `modules/**`).
- MUST: Raise root floor when any submodule raises `required_providers` — root must not be lower than any submodule.
- MUST: Confirm new AWS resources/data sources exist in the **aws** provider range declared in `versions.tf`.

## Renovate and consumer floors (ROSAENG-61027)

- **rhcs** (`terraform-redhat/rhcs`): Renovate may auto-bump the root `required_providers` floor in `versions.tf`.
- **aws**, **null**, and other non-rhcs providers: bump **manually** only when a feature, security fix, or submodule requirement needs it. Renovate must not change consumer floors.
- **Terraform module pins** (`terraform-aws-modules/*`, etc. under `modules/**`): bump **manually** only.
- **`# tested_aws_provider_latest`**: Renovate updates this comment in root `versions.tf` when a new AWS provider release is published. It does **not** change consumer constraints; it records the version targeted by CI on the last green Renovate PR.

## CI verification

- **`make verify`** runs `scripts/verify.sh`: for each example and the root module, `terraform validate` at the **effective AWS provider floor** (pinned) and at **latest** matching all `>=` constraints (unpinned init).
- Effective floor = max(root floor, example floor, module-tree floor). Paths that pull in `account-iam-resources` or `ocm-role` therefore exercise **aws >= 6.0**, not necessarily the root floor alone. Registry modules (for example `terraform-aws-modules/s3-bucket`) may raise the merged floor further; the floor pass reads merged constraints from `.terraform.lock.hcl` after init.

WHEN a feature is OpenShift version-gated:

- MUST: Document minimum OpenShift version in variable `description` and README.

DEFAULT: No extra version callout beyond what the **rhcs** provider schema requires.

**See:** [`submodules.md`](submodules.md)
