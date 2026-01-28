---
name: docs-generator
description: Improve NatSpec documentation and generate adapter AUDIT.md files based on existing Solidity implementations. Use after implementation to document behavior for audits and releases.
---

# Skill: docs-generator

## Purpose

Improve, complete, and normalize **NatSpec documentation** based on the
final implemented Solidity code, and generate **AUDIT.md** for adapters.

This skill does not invent behavior. It documents what already exists.

## When to Invoke

- After `spec-to-implementation` is complete
- Before audits
- Before releases
- When onboarding new contributors or integrators
- When NatSpec exists but is incomplete, inconsistent, or unclear

## Inputs Required

- Implemented Solidity contracts
- Existing NatSpec documentation
- Global specs and stated assumptions (if any)
- Protocol context (vault type, integrations, roles)

## Actions

### 1) Review and improve NatSpec

For all public and external contracts, functions, and events:

- Improve clarity and consistency of existing NatSpec
- Fill in missing NatSpec where required
- Ensure NatSpec accurately reflects:
  - observable behavior
  - state changes
  - external calls
  - assumptions and trust boundaries
  - edge cases and known risks

NatSpec must:
- explain **why**, not restate the code
- align exactly with implemented behavior
- avoid aspirational or future-looking statements

No placeholder or outdated NatSpec may remain after this step.

### 2) Generate audit documentation

Generate an `AUDIT.md` at:

`src/adapters/<category>/<protocol>/AUDIT.md`

This file must be written **for auditors** and include:
- scope and system overview
- architecture overview (textual)
- trust and threat assumptions
- invariant list with rationale
- unit test coverage summary
- known risks, limitations, and accepted trade-offs
- links or pointers to relevant contracts, tests, and docs

## Constraints and Safety Rules

- Must not invent guarantees or properties
- Must not contradict implemented behavior
- Must not describe behavior not present in code
- Must not modify business logic
- Must comply with all rules in `.codex/constraints/solidity-style.md`
- Documentation must reflect the current codebase exactly

If code behavior is unclear or risky, it must be documented explicitly.

## Outputs

- Improved and completed NatSpec in Solidity contracts
- `AUDIT.md` for the adapter

## Verification

- NatSpec aligns with actual code behavior
- No placeholder or outdated documentation remains
- Generated markdown files are accurate, readable, and consistent
- Documentation highlights assumptions and risks clearly

## Handoff

After successful execution, this skill may be followed by:
- `security-review` to validate documented assumptions
- `protocol-audit-prep` to package documentation for auditors

## Example Prompts

- “Use docs-generator to improve NatSpec and generate README.md and
  INTEGRATION.md for the Morpho vault.”
- “Finalize documentation for this protocol vault, focusing on
  integrator-facing risks and assumptions.”
