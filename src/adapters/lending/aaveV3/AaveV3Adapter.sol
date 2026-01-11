// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IAaveV3Adapter } from "@src/adapters/lending/aaveV3/interfaces/IAaveV3Adapter.sol";
import { IAToken } from "@src/adapters/lending/aaveV3/lib/interfaces/IAToken.sol";
import { IPool } from "@src/adapters/lending/aaveV3/lib/interfaces/IPool.sol";
import {
    IPoolAddressesProviderRegistry
} from "@src/adapters/lending/aaveV3/lib/interfaces/IPoolAddressesProviderRegistry.sol";

import { AdapterBase } from "@src/adapterBase/AdapterBase.sol";

/// @title AaveV3Adapter.
/// @author mgnfy-view.
/// @notice Morpho Vault v2 adapter that allocates assets to Aave v3 pools using supply/withdraw.
/// @dev Positions are tracked via aToken balances, and pools are validated against the registry.
contract AaveV3Adapter is AdapterBase, IAaveV3Adapter {
    /// @dev Registry of Aave v3 pool addresses providers used for pool validation.
    IPoolAddressesProviderRegistry internal immutable i_poolAddressesProviderRegstry;
    /// @dev List of Aave v3 pools with a non-zero allocation.
    IPool[] internal s_pools;

    /// @dev Initializes the contract.
    /// @param _morphoVaultV2 The Morpho Vault v2 contract.
    /// @param _poolAddressesProviderRegstry Registry for pool addresses providers.
    constructor(address _morphoVaultV2, address _poolAddressesProviderRegstry) AdapterBase(_morphoVaultV2) {
        i_poolAddressesProviderRegstry = IPoolAddressesProviderRegistry(_poolAddressesProviderRegstry);
    }

    /// @notice Supplies assets to the given Aave v3 pool.
    /// @dev `_data` must be `abi.encode(address poolAddr)`.
    /// @param _data Abi encoded Aave v3 pool address.
    /// @param _assets The amount of assets to supply.
    /// @return A list of IDs associated with the Aave v3 pool.
    /// @return The delta change in the amount of assets held by this adapter for the vault.
    function allocate(bytes memory _data, uint256 _assets, bytes4, address)
        external
        returns (bytes32[] memory, int256)
    {
        _requireCallerIsMorphoVault(msg.sender);

        (address poolAddr) = abi.decode(_data, (address));
        IPool pool = IPool(poolAddr);
        IAToken aToken = IAToken(pool.getReserveData(address(i_asset)).aTokenAddress);

        _requireValidPool(pool);

        if (_assets > 0) {
            i_asset.approve(poolAddr, _assets);
            pool.supply(address(i_asset), _assets, address(this), 0);
        }

        uint256 oldAllocation = getAllocation(poolAddr);
        uint256 newAllocation = aToken.balanceOf(address(this));
        _updatePoolsList(pool, oldAllocation, newAllocation);

        // forge-lint: disable-next-line(unsafe-typecast)
        return (getIds(poolAddr), int256(newAllocation) - int256(oldAllocation));
    }

    /// @notice Withdraws assets from the given Aave v3 pool.
    /// @dev `_data` must be `abi.encode(address poolAddr)`.
    /// @param _data Abi encoded Aave v3 pool address.
    /// @param _assets The amount of assets to withdraw.
    /// @return A list of IDs associated with the Aave v3 pool.
    /// @return The delta change in the amount of assets held by this adapter for the vault.
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

        (address poolAddr) = abi.decode(_data, (address));
        IPool pool = IPool(poolAddr);
        IAToken aToken = IAToken(pool.getReserveData(address(i_asset)).aTokenAddress);

        if (_assets > 0) {
            pool.withdraw(address(i_asset), _assets, address(this));
        }

        uint256 oldAllocation = getAllocation(poolAddr);
        uint256 newAllocation = aToken.balanceOf(address(this));
        _updatePoolsList(pool, oldAllocation, newAllocation);

        // forge-lint: disable-next-line(unsafe-typecast)
        return (getIds(poolAddr), int256(newAllocation) - int256(oldAllocation));
    }

    /// @dev Reverts if the given pool is not a valid Aave v3 pool. A pool is valid when its
    /// addresses provider is registered in the pool addresses providers registry.
    /// @param _pool The pool to check.
    function _requireValidPool(IPool _pool) internal view {
        address[] memory poolAddressesProviders = i_poolAddressesProviderRegstry.getAddressesProvidersList();
        uint256 poolAddressesProvidersLength = poolAddressesProviders.length;
        address poolAddressesProvider = address(_pool.ADDRESSES_PROVIDER());
        bool isValid;

        for (uint256 i; i < poolAddressesProvidersLength; ++i) {
            if (poolAddressesProvider == poolAddressesProviders[i]) {
                isValid = true;
                break;
            }
        }

        if (!isValid) revert AaveV3Adapter__InvalidPool(address(_pool));
    }

    /// @dev Updates the list of Aave v3 pools with a non-zero allocation.
    /// @param _pool The pool to add/pop. Or no-op if allocation is greater than 0 and the pool address
    /// is already in the list.
    /// @param _oldAllocation The amount of assets held by the adapter in the given pool before the
    /// allocate/deallocate call.
    /// @param _newAllocation The amount of assets held by the adapter in the given pool after the
    /// allocate/deallocate call.
    function _updatePoolsList(IPool _pool, uint256 _oldAllocation, uint256 _newAllocation) internal {
        uint256 poolAddressesArrayLength = s_pools.length;

        if (_oldAllocation > 0 && _newAllocation == 0) {
            for (uint256 i = 0; i < poolAddressesArrayLength; i++) {
                if (address(s_pools[i]) == address(_pool)) {
                    s_pools[i] = s_pools[poolAddressesArrayLength - 1];
                    s_pools.pop();
                    break;
                }
            }
        } else if (_oldAllocation == 0 && _newAllocation > 0) {
            s_pools.push(_pool);
        }
    }

    /// @notice Gets the total amount of assets held by this adapter across tracked Aave v3 pools.
    /// @dev Returns the sum of aToken balances across tracked pools.
    /// @return Real assets held by this adapter in Aave v3 pools.
    function realAssets() external view returns (uint256) {
        uint256 poolAddressesArrayLength = s_pools.length;
        uint256 amountRealAssets;

        for (uint256 i = 0; i < poolAddressesArrayLength; ++i) {
            IAToken aToken = IAToken(s_pools[i].getReserveData(address(i_asset)).aTokenAddress);
            amountRealAssets += aToken.balanceOf(address(this));
        }

        return amountRealAssets;
    }

    /// @notice Gets the pool addresses provider registry address used for validation.
    /// @return The pool addresses provider registry address.
    function getPoolAddressesProviderRegistry() external view returns (address) {
        return address(i_poolAddressesProviderRegstry);
    }

    /// @notice Gets the number of Aave v3 pools with non-zero allocation.
    /// @return The number of tracked pools.
    function getPoolsListLength() external view returns (uint256) {
        return s_pools.length;
    }

    /// @notice Gets the pool address at the given index in the tracked pools list.
    /// @param _index The array index.
    /// @return The pool address at the given index.
    function getPool(uint256 _index) external view returns (address) {
        return address(s_pools[_index]);
    }

    /// @notice Gets all the IDs associated with the given Aave v3 pool.
    /// @param _pool The Aave v3 pool address.
    /// @return A list of bytes32 IDs.
    function getIds(address _pool) public view returns (bytes32[] memory) {
        bytes32[] memory ids = new bytes32[](2);
        ids[0] = i_adapterId;
        ids[1] = keccak256(abi.encode("this/pool", address(this), _pool));

        return ids;
    }

    /// @notice Gets the assets allocated to the given Aave v3 pool according to the parent vault.
    /// @dev This value is updated by the parent vault at the end of allocate/deallocate calls.
    /// @param _pool The Aave v3 pool address.
    /// @return The amount allocated to the pool.
    function getAllocation(address _pool) public view returns (uint256) {
        return i_morphoVaultV2.allocation(getIds(_pool)[1]);
    }
}
