# Architecture

- MUST: **ROSA Classic only** — not [ROSA HCP](https://github.com/terraform-redhat/terraform-rhcs-rosa-hcp).
- MUST NOT: HCP-only resources (e.g. `rhcs_cluster_rosa_hcp`, HCP log forwarders, kubelet-configs, image-mirrors).
- MUST: Follow **this** repo's `main.tf` and `versions.tf` in shared submodules (e.g. `modules/idp`).
- MUST: Use [`terraform-redhat/rhcs`](https://github.com/terraform-redhat/terraform-provider-rhcs) registry schema/docs — do not invent attributes.

**See:** [AWS — ROSA architecture models](https://docs.aws.amazon.com/rosa/latest/userguide/rosa-architecture-models.html#rosa-architecture-differences)

## ROSA CLI parity (when applicable)

WHEN Terraform replaces or must interoperate with [ROSA CLI](https://docs.openshift.com/rosa/cli_reference/rosa_cli/rosa-get-started-cli.html) workflows:
- MUST: Match CLI naming and validation so ROSA tooling recognizes resources.
- PREFER: `rhcs_policies` for trust/permission documents (policy records, trust policies).
- MUST NOT: `rhcs_hcp_*` data sources or resources — HCP-only; use `rhcs_policies` for Classic STS policy documents.
- PREFER: `rhcs_info` for organization metadata (e.g. `organization_external_id`).
- MUST: Put CLI-mirrored checks in `validation` blocks — see [`variables.md`](variables.md).
DEFAULT: If not interoperating with the ROSA CLI, prioritize pure **rhcs** provider defaults.

**See:** [`modules/ocm-role/`](../modules/ocm-role/)
