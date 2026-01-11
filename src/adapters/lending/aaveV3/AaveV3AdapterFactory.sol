// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IAaveV3AdapterFactory } from "@src/adapters/lending/aaveV3/interfaces/IAaveV3AdapterFactory.sol";

import { AaveV3Adapter } from "@src/adapters/lending/aaveV3/AaveV3Adapter.sol";

/// @title AaveV3AdapterFactory.
/// @author mgnfy-view.
/// @notice Factory contract to deploy Aave v3 adapters for Morpho Vault v2.
contract AaveV3AdapterFactory is IAaveV3AdapterFactory {
    /// @dev The pool addresses provider registry for Aave V3.
    address internal immutable i_poolAddressesProviderRegistry;
    /// @dev Maps a parent Morpho vault to its corresponding Aave v3 adapter.
    mapping(address parentVault => address aaveV3Adapter) internal s_aaveV3Adapters;
    /// @dev Checks if the given address is an Aave v3 adapter deployed by this factory or not.
    mapping(address account => bool isAaveV3Adapter) internal s_isAaveV3Adapter;

    /// @dev Initializes the contract.
    /// @param _poolAddressesProviderRegistry The pool addresses provider registry address from
    /// Aave v3.
    constructor(address _poolAddressesProviderRegistry) {
        i_poolAddressesProviderRegistry = _poolAddressesProviderRegistry;
    }

    /// @notice Deploys the Aave v3 adapter for the given parent vault.
    /// @dev New deployments can overwrite the adapter address.
    /// @param _parentVault The Morpho Vault v2 instance.
    /// @return The deployed adapter address.
    function createAaveV3Adapter(address _parentVault) external returns (address) {
        address aaveV3Adapter = address(new AaveV3Adapter(_parentVault, i_poolAddressesProviderRegistry));
        s_aaveV3Adapters[_parentVault] = aaveV3Adapter;
        s_isAaveV3Adapter[aaveV3Adapter] = true;

        emit AaveV3AdapterCreated(_parentVault, aaveV3Adapter);

        return aaveV3Adapter;
    }

    /// @notice Gets the Aave v3 adapter address for the given parent vault.
    /// @param _parentVault The parent Morpho vault address.
    /// @return The adapter address.
    function getAaveV3Adapter(address _parentVault) external view returns (address) {
        return s_aaveV3Adapters[_parentVault];
    }

    /// @notice Checks if the given adapter address is an Aave v3 adapter deployed by this
    /// factory or not.
    /// @param _adapter The adapter address.
    /// @return A boolean indicating whether the given adapter address is an Aave v3 adapter deployed by this
    /// factory or not.
    function isAaveV3Adapter(address _adapter) external view returns (bool) {
        return s_isAaveV3Adapter[_adapter];
    }
}
