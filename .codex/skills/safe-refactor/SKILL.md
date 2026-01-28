---
name: safe-refactor
description: Refactor non-upgradeable Solidity contracts for clarity and maintainability without changing observable behavior, interfaces, or tests. Use when behavior is locked and you need structural cleanup.
---

# Skill: safe-refactor

## Purpose

Refactor **non-upgradeable** Solidity contracts to improve clarity,
maintainability, and internal structure **without changing any observable behavior**.

This skill is purely structural. It must not alter semantics, interfaces,
or externally visible effects.

## When to Invoke

- Code cleanup
- Duplication removal
- Readability or maintainability improvements
- Preparing code for audit or review
- Simplifying logic after behavior has been locked by tests

## Inputs Required

- Target Solidity contracts
- Existing test suite covering the affected behavior

## Actions

Permitted actions include:
- Extracting internal helper functions
- Renaming variables and internal functions for clarity
- Simplifying control flow without semantic change
- Removing dead code or unreachable branches
- Reorganizing code to follow repository layout conventions

Refactors must preserve:
- execution order
- revert behavior
- event emission
- state transitions
- external call behavior

## Constraints and Safety Rules

- Must not change observable behavior
- Must not change public or external APIs
- Must not change custom errors or error parameters
- Must not introduce or remove external calls
- Must not introduce new dependencies
- Must not modify storage semantics
- Must comply with all rules in `.codex/constraints/solidity-style.md`
- Tests must pass **unchanged**
- No new tests may be added as justification for behavior changes

If a refactor would benefit from behavior changes, use a different skill.

## Outputs

- Refactored Solidity source files with identical behavior

## Verification

- `forge build` passes
- `forge test` passes with no test changes
- Behavior is identical under existing unit tests

## Handoff

If refactoring reveals unclear or risky logic, consider:
- `security-review` for deeper analysis
- `docs-generator` to improve documentation without changing code

## Example Prompts

- “Use safe-refactor to simplify withdraw logic without changing behavior.”
- “Refactor internal helpers in `VaultMath` for readability while preserving semantics.”
