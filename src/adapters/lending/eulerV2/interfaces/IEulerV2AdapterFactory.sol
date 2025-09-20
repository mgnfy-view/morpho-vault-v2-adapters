// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IEulerV2AdapterFactory {
    event EulerV2AdapterCreated(address indexed parentVault, address indexed compoundV3Adapter);

    function createEulerV2Adapter(address _parentVault) external returns (address);

    function getEulerV2Adapter(address _parentVault) external view returns (address);
    function isEulerV2Adapter(address _adapter) external view returns (bool);
}
