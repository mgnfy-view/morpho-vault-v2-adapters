// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IAdapterBase } from "@src/adapterBase/interfaces/IAdapterBase.sol";

/// @title ICompoundV3Adapter.
/// @author mgnfy-view.
/// @notice Interface to be implemented by the Compound v3 adapter.
interface ICompoundV3Adapter is IAdapterBase {
    error CompoundV3Adapter__InvalidCometInstance();

    function getConfigurator() external view returns (address);
    function getCometsListLength() external view returns (uint256);
    function getComet(uint256 _index) external view returns (address);
    function getIds(address _comet) external view returns (bytes32[] memory);
    function getAllocation(address _comet) external view returns (uint256);
}
