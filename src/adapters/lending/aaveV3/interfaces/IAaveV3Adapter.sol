// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IAdapterBase } from "@src/adapterBase/interfaces/IAdapterBase.sol";

/// @title IAaveV3Adapter.
/// @author mgnfy-view.
/// @notice Interface for the Aave v3 adapter used by Morpho Vault v2.
interface IAaveV3Adapter is IAdapterBase {
    /// @notice Thrown when a pool is not a valid Aave v3 pool.
    error AaveV3Adapter__InvalidPool(address _pool);

    /// @notice Gets the pool addresses provider registry address used for validation.
    function getPoolAddressesProviderRegistry() external view returns (address);
    /// @notice Gets the number of tracked Aave v3 pools with a non-zero allocation.
    function getPoolsListLength() external view returns (uint256);
    /// @notice Gets the pool address at the given index in the tracked pools list.
    function getPool(uint256 _index) external view returns (address);
    /// @notice Gets the IDs associated with the given Aave v3 pool.
    function getIds(address _pool) external view returns (bytes32[] memory);
    /// @notice Gets the amount allocated to the given Aave v3 pool per the parent vault's accounting.
    function getAllocation(address _pool) external view returns (uint256);
}
