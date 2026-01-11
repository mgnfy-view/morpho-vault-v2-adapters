// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IAdapterBase } from "@src/adapterBase/interfaces/IAdapterBase.sol";

/// @title ICompoundV3Adapter.
/// @author mgnfy-view.
/// @notice Interface for the Compound v3 adapter used by Morpho Vault v2.
interface ICompoundV3Adapter is IAdapterBase {
    /// @notice Thrown when a comet instance is invalid or not configured for the vault asset.
    error CompoundV3Adapter__InvalidCometInstance();

    /// @notice Gets the configurator address used to validate comets.
    function getConfigurator() external view returns (address);
    /// @notice Gets the number of tracked comet instances with a non-zero allocation.
    function getCometsListLength() external view returns (uint256);
    /// @notice Gets the comet address at the given index in the tracked list.
    function getComet(uint256 _index) external view returns (address);
    /// @notice Gets the IDs associated with the given comet.
    function getIds(address _comet) external view returns (bytes32[] memory);
    /// @notice Gets the amount allocated to the given comet per the parent vault's accounting.
    function getAllocation(address _comet) external view returns (uint256);
}
