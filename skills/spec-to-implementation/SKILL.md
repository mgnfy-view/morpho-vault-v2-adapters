# Skill: spec-to-implementation

## Purpose

Implement Solidity function(s) or modules directly from an inline
comment-level specification,
following a deliberate implementation-first workflow.

This skill exists to translate intent into code while:
- completing and updating NatSpec created during scaffolding
- preserving correctness
- surfacing assumptions explicitly
- remaining audit-ready

Completeness and optimization are secondary to faithful implementation.

## When to Invoke

- A contract has already been scaffolded
- Inline comments describe intended behavior or invariants
- The logic is conceptually understood but not yet encoded in Solidity
- You want a stable implementation baseline before:
  - test generation
  - refactoring
  - gas optimization

## Inputs Required

- Target contract(s) and function signature(s)
- Inline comment-level spec (bullet points preferred)
- Explicit assumptions about:
  - token behavior (ERC20 quirks, hooks, rebasing)
  - oracle usage (freshness, decimals, trust)
  - access control (roles, admin powers)
  - upgradeability (storage layout constraints, ABI stability)

If assumptions are missing or ambiguous, they must be surfaced explicitly.

## Actions

### 1) Translate the spec into implementation intent

- Restate the inline spec in concrete implementation terms:
  - inputs to outputs
  - state before to state after
- Identify:
  - state transitions
  - external calls and dependencies
  - accounting paths and units (assets, shares, debt, rewards)

### 2) Design the control flow explicitly

Before writing code, reason about:
- call ordering (effects before interactions)
- failure modes and revert conditions
- edge cases (zero values, rounding, max or min bounds)

### 3) Implement the Solidity code

Implementation must:
- follow the specification literally
- use clear, explicit control flow
- reuse shared logic from `src/utils` or protocol-specific `lib/` folders where applicable
- isolate accounting logic into readable, reviewable sections
- prefer readability and correctness over micro-optimizations

### 4) Update and finalize NatSpec documentation

NatSpec added during the scaffolding phase must now be completed and corrected.

For every public or external function:
- replace placeholder NatSpec with accurate descriptions
- document:
  - behavior
  - parameters and return values
  - state changes
  - external calls
  - assumptions and trust boundaries
  - known edge cases and risks

NatSpec must explain why decisions were made, not restate the code.

### 5) Remove inline comment-level specification

After implementation is completed and **explicitly confirmed by the user or Codex developer**:

- Delete all inline comment-level specification used only for guidance
- Do not remove:
  - finalized NatSpec
  - explanatory comments that justify design decisions
- Inline specs must not persist once behavior is locked

> Rationale: inline specs are transitional scaffolding. Persisting them risks
> divergence between comments and behavior and confuses audits.

## Constraints and Safety Rules

- Must not write or modify tests  
  (tests are generated via `implementation-to-tests`)
- Must comply with all rules in `constraints/solidity-style.md`
- State updates must precede external calls
- Custom errors must be used instead of revert strings
- ERC20 non-compliance must be assumed
- Accounting logic must be:
  - clearly isolated
  - commented
  - unit-consistent
- No gas optimizations that obscure correctness or intent
- No changes to unrelated code or public APIs unless explicitly requested

## Outputs

- Modified Solidity source files implementing the specified behavior
- Updated NatSpec documentation reflecting final behavior
- Inline comment-level specs removed after confirmation

## Verification

- Code compiles cleanly with `forge build`
- Formatting passes `forge fmt`
- NatSpec accurately reflects implemented behavior
- Inline comment-level specs are removed after confirmation
- Any ambiguity or missing spec detail is explicitly documented for follow-up

## Handoff

After successful execution, this skill should be followed by:
- `implementation-to-tests` to lock behavior

## Example Prompts

- “Use spec-to-implementation to implement `claimRewards(address to)`,
  update NatSpec, then remove the inline spec once confirmed.”
- “Translate this ERC4626 withdrawal spec into an implementation and
  remove inline comments after final review.”
