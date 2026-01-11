// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ISiloV2CommonAdapterFactory } from "@src/adapters/lending/siloV2/interfaces/ISiloV2CommonAdapterFactory.sol";

import {
    SiloV2IsolatedMarketAdapter
} from "@src/adapters/lending/siloV2/isolatedMarket/SiloV2IsolatedMarketAdapter.sol";
import { SiloV2ManagedVaultAdapter } from "@src/adapters/lending/siloV2/managedVault/SiloV2ManagedVaultAdapter.sol";

/// @title SiloV2CommonAdapterFactory.
/// @author mgnfy-view.
/// @notice Factory contract to deploy Silo v2 adapters for isolated markets and managed vaults.
contract SiloV2CommonAdapterFactory is ISiloV2CommonAdapterFactory {
    /// @dev The Silo factory used to validate Silo v2 isolated markets.
    address internal immutable i_siloFactory;
    /// @dev The SiloVaultsFactory used to validate Silo v2 managed vaults.
    address internal immutable i_siloVaultsFactory;
    /// @dev Maps a parent Morpho vault to its corresponding Silo v2 isolated market adapter.
    mapping(address parentVault => address siloV2IsolatedMarketAdapter) internal s_siloV2IsolatedMarketAdapters;
    /// @dev Maps a parent Morpho vault to its corresponding Silo v2 managed vault adapter.
    mapping(address parentVault => address siloV2ManagedVaultAdapter) internal s_siloV2ManagedVaultAdapters;
    /// @dev Checks if the given address is a Silo v2 isolated market adapter deployed by this factory or not.
    mapping(address account => bool isSiloV2IsolatedMarketAdapter) internal s_isSiloV2IsolatedMarketAdapter;
    /// @dev Checks if the given address is a Silo v2 managed vault adapter deployed by this factory or not.
    mapping(address account => bool isSiloV2ManagedVaultAdapter) internal s_isSiloV2ManagedVaultAdapter;

    /// @dev Initializes the contract.
    /// @param _siloFactory The Silo factory address used for isolated market validation.
    /// @param _siloVaultsFactory The SiloVaultsFactory address used for managed vault validation.
    constructor(address _siloFactory, address _siloVaultsFactory) {
        i_siloFactory = _siloFactory;
        i_siloVaultsFactory = _siloVaultsFactory;
    }

    /// @notice Deploys the Silo v2 isolated market adapter for the given parent vault.
    /// @dev New deployments can overwrite the adapter address.
    /// @param _parentVault The Morpho Vault v2 instance.
    /// @return The deployed adapter address.
    function createSiloV2IsolatedMarketAdapter(address _parentVault) external returns (address) {
        address siloV2IsolatedMarketAdapter = address(new SiloV2IsolatedMarketAdapter(_parentVault, i_siloFactory));
        s_siloV2IsolatedMarketAdapters[_parentVault] = siloV2IsolatedMarketAdapter;
        s_isSiloV2IsolatedMarketAdapter[siloV2IsolatedMarketAdapter] = true;

        emit SiloV2IsolatedMarketAdapterCreated(_parentVault, siloV2IsolatedMarketAdapter);

        return siloV2IsolatedMarketAdapter;
    }

    /// @notice Deploys the Silo v2 managed vault adapter for the given parent vault.
    /// @dev New deployments can overwrite the adapter address.
    /// @param _parentVault The Morpho Vault v2 instance.
    /// @return The deployed adapter address.
    function createSiloV2ManagedVaultAdapter(address _parentVault) external returns (address) {
        address siloV2ManagedVaultAdapter = address(new SiloV2ManagedVaultAdapter(_parentVault, i_siloVaultsFactory));
        s_siloV2ManagedVaultAdapters[_parentVault] = siloV2ManagedVaultAdapter;
        s_isSiloV2ManagedVaultAdapter[siloV2ManagedVaultAdapter] = true;

        emit SiloV2ManagedVaultAdapterCreated(_parentVault, siloV2ManagedVaultAdapter);

        return siloV2ManagedVaultAdapter;
    }

    /// @notice Gets the Silo v2 isolated market adapter address for the given parent vault.
    /// @param _parentVault The parent Morpho vault address.
    /// @return The adapter address.
    function getSiloV2IsolatedMarketAdapter(address _parentVault) external view returns (address) {
        return s_siloV2IsolatedMarketAdapters[_parentVault];
    }

    /// @notice Checks if the given adapter address is a Silo v2 isolated market adapter deployed by this
    /// factory or not.
    /// @param _adapter The adapter address.
    /// @return A boolean indicating whether the given adapter address is a Silo v2 isolated market adapter deployed by
    /// this factory or not.
    function isSiloV2IsolatedMarketAdapter(address _adapter) external view returns (bool) {
        return s_isSiloV2IsolatedMarketAdapter[_adapter];
    }

    /// @notice Gets the Silo v2 managed vault adapter address for the given parent vault.
    /// @param _parentVault The parent Morpho vault address.
    /// @return The adapter address.
    function getSiloV2ManagedVaultAdapter(address _parentVault) external view returns (address) {
        return s_siloV2ManagedVaultAdapters[_parentVault];
    }

    /// @notice Checks if the given adapter address is a Silo v2 managed vault adapter deployed by this
    /// factory or not.
    /// @param _adapter The adapter address.
    /// @return A boolean indicating whether the given adapter address is a Silo v2 managed vault adapter deployed by
    /// this factory or not.
    function isSiloV2ManagedVaultAdapter(address _adapter) external view returns (bool) {
        return s_isSiloV2ManagedVaultAdapter[_adapter];
    }
}
