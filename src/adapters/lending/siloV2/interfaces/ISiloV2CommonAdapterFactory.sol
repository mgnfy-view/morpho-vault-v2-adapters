// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title ISiloV2CommonAdapterFactory.
/// @author mgnfy-view.
/// @notice Interface for the Silo v2 common adapter factory.
interface ISiloV2CommonAdapterFactory {
    /// @notice Emitted when a new Silo v2 isolated market adapter is deployed for a parent vault.
    event SiloV2IsolatedMarketAdapterCreated(address indexed parentVault, address indexed siloV2IsolatedMarketAdapter);
    /// @notice Emitted when a new Silo v2 managed vault adapter is deployed for a parent vault.
    event SiloV2ManagedVaultAdapterCreated(address indexed parentVault, address indexed siloV2ManagedVaultAdapter);

    /// @notice Deploys a Silo v2 isolated market adapter for the given parent vault.
    function createSiloV2IsolatedMarketAdapter(address _parentVault) external returns (address);
    /// @notice Deploys a Silo v2 managed vault adapter for the given parent vault.
    function createSiloV2ManagedVaultAdapter(address _parentVault) external returns (address);

    /// @notice Gets the Silo v2 isolated market adapter address for the given parent vault.
    function getSiloV2IsolatedMarketAdapter(address _parentVault) external view returns (address);
    /// @notice Returns true if the address is an isolated market adapter deployed by this factory.
    function isSiloV2IsolatedMarketAdapter(address _adapter) external view returns (bool);

    /// @notice Gets the Silo v2 managed vault adapter address for the given parent vault.
    function getSiloV2ManagedVaultAdapter(address _parentVault) external view returns (address);
    /// @notice Returns true if the address is a managed vault adapter deployed by this factory.
    function isSiloV2ManagedVaultAdapter(address _adapter) external view returns (bool);
}
