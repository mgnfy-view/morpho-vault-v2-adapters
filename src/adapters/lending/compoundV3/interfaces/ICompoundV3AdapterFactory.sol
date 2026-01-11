// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title ICompoundV3AdapterFactory.
/// @author mgnfy-view.
/// @notice Interface for the Compound v3 adapter factory.
interface ICompoundV3AdapterFactory {
    /// @notice Emitted when a new Compound v3 adapter is deployed for a parent vault.
    event CompoundV3AdapterCreated(address indexed parentVault, address indexed compoundV3Adapter);

    /// @notice Deploys a Compound v3 adapter for the given parent vault.
    function createCompoundV3Adapter(address _parentVault) external returns (address);

    /// @notice Gets the Compound v3 adapter address for the given parent vault.
    function getCompoundV3Adapter(address _parentVault) external view returns (address);
    /// @notice Returns true if the address is a Compound v3 adapter deployed by this factory.
    function isCompoundV3Adapter(address _adapter) external view returns (bool);
}
