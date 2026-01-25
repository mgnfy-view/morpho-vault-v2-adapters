# Skill: docs-generator

## Purpose

Improve, complete, and normalize **NatSpec documentation** based on the
final implemented Solidity code, and generate **protocol-level integration
documentation** for external consumers.

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

### 2) Generate protocol README

Generate a `README.md` at:

`src/adapters/<category>/<protocol>/README.md`

This file must include:
- high-level overview of the protocol vault
- supported actions and user flows
- role and access-control summary
- upgradeability model (if applicable)
- high-level risks and assumptions
- pointers to relevant contracts and libraries

The README is intended for:
- contributors
- auditors
- internal reviewers

### 3) Generate integration documentation

Generate an `INTEGRATION.md` at:

`src/adapters/<category>/<protocol>/INTEGRATION.md`

This file must be written for **external integrators** and include:
- how to interact with the vault correctly
- required call ordering and expectations
- token behavior assumptions (ERC20 quirks)
- approval and allowance requirements
- rounding and precision notes
- events integrators should rely on
- common integration footguns and how to avoid them

No implementation details that are irrelevant to integrators should be included.

## Constraints and Safety Rules

- Must not invent guarantees or properties
- Must not contradict implemented behavior
- Must not describe behavior not present in code
- Must not modify business logic
- Must comply with all rules in `constraints/solidity-style.md`
- Documentation must reflect the current codebase exactly

If code behavior is unclear or risky, it must be documented explicitly.

## Outputs

- Improved and completed NatSpec in Solidity contracts
- `README.md` for the protocol vault
- `INTEGRATION.md` for external integrators

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
