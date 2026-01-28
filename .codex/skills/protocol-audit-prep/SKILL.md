---
name: protocol-audit-prep
description: Prepare auditor-facing evidence bundles and AUDIT.md for protocol vaults without changing code. Use when an audit is upcoming and you need structured context, invariants, and test coverage summaries.
---

# Skill: protocol-audit-prep

## Purpose

Prepare a protocol vault for third-party audit by assembling a
**complete, auditor-facing evidence bundle** that explains:
- what the system does
- what assumptions it relies on
- what invariants must hold
- what risks are known and accepted
- how correctness is enforced by tests

This skill does not change code. It makes the system legible to auditors.

## When to Invoke

- An audit engagement is upcoming or in progress
- External reviewers need structured context
- Before formal audit kickoff
- After documentation and tests are complete

## Inputs Required

- Implemented contracts
- Existing NatSpec documentation
- Protocol README and INTEGRATION.md
- Threat model (if available)
- Derived invariants
- Test coverage summary (unit)
- External security references may be used as a completeness and pattern
  cross-check (see `.codex/constraints/security-review.md`)

## Actions

### 1) Compile audit context

Collect and normalize the following:
- audit scope definition (in-scope vs out-of-scope contracts)
- high-level architecture and data flows
- roles and trust assumptions
- upgradeability model and constraints
- external dependencies and integrations
- known risks and intentional trade-offs

All content must reflect **current code behavior**.

### 2) Summarize invariants and safety properties

Document:
- accounting invariants (assets, shares, debt, rewards)
- access-control invariants
- safety properties enforced by design or tests
- where each invariant is enforced:
  - code
  - unit tests

### 3) Summarize test coverage

Produce a clear summary of:
- unit test coverage by scenario

Call out:
- untested or partially tested areas
- known limitations of the test suite

### 4) Generate auditor-facing documentation

Generate an `AUDIT.md` at:

`src/adapters/<category>/<protocol>/AUDIT.md`

This file must be written **for auditors** and include:
- audit scope and system overview
- architecture diagram description (textual)
- trust and threat assumptions
- invariant list with rationale
- test coverage summary
- known risks, limitations, and accepted trade-offs
- links or pointers to relevant contracts, tests, and docs

The tone must be factual and explicit, not defensive or promotional.

### 5) Identify gaps and readiness issues

Explicitly list:
- missing documentation
- unclear assumptions
- weak or missing invariants
- areas where tests should be strengthened before audit

Do not silently omit gaps.

## Constraints and Safety Rules

- Must not modify Solidity code
- Must not invent guarantees or properties
- Must not contradict implemented behavior
- Must not hide or downplay known risks
- Must comply with all rules in `.codex/constraints/security-review.md`
- Documentation must be accurate as of the current commit

If behavior is unclear or risky, it must be documented explicitly.

## Outputs

- `AUDIT.md` for the protocol vault
- Markdown audit preparation bundle summarizing:
  - scope
  - assumptions
  - invariants
  - risks
  - test coverage
  - readiness gaps

## Verification

- All referenced contracts and tests exist
- Documentation matches actual code behavior
- Assumptions and risks are explicit
- Auditors can understand the system without additional context

## Handoff

After successful execution, this skill may be followed by:
- `security-review` for an independent finding-style review
- external audit kickoff using the generated materials

## Example Prompts

- “Use protocol-audit-prep to generate AUDIT.md and prepare the
  Morpho vault system for an external audit.”
- “Assemble an audit-ready bundle for this protocol vault,
  highlighting invariants and known risks.”
