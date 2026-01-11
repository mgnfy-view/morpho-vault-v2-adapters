// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IAdapterBase } from "@src/adapterBase/interfaces/IAdapterBase.sol";

/// @title ISiloV2ManagedVaultAdapter.
/// @author mgnfy-view.
/// @notice Interface for the Silo v2 managed vault adapter used by Morpho Vault v2.
interface ISiloV2ManagedVaultAdapter is IAdapterBase {
    /// @notice Thrown when a managed vault is not a valid Silo v2 deployment.
    error SiloV2ManagedVaultAdapter__InvalidSiloVault(address _siloVault);

    /// @notice Gets the Silo vaults factory address used for vault validation.
    function getSiloVaultsFactory() external view returns (address);
    /// @notice Gets the number of tracked Silo vaults with a non-zero allocation.
    function getSiloVaultsListLength() external view returns (uint256);
    /// @notice Gets the Silo vault address at the given index in the tracked list.
    function getSiloVault(uint256 _index) external view returns (address);
    /// @notice Gets the IDs associated with the given Silo vault.
    function getIds(address _siloVault) external view returns (bytes32[] memory);
    /// @notice Gets the amount allocated to the given Silo vault per the parent vault's accounting.
    function getAllocation(address _siloVault) external view returns (uint256);
}
