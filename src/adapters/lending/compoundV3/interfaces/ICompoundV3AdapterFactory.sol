// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICompoundV3AdapterFactory {
    event CompoundV3AdapterCreated(address indexed parentVault, address indexed compoundV3Adapter);

    function createCompoundV3Adapter(address _parentVault) external returns (address);

    function getCompoundV3Adapter(address _parentVault) external view returns (address);
    function isCompoundV3Adapter(address _adapter) external view returns (bool);
}
