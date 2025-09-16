// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IAdapterBase } from "@src/adapterBase/interfaces/IAdapterBase.sol";

/// @title IEulerV2Adapter.
/// @author mgnfy-view.
/// @notice Interface to be implemented by the Euler v2 adapter.
interface IEulerV2Adapter is IAdapterBase {
    error EulerV2Adapter__InvalidEVault();

    function getEVaultFactory() external view returns (address);
    function getVaultsListLength() external view returns (uint256);
    function getVault(uint256 _index) external view returns (address);
    function getIds(address _vault) external view returns (bytes32[] memory);
    function getAllocation(address _vault) external view returns (uint256);
}
