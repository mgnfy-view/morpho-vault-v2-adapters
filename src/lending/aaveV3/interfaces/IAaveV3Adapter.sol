// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IAdapterBase } from "@src/adapterBase/interfaces/IAdapterBase.sol";

/// @title IAaveV3Adapter.
/// @author mgnfy-view.
/// @notice Interface to be implemented by the Aave v3 adapter.
interface IAaveV3Adapter is IAdapterBase {
    error AaveV3Adapter__InvalidPool(address _pool);

    function getIds(address _pool) external view returns (bytes32[] memory);
    function allocation(address _pool) external view returns (uint256);
}
