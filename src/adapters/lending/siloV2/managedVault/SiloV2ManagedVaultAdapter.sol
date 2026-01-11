// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { AdapterBase } from "@src/adapterBase/AdapterBase.sol";

import { ISiloVault } from "@src/adapters/lending/siloV2/commonLib/interfaces/ISiloVault.sol";
import { ISiloVaultsFactory } from "@src/adapters/lending/siloV2/commonLib/interfaces/ISiloVaultsFactory.sol";
import {
    ISiloV2ManagedVaultAdapter
} from "@src/adapters/lending/siloV2/managedVault/interfaces/ISiloV2ManagedVaultAdapter.sol";

/// @title SiloV2ManagedVaultAdapter.
/// @author mgnfy-view.
/// @notice Morpho Vault v2 adapter that allocates assets into Silo v2 managed (curated) vaults.
/// @dev This adapter validates managed vaults via a configured SiloVaultsFactory and tracks positions via ERC4626
/// share accounting.
contract SiloV2ManagedVaultAdapter is AdapterBase, ISiloV2ManagedVaultAdapter {
    /// @notice The SiloVaultsFactory used to validate Silo managed vault deployments.
    ISiloVaultsFactory internal immutable i_siloVaultsFactory;
    /// @notice List of Silo managed vaults with a non-zero allocation.
    ISiloVault[] internal s_siloVaults;

    /// @notice Initializes the adapter with the parent Morpho Vault v2 and SiloVaultsFactory.
    /// @param _morphoVaultV2 The Morpho Vault v2 address that owns this adapter.
    /// @param _siloVaultsFactory The SiloVaultsFactory address used for managed vault validation.
    constructor(address _morphoVaultV2, address _siloVaultsFactory) AdapterBase(_morphoVaultV2) {
        i_siloVaultsFactory = ISiloVaultsFactory(_siloVaultsFactory);
    }

    /// @notice Supplies `_assets` to the given Silo v2 managed vault.
    /// @dev `_data` must be `abi.encode(address siloVaultAddr)`.
    /// @dev `getAllocation(_siloVault)` reads the parent vault's persisted allocation, which is only updated at the end
    /// of the parent vault's `allocate()` call, so within this function it reflects the pre-call allocation.
    /// @param _data Abi encoded Silo managed vault address.
    /// @param _assets The amount of assets to supply.
    /// @return A list of IDs associated with the given Silo managed vault.
    /// @return The delta change in the amount of assets held by this adapter for the given Silo managed vault.
    function allocate(bytes memory _data, uint256 _assets, bytes4, address)
        external
        returns (bytes32[] memory, int256)
    {
        _requireCallerIsMorphoVault(msg.sender);

        (address siloVaultAddr) = abi.decode(_data, (address));
        ISiloVault siloVault = ISiloVault(siloVaultAddr);

        _validateSiloVault(siloVaultAddr);

        if (_assets > 0) {
            i_asset.approve(siloVaultAddr, _assets);
            siloVault.deposit(_assets, address(this));
        }

        uint256 oldAllocation = getAllocation(siloVaultAddr);
        uint256 newAllocation = siloVault.previewRedeem(siloVault.balanceOf(address(this)));
        _updateSiloVaultsList(siloVault, oldAllocation, newAllocation);

        // forge-lint: disable-next-line(unsafe-typecast)
        return (getIds(siloVaultAddr), int256(newAllocation) - int256(oldAllocation));
    }

    /// @notice Withdraws `_assets` from the given Silo v2 managed vault.
    /// @dev `_data` must be `abi.encode(address siloVaultAddr)`.
    /// @dev `getAllocation(_siloVault)` reads the parent vault's persisted allocation, which is only updated at the end
    /// of the parent vault's `deallocate()` call, so within this function it reflects the pre-call allocation.
    /// @param _data Abi encoded Silo managed vault address.
    /// @param _assets The amount of assets to withdraw.
    /// @return A list of IDs associated with the given Silo managed vault.
    /// @return The delta change in the amount of assets held by this adapter for the given Silo managed vault.
    function deallocate(
        bytes memory _data,
        uint256 _assets,
        bytes4,
        address
    )
        external
        returns (bytes32[] memory, int256)
    {
        _requireCallerIsMorphoVault(msg.sender);

        (address siloVaultAddr) = abi.decode(_data, (address));
        ISiloVault siloVault = ISiloVault(siloVaultAddr);

        _validateSiloVault(siloVaultAddr);

        if (_assets > 0) {
            siloVault.withdraw(_assets, address(this), address(this));
        }

        uint256 oldAllocation = getAllocation(siloVaultAddr);
        uint256 newAllocation = siloVault.previewRedeem(siloVault.balanceOf(address(this)));
        _updateSiloVaultsList(siloVault, oldAllocation, newAllocation);

        // forge-lint: disable-next-line(unsafe-typecast)
        return (getIds(siloVaultAddr), int256(newAllocation) - int256(oldAllocation));
    }

    /// @notice Reverts if `_siloVault` is not a valid Silo managed vault according to the configured factory.
    /// @param _siloVault The Silo managed vault address to validate.
    function _validateSiloVault(address _siloVault) internal view {
        if (!i_siloVaultsFactory.isSiloVault(_siloVault)) {
            revert SiloV2ManagedVaultAdapter__InvalidSiloVault(_siloVault);
        }
    }

    /// @dev Updates the list of tracked Silo managed vaults with non-zero allocations.
    /// @dev If `_newAllocation` becomes 0, the managed vault is removed from the list.
    /// @param _siloVault The managed vault to add/remove, or no-op if already present and allocation remains non-zero.
    /// @param _oldAllocation The amount of assets held by the adapter for the managed vault before the call.
    /// @param _newAllocation The amount of assets held by the adapter for the managed vault after the call.
    function _updateSiloVaultsList(ISiloVault _siloVault, uint256 _oldAllocation, uint256 _newAllocation) internal {
        uint256 siloVaultsLength = s_siloVaults.length;

        if (_oldAllocation > 0 && _newAllocation == 0) {
            for (uint256 i = 0; i < siloVaultsLength; i++) {
                if (address(s_siloVaults[i]) == address(_siloVault)) {
                    s_siloVaults[i] = s_siloVaults[siloVaultsLength - 1];
                    s_siloVaults.pop();
                    break;
                }
            }
        } else if (_oldAllocation == 0 && _newAllocation > 0) {
            s_siloVaults.push(_siloVault);
        }
    }

    /// @notice Gets the total amount of assets held by this adapter across all tracked Silo managed vaults.
    /// @dev Returns the sum of `previewRedeem(balanceOf(this))` over all tracked managed vaults.
    /// @return The total real assets held by this adapter across tracked managed vaults.
    function realAssets() external view returns (uint256) {
        uint256 siloVaultsLength = s_siloVaults.length;
        uint256 amountRealAssets;

        for (uint256 i = 0; i < siloVaultsLength; ++i) {
            amountRealAssets += s_siloVaults[i].previewRedeem(s_siloVaults[i].balanceOf(address(this)));
        }

        return amountRealAssets;
    }

    /// @notice Gets the SiloVaultsFactory address used for managed vault validation.
    /// @return The SiloVaultsFactory address.
    function getSiloVaultsFactory() external view returns (address) {
        return address(i_siloVaultsFactory);
    }

    /// @notice Gets the number of tracked Silo managed vaults with a non-zero position.
    /// @return The number of tracked managed vaults.
    function getSiloVaultsListLength() external view returns (uint256) {
        return s_siloVaults.length;
    }

    /// @notice Gets the Silo managed vault address at index `_index` in the tracked managed vaults list.
    /// @param _index The array index.
    /// @return The Silo managed vault address at the given index.
    function getSiloVault(uint256 _index) external view returns (address) {
        return address(s_siloVaults[_index]);
    }

    /// @notice Gets all the IDs associated with the given Silo managed vault.
    /// @param _siloVault The Silo managed vault address.
    /// @return A list of bytes32 IDs.
    function getIds(address _siloVault) public view returns (bytes32[] memory) {
        bytes32[] memory ids = new bytes32[](2);
        ids[0] = i_adapterId;
        ids[1] = keccak256(abi.encode("this/pool", address(this), _siloVault));

        return ids;
    }

    /// @notice Gets the assets allocated to the given managed vault according to the parent vault's accounting.
    /// @dev This value is only updated by the parent vault at the end of its `allocate()` and `deallocate()` calls.
    /// @param _siloVault The Silo managed vault address.
    /// @return The amount allocated to the managed vault according to the parent vault.
    function getAllocation(address _siloVault) public view returns (uint256) {
        return i_morphoVaultV2.allocation(getIds(_siloVault)[1]);
    }
}
