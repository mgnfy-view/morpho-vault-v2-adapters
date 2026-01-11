// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IAdapterBase } from "@src/adapterBase/interfaces/IAdapterBase.sol";

/// @title ISiloV2IsolatedMarketAdapter.
/// @author mgnfy-view.
/// @notice Interface for the Silo v2 isolated market adapter used by Morpho Vault v2.
interface ISiloV2IsolatedMarketAdapter is IAdapterBase {
    /// @notice Thrown when a Silo market is not a valid Silo v2 deployment.
    error SiloV2IsolatedMarketAdapter__InvalidSilo(address _silo);

    /// @notice Gets the Silo factory address used for market validation.
    function getSiloFactory() external view returns (address);
    /// @notice Gets the number of tracked Silo markets with a non-zero allocation.
    function getSilosListLength() external view returns (uint256);
    /// @notice Gets the Silo address at the given index in the tracked list.
    function getSilo(uint256 _index) external view returns (address);
    /// @notice Gets the IDs associated with the given Silo market.
    function getIds(address _silo) external view returns (bytes32[] memory);
    /// @notice Gets the amount allocated to the given Silo per the parent vault's accounting.
    function getAllocation(address _silo) external view returns (uint256);
}
