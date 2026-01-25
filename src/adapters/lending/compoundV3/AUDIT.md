# Compound V3 Adapter Audit Notes

## Scope

In scope for this adapter family:
- `src/adapters/lending/compoundV3/CompoundV3Adapter.sol`
- `src/adapters/lending/compoundV3/CompoundV3AdapterFactory.sol`
- `src/adapterBase/AdapterBase.sol`

Supporting interfaces used by the adapter are out of scope except as referenced by behavior.

## System Overview

The Compound v3 adapter lets a Morpho Vault v2 allocate assets into Compound v3 comet instances via `supply` and
withdraw via `withdraw`. The adapter is deployed by `CompoundV3AdapterFactory` and is bound to a single Morpho vault.
Comet instances are validated via the Compound v3 configurator and the base token is checked against the vault asset.

## Architecture Overview

- `CompoundV3AdapterFactory` deploys an adapter for a vault and tracks it in mappings. It allows overwriting the adapter
  for the same parent vault.
- `CompoundV3Adapter` stores the parent vault, accepted asset, and adapter ID from `AdapterBase`.
- `allocate` and `deallocate` are only callable by the parent vault. Each call decodes a comet address, validates it
  via the configurator, and calls `supply` or `withdraw` on the comet. The adapter maintains a list of comets with
  non-zero allocation and uses comet `balanceOf` to compute real assets.
- `realAssets` sums comet balances across tracked comets.

## Trust and Threat Assumptions

- The Morpho vault is trusted to call `allocate`/`deallocate` correctly and to keep the vault allocation accounting
  consistent with the adapter.
- The Compound v3 configurator is trusted to accurately report comet configuration and base token.
- Comet instances are trusted to implement standard behavior for `supply`, `withdraw`, and `balanceOf`.
- The parent vault owner controls `setSkimRecipient`, which can direct `skim` transfers of any ERC20 held by the adapter.

## Invariants (with rationale)

- Only the parent Morpho vault can call `allocate` and `deallocate`.
- `s_comets` tracks only comets with non-zero allocation, and comets with zero allocation are removed after a call.
- `getAllocation` reflects the parent vault's persisted allocation for the comet ID.
- `realAssets` equals the sum of comet balances across tracked comets at the time of the call.
- Comet validation must pass before any external comet interaction.

## Unit Test Coverage Summary

- Allocate/deallocate behavior: `test/lending/compoundV3/Allocate.t.sol`, `test/lending/compoundV3/Deallocate.t.sol`.
- Miscellaneous behaviors: `test/lending/compoundV3/Miscellaneous.t.sol`.
- Factory deployment logic: `test/lending/compoundV3/Factory.t.sol`.

## Known Risks, Limitations, and Trade-offs

- External protocol risk: Comet behavior changes or reverts can block allocation and impact accounting.
- Validation relies on configurator configuration and comet `baseToken`; misconfiguration can cause reverts or
  unexpected acceptance.
- `allocate` and `deallocate` rely on ERC20 `approve` and comet calls; a non-standard token could break flows.
- `realAssets` only accounts for comets tracked in `s_comets`; stale list management could underreport assets if a
  comet is not tracked.

## References

- Adapter: `src/adapters/lending/compoundV3/CompoundV3Adapter.sol`
- Factory: `src/adapters/lending/compoundV3/CompoundV3AdapterFactory.sol`
- Base: `src/adapterBase/AdapterBase.sol`
