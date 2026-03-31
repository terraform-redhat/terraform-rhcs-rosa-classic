# Agent guide — terraform-rhcs-rosa-classic

This repository is the **ROSA Classic** Terraform module. The sibling **ROSA HCP** module is [`terraform-rhcs-rosa-hcp`](https://github.com/terraform-redhat/terraform-rhcs-rosa-hcp) — do not mix architectures.

## Where rules live

| File | Purpose |
|------|--------|
| [`.cursor/rules/`](.cursor/rules/) | Hard, stable guardrails (architecture boundaries, provider/version constraints, variable conventions, credentials/secrets) |
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | Command and procedure authority (fmt, verify, docs generation, test execution) |
| This file | Process narrative, security expectations, and decision workflow for agents |

Thin entrypoints [`CLAUDE.md`](CLAUDE.md) and [`GEMINI.md`](GEMINI.md) only point here so we do not duplicate content.

## HashiCorp Terraform skills

Upstream skills live under:

**https://github.com/hashicorp/agent-skills/tree/main/terraform**

Important: if you encounter a conflict between the skills below and this repository’s `CONTRIBUTING.md`, `CONTRIBUTING.md` takes precedence.

Useful skills for this codebase:

| Skill | When to use |
|-------|-------------|
| **terraform-style-guide** | Formatting HCL, variable/output layout, naming |
| **terraform-test** | Adding or changing `*.tftest.hcl`, mocks, `terraform test` |
| **refactor-module** | Splitting modules, clarifying interfaces, safe refactors |

**How to use them**

1. Open the skill’s `SKILL.md` in the repo (or your local skills mirror).
2. Apply its workflow to the task (style, tests, or refactor) instead of inventing patterns.
3. Still respect this repository’s `CONTRIBUTING.md` and **root `versions.tf`** constraints.

## Provider & versions

- [`terraform-redhat/rhcs`](https://github.com/terraform-redhat/terraform-provider-rhcs) defines resource schemas — mirror them in variables and docs.
- Root **`versions.tf`** = effective minimum **rhcs** and **aws** for **all** submodules; bump root when any submodule needs a newer provider.

## Architecture reference

- [AWS — ROSA vs HCP vs Classic](https://docs.aws.amazon.com/rosa/latest/userguide/rosa-architecture-models.html#rosa-architecture-differences)

## Security

**Canonical baseline** (must / must-not): [`.cursor/rules/rosa-classic-terraform.mdc`](.cursor/rules/rosa-classic-terraform.mdc) — section **Security**. If anything below conflicts with that file or with **`CONTRIBUTING.md`**, follow those sources.

**Agent-oriented checks** when editing Terraform, **`examples/`**, and tests:

- Do **not** hardcode secrets, API keys, or long-lived AWS access keys in Terraform, examples, or tests. Prefer patterns in existing **`examples/`** and Red Hat documentation (STS, OIDC, IRSA, short-lived credentials).
- Use **`sensitive`** on variables and outputs where values must not appear in logs or casual `terraform show` output; avoid echoing secrets in `local` values used only for debugging.
- Do not add logging, outputs, or comments that expose credentials or session tokens.

## Critical module guardrails

- **Breaking changes:** Do **not** change existing variable names or types without a migration plan (refactor-module skill).
- **Classic specifics:** Always verify if a feature applies to **Classic** vs **HCP**. This repo centers on **`rhcs_cluster_rosa_classic`** and related Classic resources — do not copy HCP-only resource shapes from the HCP module.

## Workflow logic for agents

When asked to add a feature, the agent should follow this internal loop:

1. **Verify provider support:** Check the provider schema/docs for the version range in root `versions.tf`.
2. **Check `versions.tf`:** Does this require a provider bump? If yes, modify the root `versions.tf` first.
3. **Variable standard:** Add variables using the description / type / default order. Ensure descriptions match the upstream provider docs.
4. **Docs and tests:** Apply the required commands and verification steps from **`CONTRIBUTING.md`**.
5. **Security:** Follow **Security** above (canonical rules in `.cursor/rules` first, then the agent-oriented bullets).

## Testing expectations

New features should include a new `.tftest.hcl` file or an update to an existing one when module behavior changes.

Use mocks for AWS and RHCS resources to verify logic without requiring live credentials.

For exact commands and pass/fail criteria, follow **`CONTRIBUTING.md`**.
