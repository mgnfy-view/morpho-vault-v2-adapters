# Smart Contract Dev & Audit Skill Pack

Production-grade skills for Solidity/DeFi engineering, optimized for an
**implementation-first workflow** with strong post-implementation testing,
invariant-driven correctness, upgrade-safe refactors, and audit preparation.

## Intended Audience

- Solidity/DeFi engineers shipping production contracts and writing integrations
- Security reviewers performing structured assessments
- Teams using Foundry as their primary framework

## Out of Scope

- Tokenomics design or economic policy decisions
- Off-chain services (frontend, backend, indexers, keepers)
- Claims of guaranteed security (skills accelerate work; they do not replace audits)

## Supported Stack

- Solidity: >=0.8.x
- Frameworks: Foundry
- EVM chains: Ethereum + compatible L2s
- Optional tools: Slither, Mythril, Echidna, Aderyn

## Global Safety Constraints (Apply to ALL skills)

1. **State updates must precede external calls**  
   (exceptions require explicit justification and tests)
2. **All behavior changes require tests**  
   (tests may be added after implementation, but must validate observable behavior)
3. **ERC20 non-compliance must be assumed**  
   (fee-on-transfer, rebasing, missing return values, ERC777 hooks)
4. **Accounting changes require unit tests that cover rounding and bounds**  
   (balances, shares, debt, rewards, interest, fees)
5. **Upgradeable contracts must preserve storage layout and ABI**  
   unless explicitly opted-in and documented

## Skill Index (Planned)

### Core Development

- **scaffold-contract** — New module skeleton (contract, tests, NatSpec docs)
- **spec-to-implementation** — Implement function(s) from a global spec and inline comment spec

### Correctness & Security

- **defi-threat-model** — Threat model (actors, trust assumptions, attacker goals)
- **implementation-to-tests** — Generate unit tests from implemented code
- **security-review** — Structured security review with findings and remediation guidance
- **protocol-audit-prep** — Audit readiness checklist and evidence bundle

### Maintenance & Optimization

- **safe-refactor** — Refactor non-upgradeable contracts without behavior changes
- **gas-optimization-review** — Safe gas optimizations with explicit risk flags
- **docs-generator** — Protocol and contract documentation from code and assumptions

## Invocation Examples

Explicit:
- "Use spec-to-implementation for this ERC4626 vault specification."
- "Run security-review on src/Vault.sol and summarize findings."

Implicit:
- "Here is my staking design; help me implement it safely."
- "We changed withdrawal accounting; what invariants should we add?"

## Definition of Done (Quality Bar)

Work is considered complete only if:

- NatSpec documentation is added or updated for all modified public interfaces
- Implementation aligns with the stated global and inline specifications
- Tests pass:
  - Unit tests (mandatory)
- No global safety constraints are violated  
  (or violations are explicitly documented and justified)
- A brief changelog summary is produced:
  - what changed
  - why it changed
  - risk assessment

## Skills Layout

- .codex/skills/<skill-name>/SKILL.md
- .codex/skills/<skill-name>/prompt.txt (optional canonical prompt)
- .codex/constraints/*.md
- .codex/templates/*
- .codex/examples/*
