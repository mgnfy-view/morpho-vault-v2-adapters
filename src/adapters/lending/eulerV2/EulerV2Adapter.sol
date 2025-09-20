// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IEulerV2Adapter } from "@src/adapters/lending/eulerV2/interfaces/IEulerV2Adapter.sol";
import { IEVault } from "@src/adapters/lending/eulerV2/lib/interfaces/IEVault.sol";
import { IEVaultFactory } from "@src/adapters/lending/eulerV2/lib/interfaces/IEVaultFactory.sol";

import { AdapterBase } from "@src/adapterBase/AdapterBase.sol";

/// @title EulerV2Adapter.
/// @author mgnfy-view.
/// @notice Euler v2 adapter for Morpho vault v2. This adapter uses two functions `supply` and
/// `withdraw` to allocate to and deallocate from Euler v2 vaults respectively.
contract EulerV2Adapter is AdapterBase, IEulerV2Adapter {
    /// @dev The Euler v2 vault factory that deploys Euler vault proxies.
    IEVaultFactory internal immutable i_evaultFactory;
    /// @dev List of Euler v2 vaults to supply tokens to.
    IEVault[] internal s_vaults;

    /// @dev Initializes the contract.
    /// @param _morphoVaultV2 The Morpho vault v2 contract.
    /// @param _factory The Euler v2 vault factory that deploys Euler vault proxies.
    constructor(address _morphoVaultV2, address _factory) AdapterBase(_morphoVaultV2) {
        i_evaultFactory = IEVaultFactory(_factory);
    }

    /// @notice Supplies assets to the given Euler v2 vault.
    /// @param _data Abi encoded vault address.
    /// @param _assets The amount of assets to supply.
    /// @return A list of IDs associated with the Euler v2 vault.
    /// @return The delta change in the amount of assets held by this adapter.
    function allocate(
        bytes memory _data,
        uint256 _assets,
        bytes4,
        address
    )
        external
        returns (bytes32[] memory, int256)
    {
        _requireCallerIsMorphoVault(msg.sender);

        (address vaultAddr) = abi.decode(_data, (address));
        IEVault vault = IEVault(vaultAddr);

        _requireValidEVault(vault);

        if (_assets > 0) {
            i_asset.approve(vaultAddr, _assets);
            vault.deposit(_assets, address(this));
        }

        uint256 oldAllocation = getAllocation(vaultAddr);
        uint256 shares = vault.balanceOf(address(this));
        uint256 newAllocation = vault.convertToAssets(shares);
        _updateVaultsList(vault, oldAllocation, newAllocation);

        // forge-lint: disable-next-line(unsafe-typecast)
        return (getIds(vaultAddr), int256(newAllocation) - int256(oldAllocation));
    }

    /// @notice Withdraws assets from the given Euler v2 pool.
    /// @param _data Abi encoded Euler v2 pool address.
    /// @param _assets The amount of assets to withdraw.
    /// @return A list of IDs associated with the Euler v2 pool.
    /// @return The delta change in the amount of assets held by this adapter.
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

        (address vaultAddr) = abi.decode(_data, (address));
        IEVault vault = IEVault(vaultAddr);

        _requireValidEVault(vault);

        if (_assets > 0) {
            vault.withdraw(_assets, address(this), address(this));
        }

        uint256 oldAllocation = getAllocation(vaultAddr);
        uint256 shares = vault.balanceOf(address(this));
        uint256 newAllocation = vault.convertToAssets(shares);
        _updateVaultsList(vault, oldAllocation, newAllocation);

        // forge-lint: disable-next-line(unsafe-typecast)
        return (getIds(vaultAddr), int256(newAllocation) - int256(oldAllocation));
    }

    /// @dev Reverts if the given EVault is not a valid one. An EVault is not valid if it
    /// was not deployed by the trusted EVault factory.
    /// @param _vault The Euler v2 vault.
    function _requireValidEVault(IEVault _vault) internal view {
        if (!i_evaultFactory.isProxy(address(_vault))) {
            revert EulerV2Adapter__InvalidEVault();
        }
    }

    /// @dev Updates the list of Euler v2 vaults the adapter has supplied to. If the allocation to a
    /// pool becomes 0, the pool is popped from the list.
    /// @param _vault The vault to add/pop. Or no-op if allocation is greater than 0 and the vaullt address
    /// is already in the list.
    /// @param _oldAllocation The amount of assets held by the adapter in the given pool before the
    /// allocate/deallocate call.
    /// @param _newAllocation The amount of assets held by the adapter in the given pool after the
    /// allocate/deallocate call.
    function _updateVaultsList(IEVault _vault, uint256 _oldAllocation, uint256 _newAllocation) internal {
        uint256 vaultAddressesArrayLength = s_vaults.length;

        if (_oldAllocation > 0 && _newAllocation == 0) {
            for (uint256 i = 0; i < vaultAddressesArrayLength; i++) {
                if (s_vaults[i] == _vault) {
                    s_vaults[i] = s_vaults[vaultAddressesArrayLength - 1];
                    s_vaults.pop();
                    break;
                }
            }
        } else if (_oldAllocation == 0 && _newAllocation > 0) {
            s_vaults.push(_vault);
        }
    }

    /// @notice Gets the total amount of assets held by this adapter in Euler v2 pools.
    /// @return Real assets held by this adapter in Euler v2 pools.
    function realAssets() external view returns (uint256) {
        uint256 vaultAddressesArrayLength = s_vaults.length;
        uint256 amountRealAssets;

        for (uint256 i = 0; i < vaultAddressesArrayLength; ++i) {
            uint256 shares = s_vaults[i].balanceOf(address(this));
            amountRealAssets += s_vaults[i].convertToAssets(shares);
        }

        return amountRealAssets;
    }

    /// @notice Gets the EVault factory address.
    /// @return The EVault factory address.
    function getEVaultFactory() external view returns (address) {
        return address(i_evaultFactory);
    }

    /// @notice Gets the number of vaults this adapter has supplied tokens to.
    /// @return The number of vaults this adapter has supplied tokens to.
    function getVaultsListLength() external view returns (uint256) {
        return s_vaults.length;
    }

    /// @notice Gets the vault address at the given index in the active vaults list.
    /// @param _index The array index.
    /// @return The vault address at the given index.
    function getVault(uint256 _index) external view returns (address) {
        return address(s_vaults[_index]);
    }

    /// @notice Gets all the IDs associated with the given Euler v2 pool.
    /// @param _vault The Euler v2 vault address.
    /// @return A list of bytes32 IDs.
    function getIds(address _vault) public view returns (bytes32[] memory) {
        bytes32[] memory ids = new bytes32[](2);
        ids[0] = i_adapterId;
        ids[1] = keccak256(abi.encode("this/pool", address(this), _vault));

        return ids;
    }

    /// @notice Gets the assets allocated to the given EUler v2 vault.
    /// @param _vault The Euler v2 vault address.
    /// @return The amount allocated to the comet instance.
    function getAllocation(address _vault) public view returns (uint256) {
        return i_morphoVaultV2.allocation(getIds(_vault)[1]);
    }
}
