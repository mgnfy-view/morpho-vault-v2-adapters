// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title ISiloV2CommonAdapterFactory.
/// @author mgnfy-view.
/// @notice Interface to be implemented by the Silo v2 common adapter factory.
interface ISiloV2CommonAdapterFactory {
    event SiloV2IsolatedMarketAdapterCreated(address indexed parentVault, address indexed siloV2IsolatedMarketAdapter);
    event SiloV2ManagedVaultAdapterCreated(address indexed parentVault, address indexed siloV2ManagedVaultAdapter);

    function createSiloV2IsolatedMarketAdapter(address _parentVault) external returns (address);
    function createSiloV2ManagedVaultAdapter(address _parentVault) external returns (address);

    function getSiloV2IsolatedMarketAdapter(address _parentVault) external view returns (address);
    function isSiloV2IsolatedMarketAdapter(address _adapter) external view returns (bool);

    function getSiloV2ManagedVaultAdapter(address _parentVault) external view returns (address);
    function isSiloV2ManagedVaultAdapter(address _adapter) external view returns (bool);
}
