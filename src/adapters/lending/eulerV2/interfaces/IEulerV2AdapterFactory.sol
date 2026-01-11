// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IEulerV2AdapterFactory.
/// @author mgnfy-view.
/// @notice Interface for the Euler v2 adapter factory.
interface IEulerV2AdapterFactory {
    /// @notice Emitted when a new Euler v2 adapter is deployed for a parent vault.
    event EulerV2AdapterCreated(address indexed parentVault, address indexed compoundV3Adapter);

    /// @notice Deploys an Euler v2 adapter for the given parent vault.
    function createEulerV2Adapter(address _parentVault) external returns (address);

    /// @notice Gets the Euler v2 adapter address for the given parent vault.
    function getEulerV2Adapter(address _parentVault) external view returns (address);
    /// @notice Returns true if the address is an Euler v2 adapter deployed by this factory.
    function isEulerV2Adapter(address _adapter) external view returns (bool);
}
