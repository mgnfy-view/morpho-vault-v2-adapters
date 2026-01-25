# Testing Conventions (Foundry)

This document defines **mandatory** testing conventions for Solidity code in this repository.

The goals are:
- unit tests that lock **observable behavior** (not implementation details)
- scenario-first organization that scales with DeFi complexity
- deterministic, reproducible results suitable for audits

These rules apply to all tests unless explicitly overridden by a
protocol-specific README.

---

## 1) Test Types (Definitions)

### Unit tests (only)
- Fast, isolated tests for a single behavior.
- No real integrations.
- Use mocks/stubs only.
- Cover happy paths, failure cases, and edge cases.
### Non-unit tests
- Integration, fuzz, and invariant tests are **out of scope** for this repo.

---

## 2) Required Directory Layout

All tests live under the Foundry workspace (`test/`).

### Per-protocol test layout (current repo)

```txt
test/lending/<protocol>/
├── Allocate.t.sol
├── Deallocate.t.sol
├── Factory.t.sol
├── Miscellaneous.t.sol
└── utils/
   └── <Protocol>AdapterBaseTest.sol
```

### Hard rules

- Keep tests grouped by protocol under `test/lending/<protocol>/`.
- Shared helpers belong in `test/**/utils/` and should be protocol-scoped.
- Use mocks only when integration behavior cannot be simulated otherwise.

## 3) File Naming & Contract Naming

- All test files must end with **`.t.sol`**.
- Test contracts must reflect scenario intent:
  - Preferred: `<Scenario>Test`
  - Alternative allowed: `<Scenario>_Test`
- One scenario per test file unless explicitly justified.

## 4) Scenario-Based Testing (Mandatory)

Do **not** create tests per contract by default.  
Tests must be organized around **behaviors and scenarios**.

Examples:
- `Initialization.t.sol` — deployment paths, role config, initial invariants
- `Deposits.t.sol` — deposit/mint flows and edge cases
- `Withdrawals.t.sol` — withdraw/redeem flows
- `AccountingFuzz.t.sol` — rounding, fee math, share conversions
- `Integrations.t.sol` — adapter or protocol boundary behavior

> Exception: if a protocol is extremely small, multiple scenarios may live in one file.

## 5) Assertions & What to Test

### Prefer observable behavior (required)

Tests must assert externally visible outcomes:
- state deltas
- balances (assets / shares / debt / rewards)
- emitted events (topics + data)
- revert selectors / custom errors

### Avoid implementation coupling (required)

- Do not assert internal calls, internal ordering, or private storage variables.
- Do not mirror implementation logic in tests.

### Negative tests are mandatory

Always include negative tests for:
- unauthorized access
- invalid inputs (zero address, zero amount, bounds)
- rounding edge cases
- reentrancy attempts where external calls exist

## 6) Custom Errors & Reverts

- Prefer asserting **custom error selectors**.
- Validate error parameters when meaningful (especially accounting-related errors).

## 7) Test Scope Enforcement

### When stateless fuzzing is mandatory

Any change touching arithmetic or accounting logic must include stateless fuzz tests for:
- rounding boundaries
- fee calculations
- share ↔ asset conversions
- bounds and revert properties

### Rules

- Each fuzz test must be **single-call and stateless**.
- No state carried across fuzz cases.
- Document the property being tested in a one-line comment.

No integration, fuzz, or invariant tests should be introduced. If a change
appears to require broader coverage, discuss it in the PR first.

### When invariants are mandatory

Invariant tests are required when:
- multiple actions interact over time
- accounting safety depends on action ordering
- rewards, debt, or collateral evolve across steps

### Invariant harness structure

- `Handlers.t.sol` defines allowed state-mutating actions.
- `Selectors.t.sol` restricts callable selectors (if used).
- `Invariants.t.sol` asserts invariants after sequences.

### Invariant rules

- Invariants must be:
  - **minimal**
  - **loud**
  - **stable**
- Each invariant must include a one-line rationale.
- Any tolerance (e.g., rounding) must be explicitly justified.

## 8) Integration Tests

- Validate behavior at protocol boundaries.
- Must cover:
  - token quirks
  - oracle assumptions
  - external call ordering
- Do not rely on mainnet state unless explicitly designated as a fork test.

## 10) Test Quality Bar (Definition of Done)

A change is test-complete only if:
- unit tests cover new/changed behavior
- stateless fuzz tests cover arithmetic/accounting changes
- invariant tests exist for stateful accounting safety (if applicable)
- no test-type base contracts are cross-used
- tests are deterministic and non-flaky

## 9) Running Tests

Run from the repository root:

Minimum (always):
- `forge fmt`
- `forge build`
- `forge test`

Targeted runs (optional):
- Protocol: `forge test --match-path test/lending/<protocol>/*.t.sol`
- Utils: `forge test --match-path test/**/utils/*.t.sol`

Fuzzing/invariants are not used in this repo.
