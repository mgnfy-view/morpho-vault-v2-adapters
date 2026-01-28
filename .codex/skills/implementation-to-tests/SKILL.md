---
name: implementation-to-tests
description: Generate scenario-based Foundry unit tests from existing Solidity implementations to lock observable behavior before refactors, optimizations, upgrades, or audits. Use when implementations exist but tests are missing or insufficient.
---

# Skill: implementation-to-tests

## Purpose

Generate **scenario-based unit tests** from existing Solidity implementations to
lock **observable behavior** before refactoring, optimization, or audit.

This skill converts implemented code into:
- unit guarantees

in strict compliance with `.codex/constraints/testing.md`.

## When to Invoke

- Implementation is complete or partially complete
- Unit tests are missing, incomplete, or insufficiently expressive
- Behavior must be locked before:
  - refactoring
  - gas optimization
  - upgrade-safe changes
  - security review or audit prep

## Inputs Required

- Implemented Solidity contracts
- Target functions or behavior changes
- Protocol context (vault type, accounting model, integrations)
- Any documented assumptions or specs

## Actions

### 1) Identify observable behavior

From the implementation, identify:
- state transitions
- balance/share/debt changes
- emitted events
- revert conditions and custom errors
- external call effects (if integrations exist)

### 2) Use unit tests only

Follow `.codex/constraints/testing.md` for directory layout and unit-test rules.

### 3) Generate scenario-based test files

- Do **not** generate tests per contract.
- Generate tests per **behavioral scenario**, e.g.:
  - `Allocate.t.sol`
  - `Deallocate.t.sol`
  - `Factory.t.sol`
  - `Miscellaneous.t.sol`

Each test file must:
- live under `test/lending/<protocol>/`
- assert externally observable behavior
- include negative cases where applicable

### 4) Required coverage rules

The skill must ensure unit tests cover:
- happy path
- failure cases
- access control enforcement
- rounding and bounds for accounting changes

## Constraints/Safety Rules

- Tests must assert **external behavior only**
- Tests must not rely on:
  - internal calls
  - internal storage layout
  - implementation ordering
- No production code changes

## Outputs

- Foundry test files placed under `test/lending/<protocol>/`
- Shared helpers placed under `test/**/utils/` when needed
- Clear scenario-based file naming

## Verification

- `forge test` passes
- Tests fail on meaningful behavior changes
- Tests comply with `.codex/constraints/testing.md`

## Example Prompts

- “Use implementation-to-tests to generate **unit tests**
  for Adapter.allocate and Adapter.deallocate.”
- “Lock adapter behavior with unit tests before refactoring.”
