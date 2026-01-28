---
name: defi-threat-model
description: Produce structured DeFi threat models covering actors, trust assumptions, attacker goals, and critical attack surfaces. Use during design or before audits and invariant work for protocols and integrations.
---

# Skill: defi-threat-model

## Purpose

Produce a **structured DeFi threat model** describing:
- actors and their capabilities
- trust assumptions and dependencies
- attacker goals and incentives
- critical attack surfaces and failure modes

This skill is **purely analytical**. It does not modify code or tests.
Its output is used to guide implementation, review, and audit preparation.

## When to Invoke

- Designing a new protocol or module
- Before implementing high-risk or novel logic
- Before writing invariants
- Prior to security review or audit preparation
- When integrating with new external protocols or oracles

## Inputs Required

- Protocol or module description
- Target contracts and key functions
- Known integrations (oracles, lending markets, bridges, adapters)
- Privileged roles and admin capabilities
- Upgradeability model (if applicable)

If information is missing, uncertainty must be stated explicitly.

## Actions

### 1) Identify actors and capabilities

Enumerate all relevant actors, including but not limited to:
- end users
- privileged roles (admins, guardians, pausers)
- keepers or off-chain actors
- external protocols and contracts
- malicious users and attackers
- compromised or malicious admins (worst case)

For each actor, describe:
- what actions they can take
- what assumptions are made about their behavior

### 2) Enumerate trust assumptions

Explicitly document assumptions about:
- oracle correctness, freshness, and manipulation resistance
- admin key behavior and compromise scenarios
- upgrade mechanisms and who controls them
- guarantees or non-guarantees from external protocols
- token behavior (ERC20 quirks, hooks, rebasing)

Assumptions must be stated as assumptions, not guarantees.

### 3) Define attacker goals

For each plausible attacker, describe goals such as:
- direct fund extraction
- indirect fund extraction via accounting manipulation
- value extraction via MEV or timing
- griefing or denial of service
- privilege escalation or governance abuse

Map goals to the actors that could realistically pursue them.

### 4) Identify critical attack surfaces

Highlight high-risk areas, including:
- public or external functions that move value
- privileged or admin-only paths
- upgrade and initialization logic
- external calls and integrations
- oracle-dependent or price-sensitive logic
- state transitions that depend on sequencing or timing

Call out areas where multiple assumptions compound risk.

### 5) Summarize threat coverage gaps

Explicitly identify:
- threats that are not mitigated by design
- threats that rely on off-chain or social guarantees
- areas requiring invariants or additional unit testing
- areas needing deeper manual review

Do not claim completeness.

## Constraints and Safety Rules

- Must not modify code or tests
- Must not claim completeness or full coverage
- Must not assume honest users, honest tokens, or benign environments
- Must explicitly state uncertainty and unknowns
- Must avoid normative language (“safe”, “secure”, “guaranteed”)

## Outputs

- Markdown threat model documenting:
  - actors and capabilities
  - trust assumptions
  - attacker goals
  - critical attack surfaces
  - known gaps and risks

The output should be suitable for inclusion in:
- `security-review`
- `protocol-audit-prep`
- auditor-facing documentation

## Handoff

After successful execution, this skill should be followed by:
- `security-review` to identify concrete findings
- `protocol-audit-prep` to package the analysis for auditors

## Example Prompts

- “Use defi-threat-model to analyze the Vault and RewardsManager
  integrating with Morpho Blue.”
- “Produce a threat model for this upgradeable vault,
  focusing on oracle assumptions and admin risks.”
