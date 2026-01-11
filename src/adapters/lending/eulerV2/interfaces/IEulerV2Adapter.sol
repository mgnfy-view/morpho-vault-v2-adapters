// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IAdapterBase } from "@src/adapterBase/interfaces/IAdapterBase.sol";

/// @title IEulerV2Adapter.
/// @author mgnfy-view.
/// @notice Interface for the Euler v2 adapter used by Morpho Vault v2.
interface IEulerV2Adapter is IAdapterBase {
    /// @notice Thrown when an EVault is not a valid deployment.
    error EulerV2Adapter__InvalidEVault();

    /// @notice Gets the EVault factory address used for validation.
    function getEVaultFactory() external view returns (address);
    /// @notice Gets the number of tracked vaults with a non-zero allocation.
    function getVaultsListLength() external view returns (uint256);
    /// @notice Gets the vault address at the given index in the tracked list.
    function getVault(uint256 _index) external view returns (address);
    /// @notice Gets the IDs associated with the given Euler v2 vault.
    function getIds(address _vault) external view returns (bytes32[] memory);
    /// @notice Gets the amount allocated to the given vault per the parent vault's accounting.
    function getAllocation(address _vault) external view returns (uint256);
}
