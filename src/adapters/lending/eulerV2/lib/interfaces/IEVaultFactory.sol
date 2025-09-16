// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IEVaultFactory {
    function isProxy(address _proxy) external view returns (bool);
}
