# Silo V2 Adapters Audit Notes

## Scope

In scope for this adapter family:
- `src/adapters/lending/siloV2/isolatedMarket/SiloV2IsolatedMarketAdapter.sol`
- `src/adapters/lending/siloV2/managedVault/SiloV2ManagedVaultAdapter.sol`
- `src/adapters/lending/siloV2/SiloV2CommonAdapterFactory.sol`
- `src/adapterBase/AdapterBase.sol`

Supporting interfaces used by the adapters are out of scope except as referenced by behavior.

## System Overview

The Silo v2 adapters let a Morpho Vault v2 allocate assets into Silo v2 isolated markets and Silo v2 managed vaults
via ERC4626 `deposit` and `withdraw` calls. The adapters are deployed by `SiloV2CommonAdapterFactory` and are each bound
to a single Morpho vault. Market and vault addresses are validated using the configured Silo factories.

## Architecture Overview

- `SiloV2CommonAdapterFactory` deploys an isolated-market adapter and/or a managed-vault adapter for a vault and tracks
  them in mappings. It allows overwriting adapters for the same parent vault.
- `SiloV2IsolatedMarketAdapter` validates markets with `ISiloFactory.isSilo`, then supplies and withdraws using ERC4626
  `deposit`/`withdraw`. It tracks non-zero allocations in `s_silos` and computes real assets via
  `previewRedeem(balanceOf(this))`.
- `SiloV2ManagedVaultAdapter` validates managed vaults with `ISiloVaultsFactory.isSiloVault`, then supplies and
  withdraws using ERC4626 `deposit`/`withdraw`. It tracks non-zero allocations in `s_siloVaults` and computes real
  assets via `previewRedeem(balanceOf(this))`.
- Both adapters use `getAllocation` to read the parent vault allocation for the adapter-specific pool ID.

## Trust and Threat Assumptions

- The Morpho vault is trusted to call `allocate`/`deallocate` correctly and to keep the vault allocation accounting
  consistent with the adapters.
- The Silo factory and SiloVaultsFactory are trusted to accurately identify valid markets and managed vaults.
- ERC4626 vaults are trusted to implement `deposit`, `withdraw`, `balanceOf`, and `previewRedeem` correctly.
- The parent vault owner controls `setSkimRecipient`, which can direct `skim` transfers of any ERC20 held by the adapter.

## Invariants (with rationale)

- Only the parent Morpho vault can call `allocate` and `deallocate`.
- `s_silos` and `s_siloVaults` track only markets/vaults with non-zero allocation, and entries are removed when the
  allocation reaches zero.
- `getAllocation` reflects the parent vault's persisted allocation for the adapter-specific pool ID.
- `realAssets` equals the sum of `previewRedeem(balanceOf(this))` across tracked markets/vaults at the time of the call.
- Market or vault validation must pass before any external ERC4626 interaction.

## Unit Test Coverage Summary

- Isolated market allocate/deallocate: `test/lending/siloV2/isolatedMarket/Allocate.t.sol`,
  `test/lending/siloV2/isolatedMarket/Deallocate.t.sol`.
- Managed vault allocate/deallocate: `test/lending/siloV2/managedVault/Allocate.t.sol`,
  `test/lending/siloV2/managedVault/Deallocate.t.sol`.
- Miscellaneous behaviors: `test/lending/siloV2/isolatedMarket/Miscellaneous.t.sol`,
  `test/lending/siloV2/managedVault/Miscellaneous.t.sol`.
- Factory deployment logic: `test/lending/siloV2/Factory.t.sol`.

## Known Risks, Limitations, and Trade-offs

- External protocol risk: Silo ERC4626 vault behavior changes or reverts can block allocation and impact accounting.
- `previewRedeem` introduces rounding; `realAssets` is only as accurate as the vault's conversion logic.
- `allocate` and `deallocate` rely on ERC20 `approve` and ERC4626 calls; a non-standard token could break flows.
- `realAssets` only accounts for markets/vaults tracked in `s_silos`/`s_siloVaults`; stale list management could
  underreport assets if a market/vault is not tracked.

## References

- Isolated adapter: `src/adapters/lending/siloV2/isolatedMarket/SiloV2IsolatedMarketAdapter.sol`
- Managed adapter: `src/adapters/lending/siloV2/managedVault/SiloV2ManagedVaultAdapter.sol`
- Factory: `src/adapters/lending/siloV2/SiloV2CommonAdapterFactory.sol`
- Base: `src/adapterBase/AdapterBase.sol`
