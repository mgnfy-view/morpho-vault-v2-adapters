// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IAaveV3AdapterFactory.
/// @author mgnfy-view.
/// @notice Interface for the Aave v3 adapter factory.
interface IAaveV3AdapterFactory {
    /// @notice Emitted when a new Aave v3 adapter is deployed for a parent vault.
    event AaveV3AdapterCreated(address indexed parentVault, address indexed aaveV3Adapter);

    /// @notice Deploys an Aave v3 adapter for the given parent vault.
    function createAaveV3Adapter(address _parentVault) external returns (address);

    /// @notice Gets the Aave v3 adapter address for the given parent vault.
    function getAaveV3Adapter(address _parentVault) external view returns (address);
    /// @notice Returns true if the address is an Aave v3 adapter deployed by this factory.
    function isAaveV3Adapter(address _adapter) external view returns (bool);
}
