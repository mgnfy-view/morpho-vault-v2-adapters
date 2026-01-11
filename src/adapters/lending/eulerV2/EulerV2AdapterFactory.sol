// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IEulerV2AdapterFactory } from "@src/adapters/lending/eulerV2/interfaces/IEulerV2AdapterFactory.sol";
import { IEVaultFactory } from "@src/adapters/lending/eulerV2/lib/interfaces/IEVaultFactory.sol";

import { EulerV2Adapter } from "@src/adapters/lending/eulerV2/EulerV2Adapter.sol";

/// @title EulerV2AdapterFactory.
/// @author mgnfy-view.
/// @notice Factory contract to deploy Euler v2 adapters for Morpho Vault v2.
contract EulerV2AdapterFactory is IEulerV2AdapterFactory {
    /// @dev The Euler v2 vault factory that deploys Euler vault proxies.
    IEVaultFactory internal immutable i_factory;
    /// @dev Maps a parent Morpho vault to its corresponding Euler v2 adapter.
    mapping(address parentVault => address eulerV2Adapter) internal s_eulerV2Adapters;
    /// @dev Checks if the given address is a Euler v2 adapter deployed by this factory or not.
    mapping(address account => bool isEulerV2Adapter) internal s_isEulerV2Adapter;

    /// @dev Initializes the contract.
    /// @param _factory The Euler v2 vault factory that deploys Euler vault proxies.
    constructor(address _factory) {
        i_factory = IEVaultFactory(_factory);
    }

    /// @notice Deploys the Euler v2 adapter for the given parent vault.
    /// @dev New deployments can overwrite the adapter address.
    /// @param _parentVault The Morpho Vault v2 instance.
    /// @return The deployed adapter address.
    function createEulerV2Adapter(address _parentVault) external returns (address) {
        address eulerV2Adapter = address(new EulerV2Adapter(_parentVault, address(i_factory)));
        s_eulerV2Adapters[_parentVault] = eulerV2Adapter;
        s_isEulerV2Adapter[eulerV2Adapter] = true;

        emit EulerV2AdapterCreated(_parentVault, eulerV2Adapter);

        return eulerV2Adapter;
    }

    /// @notice Gets the Euler v2 adapter address for the given parent vault.
    /// @param _parentVault The parent Morpho vault address.
    /// @return The adapter address.
    function getEulerV2Adapter(address _parentVault) external view returns (address) {
        return s_eulerV2Adapters[_parentVault];
    }

    /// @notice Checks if the given adapter address is an Euler v2 adapter deployed by this
    /// factory or not.
    /// @param _adapter The adapter address.
    /// @return A boolean indicating whether the given adapter address is a Euler v2 adapter deployed by this
    /// factory or not.
    function isEulerV2Adapter(address _adapter) external view returns (bool) {
        return s_isEulerV2Adapter[_adapter];
    }
}
