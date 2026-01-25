# Euler V2 Adapter Audit Notes

## Scope

In scope for this adapter family:
- `src/adapters/lending/eulerV2/EulerV2Adapter.sol`
- `src/adapters/lending/eulerV2/EulerV2AdapterFactory.sol`
- `src/adapterBase/AdapterBase.sol`

Supporting interfaces used by the adapter are out of scope except as referenced by behavior.

## System Overview

The Euler v2 adapter lets a Morpho Vault v2 allocate assets into Euler v2 vaults via `deposit` and withdraw via
`withdraw`. The adapter is deployed by `EulerV2AdapterFactory` and is bound to a single Morpho vault. Vaults are
validated against the Euler v2 vault factory and positions are tracked using vault shares converted to assets.

## Architecture Overview

- `EulerV2AdapterFactory` deploys an adapter for a vault and tracks it in mappings. It allows overwriting the adapter
  for the same parent vault.
- `EulerV2Adapter` stores the parent vault, accepted asset, and adapter ID from `AdapterBase`.
- `allocate` and `deallocate` are only callable by the parent vault. Each call decodes a vault address, validates it
  via the Euler v2 factory, and calls `deposit` or `withdraw` on the vault. The adapter maintains a list of vaults with
  non-zero allocation and uses `convertToAssets(balanceOf(this))` to compute real assets.
- `realAssets` sums converted asset balances across tracked vaults.

## Trust and Threat Assumptions

- The Morpho vault is trusted to call `allocate`/`deallocate` correctly and to keep the vault allocation accounting
  consistent with the adapter.
- The Euler v2 vault factory is trusted to accurately identify valid vault proxies.
- Euler v2 vaults are trusted to implement standard ERC4626-like behavior for `deposit`, `withdraw`, `balanceOf`, and
  `convertToAssets`.
- The parent vault owner controls `setSkimRecipient`, which can direct `skim` transfers of any ERC20 held by the adapter.

## Invariants (with rationale)

- Only the parent Morpho vault can call `allocate` and `deallocate`.
- `s_vaults` tracks only vaults with non-zero allocation, and vaults with zero allocation are removed after a call.
- `getAllocation` reflects the parent vault's persisted allocation for the vault ID.
- `realAssets` equals the sum of vault `convertToAssets(balanceOf(this))` across tracked vaults at the time of the call.
- Vault validation must pass before any external vault interaction.

## Unit Test Coverage Summary

- Allocate/deallocate behavior: `test/lending/eulerV2/Allocate.t.sol`, `test/lending/eulerV2/Deallocate.t.sol`.
- Miscellaneous behaviors: `test/lending/eulerV2/Miscellaneous.t.sol`.
- Factory deployment logic: `test/lending/eulerV2/Factory.t.sol`.

## Known Risks, Limitations, and Trade-offs

- External protocol risk: Euler vault behavior changes or reverts can block allocation and impact accounting.
- `convertToAssets` introduces rounding; `realAssets` is only as accurate as the vault's conversion logic.
- `allocate` and `deallocate` rely on ERC20 `approve` and vault calls; a non-standard token could break flows.
- `realAssets` only accounts for vaults tracked in `s_vaults`; stale list management could underreport assets if a
  vault is not tracked.

## References

- Adapter: `src/adapters/lending/eulerV2/EulerV2Adapter.sol`
- Factory: `src/adapters/lending/eulerV2/EulerV2AdapterFactory.sol`
- Base: `src/adapterBase/AdapterBase.sol`
