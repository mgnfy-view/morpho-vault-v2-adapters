# Solidity Coding Style & Conventions

This document defines **mandatory** coding style and conventions for all Solidity
**contracts, libraries, interfaces, tests, and scripts** in this repository.

These rules optimize for:

* auditability and review speed
* consistent external integration surfaces (UI/indexers/other protocols)
* Foundry compatibility
* predictable agent behavior (Codex)

If a rule here conflicts with personal preference, this document wins.

## 1) Compatibility & Tooling

* Solidity version: **`>=0.8.x`** and compatible with Foundry.
* Formatting is enforced via **`forge fmt`**.
* Import sorting must be enabled (see `foundry.toml`, `sort_imports = true`).
* Indentation: **4 spaces**.
* Max line length: **120** (see `foundry.toml`).

### Required pre-commit checks

Before committing/pushing changes that touch Solidity:

* `make format` (or `forge fmt`)
* `make fbuild` (or `forge build`)
* `make ftest` (or `forge test`)

## 2) File Naming & Placement

* **Contracts / libraries**: `PascalCase.sol`
* **Tests**: suffix file names with **`.t.sol`**
* **Scripts**: suffix file names with **`.s.sol`**
* **One interface per file** (mandatory).
* **No relative import paths**. Use repository-root absolute-style imports:

  * ✅ `@src/adapterBase/...`
  * ✅ `@src/adapters/...`
  * ❌ `../adapters/...`
  * ❌ `./Foo.sol`

> Rationale: absolute imports and one-interface-per-file prevent import drift,
> simplify search/navigation, and reduce integrator mistakes.

## 3) Import Structure

Group imports into **exactly four sections** in this order, separated by blank lines:

1. External dependency **interfaces**
2. External dependency **contracts**
3. Local **interfaces**
4. Local **contracts / libraries**

Example:

```solidity
import {IERC20} from "openzeppelin-contracts/interfaces/IERC20.sol";

import {ERC20} from "openzeppelin-contracts/token/ERC20/ERC20.sol";

import {IVault} from "src/vaults/interfaces/IVault.sol";

import {VaultMath} from "src/vaults/libraries/VaultMath.sol";
```

## 4) Reuse of Common Libraries

- Common logic **must be reused** from existing libraries under
  `src/utils/` or protocol-specific `lib/` folders whenever applicable.
- Do **not** duplicate logic across contracts if:
  - a shared, well-tested library already exists, or
  - the logic can reasonably be extracted into a reusable library.
- New reusable logic should be added to `src/utils/` or a protocol `lib/`
  folder rather than embedded directly into contracts.

### Library design rules
- Library functions should be:
  - `pure` or `view` where possible
  - generic and reusable across modules
  - free of protocol-specific state
- Library logic must be covered by unit tests (directly or indirectly).

> Rationale: centralized libraries reduce duplicated logic, improve auditability,
> ensure consistent behavior across modules, and make future upgrades safer.

## 5) Naming Conventions

### Types

* Contracts, libraries, structs, enums: **`PascalCase`**
* Interfaces: **`I<PascalCase>`** (e.g., `IVault`)
* Test contracts: **`<Scenario>Test`** or `<Scenario>_Test` (choose one and stay consistent)

### Functions, variables, parameters

* Functions and variables: **`camelCase`**
* **Parameters** (functions/events/errors): prefix with `_` and use `camelCase`
* **Return values**: do not use named return parameters; return explicit locals.

  * e.g., `deposit(uint256 _assets, address _receiver)`
  * e.g., `event Deposited(address indexed _caller, address indexed _receiver, uint256 _assets);`

### Storage + constants

* Constants: **`SCREAMING_SNAKE_CASE`**
* Immutables: prefix with **`i_`**
* State variables: prefix with **`s_`**

### Errors

Use the format **`Module__Reason`**:

* `SanityChecks__AddressZero()`
* `Vault__InsufficientAssets(uint256 _requested, uint256 _available)`

> Rule: error names must clearly identify the module and the condition.

## 6) Interfaces (External Integration Surface)

Interfaces in this repo are treated as the **integration contract** for:

* UI/frontends
* off-chain indexers
* external protocol integrators

### Interface requirements (mandatory)

* Interfaces must declare:

  * **structs**
  * **enums**
  * **events**
  * **errors**
  * **all external/public function signatures**
  * **all explicit getter function signatures** (see section 7)
* A single interface file must declare **exactly one interface**.
* Group function signatures logically (e.g., configuration, user actions, views).

### Documentation in interfaces

* **Add NatSpec documentation to interface enums, structs, events, and errors.**
* **Struct fields must each be documented with NatSpec.**
* Interface functions **must** include NatSpec, consistent with repository guidelines.
* Documentation belongs in both interfaces (signatures and meanings) and implementations (behavioral details).

> Rationale: interfaces are for stable signatures; implementations hold behavior notes,
> assumptions, and edge cases, while interface types/events/errors still need clear meaning.

## 7) Documentation & NatSpec

### Where documentation is required

Always use `///` NatSpec comments for:

* public/external contracts
* public/external functions
* events

### What NatSpec must include

For public/external functions:

* purpose
* parameter meaning
* side effects (state changes, external calls)
* assumptions (token behavior, oracle assumptions, admin trust)
* notable edge cases (rounding, fee paths)

### State documentation

* **State variables, constants, and immutables must include NatSpec.**
* **Constructors must include NatSpec.**
* **Each core contract must include `@title`, `@author`, `@notice`, and `@dev`.**
* **Use trailing periods in `@title` and `@author` tags.**
* **Internal functions must include NatSpec.**
* **Use `@return` NatSpec for any function that returns a value.**

### Avoid

* Restating obvious code
* “TODO” without context

## 8) Storage Visibility & Getters

### Storage rule

* **All state variables must be `internal`**.
* **No public state variables**.

### Getter rule

* Every internal state variable that represents meaningful state must have an
  explicit getter function (external/public view).
* Getter functions must be declared in the corresponding interface.

Example:

```solidity
uint256 internal s_totalAssets;

function totalAssets() external view returns (uint256) {
    return s_totalAssets;
}
```

> Rationale: explicit getters provide stable names and allow future internal refactors
> without breaking integrators.

## 9) Contract Layout Order

All contracts should be structured in the following order:

1. Constants
2. Immutables
3. State variables
4. Constructor / initializer
5. Configuration / admin functions
6. User-facing external/public functions
7. Internal functions
8. External view functions
9. Public view functions

> Note: keep function groups separated by clear section comments.
> Internal functions should be placed immediately before the getter/view groups.

## 10) Validation, Modifiers, and Checks

* Avoid modifiers.
* Prefer internal functions for validations and checks:

  * `_requireNotPaused()`
  * `_requireAuthorized(address _caller)`
  * `_requireNonZero(address _addr)`

> Rationale: internal checks are easier to step through, test, and audit than chained modifiers.

## 11) Yul / Assembly

* Use Yul/assembly **sparingly** and only when necessary for gas optimizations.
* Every assembly block must include:

  * a short rationale comment (why assembly is needed)
  * tests demonstrating correctness
  * clear constraints on inputs/outputs

## 12) Testing Conventions (Foundry)

Testing conventions are defined in:

* `constraints/testing.md`

## 13) Scripts

* Script files must use `.s.sol`.
* Scripts should be deterministic and avoid hidden state.
* Scripts must not contain secrets. Use environment variables and `.env` patterns as required.
