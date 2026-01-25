# Skill: gas-optimization-review

## Purpose

Identify **safe and justified gas optimizations** in Solidity code
while preserving:
- correctness
- accounting integrity
- readability
- auditability

This skill proposes optimizations. It does not apply them unless explicitly requested.

## When to Invoke

- After correctness is established
- After tests and invariants are in place
- During performance tuning or cost-reduction phases
- Before deployment or audit finalization

Gas optimization must never precede correctness.

## Inputs Required

- Target Solidity contracts
- Critical execution paths (hot paths)
- Context on expected usage patterns (optional)

## Actions

### 1) Identify gas hotspots

Analyze:
- frequently called functions
- loops and repeated storage access
- redundant computations
- unnecessary external calls
- storage reads and writes

Focus on **measurable impact**, not theoretical savings.

### 2) Propose optimizations

For each proposed optimization:
- describe the change clearly
- explain the gas-saving mechanism
- estimate relative impact (low/medium/high)
- specify whether it is:
  - purely mechanical
  - logic-adjacent
  - logic-sensitive

### 3) Flag risk and correctness sensitivity

Explicitly flag optimizations that:
- rely on assumptions about token behavior
- change evaluation order
- alter arithmetic or rounding behavior
- depend on compiler or EVM subtleties
- reduce readability or debuggability

Risky optimizations must be clearly labeled and justified.

## Constraints and Safety Rules

- Must not change observable behavior
- Must not change arithmetic semantics or rounding
- Must not weaken safety checks or invariants
- Must not obscure logic for marginal gas gains
- Must not introduce assembly unless explicitly justified
- Must comply with all rules in `constraints/solidity-style.md`

If an optimization risks correctness, it must be presented as optional and high-risk.

## Outputs

- A structured list of gas optimization suggestions, each including:
  - description
  - affected code paths
  - expected gas impact (qualitative)
  - risk level (low/medium/high)
  - rationale and trade-offs

The output must be suitable for review by:
- protocol engineers
- auditors
- reviewers evaluating cost vs risk

## Verification

- Suggested optimizations preserve behavior under existing tests
- Risky suggestions are explicitly marked
- No recommendation contradicts documented assumptions or invariants

## Handoff

After review, optimizations may be applied via:
- `safe-refactor` for non-upgradeable contracts

Any applied optimization must be followed by:
- unchanged test suite passing
- explicit confirmation of no behavior change

## Example Prompts

- “Use gas-optimization-review on `Vault.sol`
  and clearly flag any logic-sensitive suggestions.”
- “Identify low-risk gas optimizations for the deposit path
  without reducing readability.”
