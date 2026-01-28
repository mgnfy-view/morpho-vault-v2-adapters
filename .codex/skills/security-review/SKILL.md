---
name: security-review
description: Perform structured smart-contract security reviews of implemented Solidity code with actionable findings and remediation guidance. Use for security-sensitive changes, audit prep, or final review.
---

# Skill: security-review

## Purpose

Perform a **structured smart-contract security review** of implemented
Solidity code and produce **actionable, evidence-based findings**
with clear remediation guidance.

This skill evaluates *risk*, not just correctness, and does not modify code
unless explicitly requested.

## When to Invoke

- Before merging major or high-risk changes
- During PR review for security-sensitive logic
- After implementation and tests are complete
- Before audit handoff
- After integrating new external protocols or oracles

## Inputs Required

- Target Solidity contracts
- Threat model (if available)
- Derived invariants (if available)
- Known assumptions and constraints
- Test coverage summary (unit)
- External security references may be used as a completeness and pattern
  cross-check (see `.codex/constraints/security-review.md`)


Missing inputs must be explicitly noted as review limitations.

## Actions

### 1) Establish review context

Confirm and document:
- in-scope and out-of-scope contracts
- trust assumptions and roles
- upgradeability model
- external integrations and dependencies

### 2) Review critical risk areas

Systematically review:
- access control and privilege boundaries
- external calls and call ordering
- accounting logic and rounding
- ERC20 non-compliance assumptions
- reentrancy surfaces (direct and indirect)
- oracle usage and price dependencies
- initialization and upgrade paths
- failure modes and revert behavior

### 3) Identify findings

Identify:
- concrete vulnerabilities
- design weaknesses
- invariant violations or missing invariants
- dangerous assumptions
- test coverage gaps with security impact

Do not conflate stylistic issues with security findings.

### 4) Assess severity and likelihood

For each finding, assess:
- **severity** (Critical, High, Medium, Low, Informational)
- **likelihood** given assumptions and attacker capabilities

Severity must be justified by impact, not intuition.

### 5) Propose remediation and prevention

For each finding:
- propose concrete remediation steps
- note trade-offs or design implications
- recommend regression tests or invariants to prevent recurrence

## Constraints and Safety Rules

- Must not claim exploitability without justification
- Must not exaggerate impact or certainty
- Must not provide exploit code for live or real-world protocols
- Must not modify Solidity code unless explicitly requested
- Must state uncertainty and assumptions clearly
- Must comply with all rules in `.codex/constraints/security-review.md`

## Outputs

- Structured findings report with one entry per issue, including:
  - title
  - severity
  - impact
  - likelihood
  - affected contracts and functions
  - rationale
  - recommendation
  - suggested regression test or invariant

The output must be suitable for:
- PR review
- audit preparation
- inclusion in `AUDIT.md`

## Verification

- Findings are traceable to specific code paths
- Severity and likelihood are clearly justified
- No claims exceed available evidence
- Review scope and limitations are explicit

## Handoff

After successful execution, this skill may be followed by:
- `safe-refactor` to address findings
- `implementation-to-tests` to add regression coverage
- `protocol-audit-prep` to package findings for auditors

## Example Prompts

- “Run security-review on the Vault and Strategy contracts
  and summarize high-risk findings with remediation guidance.”
- “Review this upgradeable vault focusing on external calls,
  oracle assumptions, and upgrade safety.”
