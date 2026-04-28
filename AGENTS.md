# AGENTS.md

## Project Scope

- Repository type: Terraform primitive module
- Module purpose: manage a single resource type.
- Keep changes aligned with primitive module standards used across this organization.

## Primary Standards Sources

- Canonical primitive guidance: `.github/agents/primitive-module-creator.agent.md`.
- Architecture-level guidance (for composition patterns and testing depth references): `.github/agents/reference-architecture-creator.agent.md`.
- Module behavior and examples: `README.md`, `examples/complete/*`, and tests under `tests/`.

In case of conflicting guidance, prioritize user instructions. When deviating from this file or the referenced agent guides, inform the user and reference the superseded guidance for context.

## Repository Conventions

- Keep this module focused on a single resource type; do not expand into unrelated resource orchestration.
- Prefer explicit variable validation and clear error messages in `variables.tf`.
- Keep output names and descriptions precise and non-ambiguous.
- Keep README usage/examples aligned with current module inputs and outputs.

## Required Workflow For Code Changes

1. Read the files you will edit and nearby tests/examples.
2. Implement the smallest safe change; avoid unrelated refactors.
3. Update and run relevant tests/checks against the change to validate behavior; if blocked, state what could not run.
4. Update documentation as to the behavior and test change(s).
5. Stage all relevant files and execute `pre-commit run`; resolve all pre-commit issues.

## Validation And Test Commands

- Dependency/bootstrap: `make configure-dependencies` and `make configure-git-hooks`
- Main test target: `make test`
- Terraform tests only: `make tfmodule/test/terraform`
- Go tests only: `make tfmodule/test/go`

If a full run cannot be completed, state what was run and what remains.

## Testing Expectations

- Prefer assertions with expected values over generic non-empty checks where expected values are known.
- For deployed behavior, verify meaningful remote state, not only Terraform outputs.
- Keep test intent clear:
  - Validation/plan tests under `tests/terraform/`.
  - Post-deploy integration tests under `tests/post_deploy_functional/`.
- When introducing new behavior, add or update tests in the appropriate suite.

## Example And Documentation Expectations

- Keep `examples/complete/` functional and representative of recommended usage.
- Ensure example README and root README remain consistent with actual example code and module variables.
- Keep terraform-docs generated sections current when inputs/outputs change.

## Security And Safety Expectations

- Prefer secure defaults and least-privilege patterns where applicable.
- Do not include secrets, keys, or account-specific sensitive data in committed code, docs, or tests.
- Treat policy-related changes as high-impact and validate carefully.

## Pull Request Readiness Checklist

- [ ] Changes are scoped to the requested behavior.
- [ ] Tests were updated (or a rationale is provided for no test change).
- [ ] Relevant `make` targets were run, or limitations were documented.
- [ ] README/examples were updated if interface or behavior changed.
- [ ] No unrelated file churn.
