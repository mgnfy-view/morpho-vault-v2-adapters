# Aave V3 Adapter Audit Notes

## Scope

In scope for this adapter family:
- `src/adapters/lending/aaveV3/AaveV3Adapter.sol`
- `src/adapters/lending/aaveV3/AaveV3AdapterFactory.sol`
- `src/adapterBase/AdapterBase.sol`

Supporting interfaces used by the adapter are out of scope except as referenced by behavior.

## System Overview

The Aave v3 adapter lets a Morpho Vault v2 allocate assets into Aave v3 pools via `supply` and withdraw via `withdraw`.
The adapter is deployed by `AaveV3AdapterFactory` and is bound to a single Morpho vault. Positions are tracked through
Aave aToken balances, and pools are validated against the Aave Pool Addresses Provider Registry.

## Architecture Overview

- `AaveV3AdapterFactory` deploys an adapter for a vault and tracks it in mappings. It allows overwriting the adapter
  for the same parent vault.
- `AaveV3Adapter` stores the parent vault, accepted asset, and adapter ID from `AdapterBase`.
- `allocate` and `deallocate` are only callable by the parent vault. Each call decodes a pool address, validates it
  via the registry, and calls `supply` or `withdraw` on the pool. The adapter maintains a list of pools with non-zero
  allocation and uses aToken balances to compute real assets.
- `realAssets` sums aToken balances across tracked pools and is intended to match the external protocol state.

## Trust and Threat Assumptions

- The Morpho vault is trusted to call `allocate`/`deallocate` correctly and to keep the vault allocation accounting
  consistent with the adapter.
- The Aave Pool Addresses Provider Registry is trusted to be accurate and not return malicious providers.
- Aave v3 pools and aTokens are trusted to implement standard behavior for `supply`, `withdraw`, `balanceOf`, and
  `getReserveData`.
- The parent vault owner controls `setSkimRecipient`, which can direct `skim` transfers of any ERC20 held by the adapter.

## Invariants (with rationale)

- Only the parent Morpho vault can call `allocate` and `deallocate`.
- `s_pools` tracks only pools with non-zero allocation, and pools with zero allocation are removed after a call.
- `getAllocation` reflects the parent vault's persisted allocation for the pool ID.
- `realAssets` equals the sum of aToken balances across tracked pools at the time of the call.
- Pool validation must pass before any external pool interaction.

## Unit Test Coverage Summary

- Allocate/deallocate behavior: `test/lending/aaveV3/Allocate.t.sol`, `test/lending/aaveV3/Deallocate.t.sol`.
- Miscellaneous behaviors: `test/lending/aaveV3/Miscellaneous.t.sol`.
- Factory deployment logic: `test/lending/aaveV3/Factory.t.sol`.

## Known Risks, Limitations, and Trade-offs

- External protocol risk: Aave pool or aToken behavior changes or reverts can block allocation and impact accounting.
- The registry list is iterated linearly; a large list increases gas costs for validation.
- `allocate` and `deallocate` rely on ERC20 `approve` and Aave v3 pool calls; a non-standard token could break flows.
- `realAssets` only accounts for pools tracked in `s_pools`; stale list management could underreport assets if a pool
  is not tracked.

## References

- Adapter: `src/adapters/lending/aaveV3/AaveV3Adapter.sol`
- Factory: `src/adapters/lending/aaveV3/AaveV3AdapterFactory.sol`
- Base: `src/adapterBase/AdapterBase.sol`
