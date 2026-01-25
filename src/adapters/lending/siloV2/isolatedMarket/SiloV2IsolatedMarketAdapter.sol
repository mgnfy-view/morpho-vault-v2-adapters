// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { AdapterBase } from "@src/adapterBase/AdapterBase.sol";

import { IERC4626 } from "@openzeppelin-contracts-5.3.0/interfaces/IERC4626.sol";
import { ISiloFactory } from "@src/adapters/lending/siloV2/commonLib/interfaces/ISiloFactory.sol";
import {
    ISiloV2IsolatedMarketAdapter
} from "@src/adapters/lending/siloV2/isolatedMarket/interfaces/ISiloV2IsolatedMarketAdapter.sol";

/// @title SiloV2IsolatedMarketAdapter.
/// @author mgnfy-view.
/// @notice Morpho Vault v2 adapter that allocates assets into Silo v2 isolated lending markets.
/// @dev This adapter always supplies borrowable liquidity, validates markets via the Silo factory,
/// and tracks positions via ERC4626 share accounting.
contract SiloV2IsolatedMarketAdapter is AdapterBase, ISiloV2IsolatedMarketAdapter {
    /// @notice The Silo factory used to validate Silo v2 deployments.
    ISiloFactory internal immutable i_siloFactory;
    /// @notice List of Silo markets with a non-zero allocation.
    IERC4626[] internal s_silos;

    /// @notice Initializes the adapter with the parent Morpho Vault v2 and Silo factory.
    /// @param _morphoVaultV2 The Morpho Vault v2 address that owns this adapter.
    /// @param _siloFactory The Silo factory address used for Silo validation.
    constructor(address _morphoVaultV2, address _siloFactory) AdapterBase(_morphoVaultV2) {
        i_siloFactory = ISiloFactory(_siloFactory);
    }

    /// @notice Supplies `_assets` to the given Silo v2 isolated market in borrowable mode.
    /// @dev `_data` must be `abi.encode(address siloAddr)`.
    /// @dev `getAllocation(_silo)` reads the parent vault's persisted allocation, which is only updated at the end of
    /// the parent vault's `allocate()` call, so within this function it reflects the pre-call allocation.
    /// @param _data Abi encoded Silo address.
    /// @param _assets The amount of assets to supply.
    /// @return A list of IDs associated with the given Silo.
    /// @return The delta change in the amount of assets held by this adapter for the given Silo.
    function allocate(bytes memory _data, uint256 _assets, bytes4, address)
        external
        returns (bytes32[] memory, int256)
    {
        _requireCallerIsMorphoVault(msg.sender);

        (address siloAddr) = abi.decode(_data, (address));
        IERC4626 silo = IERC4626(siloAddr);

        _validateIsolatedMarket(siloAddr);

        if (_assets > 0) {
            i_asset.approve(siloAddr, _assets);
            silo.deposit(_assets, address(this));
        }

        uint256 oldAllocation = getAllocation(siloAddr);
        uint256 newAllocation = silo.previewRedeem(silo.balanceOf(address(this)));
        _updateSilosList(silo, oldAllocation, newAllocation);

        // forge-lint: disable-next-line(unsafe-typecast)
        return (getIds(siloAddr), int256(newAllocation) - int256(oldAllocation));
    }

    /// @notice Withdraws `_assets` from the given Silo v2 isolated market in borrowable mode.
    /// @dev `_data` must be `abi.encode(address siloAddr)`.
    /// @dev `getAllocation(_silo)` reads the parent vault's persisted allocation, which is only updated at the end of
    /// the parent vault's `deallocate()` call, so within this function it reflects the pre-call allocation.
    /// @param _data Abi encoded Silo address.
    /// @param _assets The amount of assets to withdraw.
    /// @return A list of IDs associated with the given Silo.
    /// @return The delta change in the amount of assets held by this adapter for the given Silo.
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

        (address siloAddr) = abi.decode(_data, (address));
        IERC4626 silo = IERC4626(siloAddr);

        _validateIsolatedMarket(siloAddr);

        if (_assets > 0) {
            silo.withdraw(_assets, address(this), address(this));
        }

        uint256 oldAllocation = getAllocation(siloAddr);
        uint256 newAllocation = silo.previewRedeem(silo.balanceOf(address(this)));
        _updateSilosList(silo, oldAllocation, newAllocation);

        // forge-lint: disable-next-line(unsafe-typecast)
        return (getIds(siloAddr), int256(newAllocation) - int256(oldAllocation));
    }

    /// @notice Reverts if `_silo` is not a valid Silo v2 deployment according to the configured factory.
    /// @param _silo The Silo address to validate.
    function _validateIsolatedMarket(address _silo) internal view {
        if (!i_siloFactory.isSilo(_silo)) revert SiloV2IsolatedMarketAdapter__InvalidSilo(_silo);
    }

    /// @dev Updates the list of tracked silos with non-zero allocations.
    /// @dev If `_newAllocation` becomes 0, the silo is removed from the list.
    /// @param _silo The Silo to add/remove, or no-op if already present and allocation remains non-zero.
    /// @param _oldAllocation The amount of assets held by the adapter for the Silo before the call.
    /// @param _newAllocation The amount of assets held by the adapter for the Silo after the call.
    function _updateSilosList(IERC4626 _silo, uint256 _oldAllocation, uint256 _newAllocation) internal {
        uint256 silosLength = s_silos.length;

        if (_oldAllocation > 0 && _newAllocation == 0) {
            for (uint256 i = 0; i < silosLength; i++) {
                if (address(s_silos[i]) == address(_silo)) {
                    s_silos[i] = s_silos[silosLength - 1];
                    s_silos.pop();
                    break;
                }
            }
        } else if (_oldAllocation == 0 && _newAllocation > 0) {
            s_silos.push(_silo);
        }
    }

    /// @notice Gets the total amount of assets held by this adapter across all tracked silos.
    /// @dev Returns the sum of `previewRedeem(balanceOf(this))` over all tracked silos.
    /// @return The total real assets held by this adapter across tracked silos.
    function realAssets() external view returns (uint256) {
        uint256 silosLength = s_silos.length;
        uint256 amountRealAssets;

        for (uint256 i = 0; i < silosLength; ++i) {
            amountRealAssets += s_silos[i].previewRedeem(s_silos[i].balanceOf(address(this)));
        }

        return amountRealAssets;
    }

    /// @notice Gets the Silo factory address used for Silo validation.
    /// @return The Silo factory address.
    function getSiloFactory() external view returns (address) {
        return address(i_siloFactory);
    }

    /// @notice Gets the number of tracked silos with a non-zero position.
    /// @return The number of tracked silos.
    function getSilosListLength() external view returns (uint256) {
        return s_silos.length;
    }

    /// @notice Gets the Silo address at index `_index` in the tracked silos list.
    /// @param _index The array index.
    /// @return The Silo address at the given index.
    function getSilo(uint256 _index) external view returns (address) {
        return address(s_silos[_index]);
    }

    /// @notice Gets all the IDs associated with the given Silo.
    /// @param _silo The Silo address.
    /// @return A list of bytes32 IDs.
    function getIds(address _silo) public view returns (bytes32[] memory) {
        bytes32[] memory ids = new bytes32[](2);
        ids[0] = i_adapterId;
        ids[1] = keccak256(abi.encode("this/pool", address(this), _silo));

        return ids;
    }

    /// @notice Gets the assets allocated to the given Silo according to the parent vault's accounting.
    /// @dev This value is only updated by the parent vault at the end of its `allocate()` and `deallocate()` calls.
    /// @param _silo The Silo address.
    /// @return The amount allocated to the Silo according to the parent vault.
    function getAllocation(address _silo) public view returns (uint256) {
        return i_morphoVaultV2.allocation(getIds(_silo)[1]);
    }
}
