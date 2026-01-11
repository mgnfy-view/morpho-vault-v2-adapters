// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ICompoundV3AdapterFactory } from "@src/adapters/lending/compoundV3/interfaces/ICompoundV3AdapterFactory.sol";
import { IConfigurator } from "@src/adapters/lending/compoundV3/lib/interfaces/IConfigurator.sol";

import { CompoundV3Adapter } from "@src/adapters/lending/compoundV3/CompoundV3Adapter.sol";

/// @title CompoundV3AdapterFactory.
/// @author mgnfy-view.
/// @notice Factory contract to deploy Compound v3 adapters for Morpho Vault v2.
contract CompoundV3AdapterFactory is ICompoundV3AdapterFactory {
    /// @dev The Compound v3 configurator that can deploy and configure comet instances.
    IConfigurator internal immutable i_configurator;
    /// @dev Maps a parent Morpho vault to its corresponding Compound v3 adapter.
    mapping(address parentVault => address compoundV3Adapter) internal s_compoundV3Adapters;
    /// @dev Checks if the given address is a Compound v3 adapter deployed by this factory or not.
    mapping(address account => bool isCompoundV3Adapter) internal s_isCompoundV3Adapter;

    /// @dev Initializes the contract.
    /// @param _configurator The Compound v3 configurator that can deploy and configure comet instances.
    constructor(address _configurator) {
        i_configurator = IConfigurator(_configurator);
    }

    /// @notice Deploys the Compound v3 adapter for the given parent vault.
    /// @dev New deployments can overwrite the adapter address.
    /// @param _parentVault The Morpho Vault v2 instance.
    /// @return The deployed adapter address.
    function createCompoundV3Adapter(address _parentVault) external returns (address) {
        address compoundV3Adapter = address(new CompoundV3Adapter(_parentVault, address(i_configurator)));
        s_compoundV3Adapters[_parentVault] = compoundV3Adapter;
        s_isCompoundV3Adapter[compoundV3Adapter] = true;

        emit CompoundV3AdapterCreated(_parentVault, compoundV3Adapter);

        return compoundV3Adapter;
    }

    /// @notice Gets the Compound v3 adapter address for the given parent vault.
    /// @param _parentVault The parent Morpho vault address.
    /// @return The adapter address.
    function getCompoundV3Adapter(address _parentVault) external view returns (address) {
        return s_compoundV3Adapters[_parentVault];
    }

    /// @notice Checks if the given adapter address is a Compound v3 adapter deployed by this
    /// factory or not.
    /// @param _adapter The adapter address.
    /// @return A boolean indicating whether the given adapter address is a Compound v3 adapter deployed by this
    /// factory or not.
    function isCompoundV3Adapter(address _adapter) external view returns (bool) {
        return s_isCompoundV3Adapter[_adapter];
    }
}
