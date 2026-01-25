# Security Review — External References and Checklists

This document lists **external security references** used as
**completeness and pattern cross-checks** during:

- security-review
- protocol-audit-prep
- PR security review

These resources:
- do not replace protocol-specific reasoning
- do not imply safety or completeness
- must be applied critically and selectively

They are supporting inputs to:
- threat modeling
- invariant derivation
- manual review
- audit preparation

## Cyfrin Audit Checklist

- Source (JSON): https://github.com/Cyfrin/audit-checklist/blob/main/checklist.json

The Cyfrin checklist provides a structured list of common smart-contract
security categories.

Use this checklist to:
- ensure common vulnerability classes were considered
- catch missing review dimensions
- validate review completeness at a high level

Do not:
- treat checklist coverage as proof of security
- assume unchecked items imply irrelevance
- rely on the checklist without protocol-specific analysis

Checklist items that are not applicable should be explicitly marked
as N/A with a one-line rationale in review notes.

## Solodit — Historical Audit Findings

- Website: https://solodit.xyz/

Solodit aggregates **real-world audit findings** across many protocols
and auditors.

Use Solodit to:
- identify recurring vulnerability patterns
- search for historical failures in similar designs
- review findings related to specific integrations or mechanisms
- inspire targeted threat modeling and invariant design

Typical searches include:
- protocol category (vaults, lending, staking)
- integration targets (oracles, lending markets)
- mechanisms (ERC4626, upgradeable proxies, reward accounting)

Do not:
- copy findings blindly
- assume absence of past findings implies safety
- treat Solodit as exhaustive or authoritative

Historical findings are context, not guarantees.

## How These References Should Be Used

- Use **after** threat modeling and invariant derivation, not before.
- Prefer protocol-specific reasoning over generic pattern matching.
- When a checklist item or historical pattern is considered:
- record whether it applies
- document why it does or does not apply
- Use findings to:
- refine invariants
- strengthen tests
- focus manual review

Security confidence must come from:
- clear assumptions
- explicit invariants
- tested behavior
- documented risks

External references are aids, not substitutes.
