// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IAaveV3AdapterFactory.
/// @author mgnfy-view.
/// @notice Interface to be implemented by the Aave v3 adapter factory.
interface IAaveV3AdapterFactory {
    event AaveV3AdapterCreated(address indexed parentVault, address indexed aaveV3Adapter);

    function createAaveV3Adapter(address _parentVault) external returns (address);

    function getAaveV3Adapter(address _parentVault) external view returns (address);
    function isAaveV3Adapter(address _adapter) external view returns (bool);
}
