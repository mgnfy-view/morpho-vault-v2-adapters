// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "@openzeppelin-contracts-5.3.0/token/ERC20/IERC20.sol";

import { IAaveV3Adapter } from "@src/lending/aaveV3/interfaces/IAaveV3Adapter.sol";
import { IPool } from "@src/lending/aaveV3/lib/interfaces/IPool.sol";

import { IPoolAddressesProvider } from "@src/lending/aaveV3/lib/interfaces/IPoolAddressesProvider.sol";
import { IPoolAddressesProviderRegistry } from "@src/lending/aaveV3/lib/interfaces/IPoolAddressesProviderRegistry.sol";

import { AdapterBase } from "@src/adapterBase/AdapterBase.sol";

contract AaveV3Adapter is AdapterBase, IAaveV3Adapter {
    /// @dev Registry for pool addresses providers.
    IPoolAddressesProviderRegistry internal immutable i_poolAddressesProviderRegstry;
    /// @dev List of Aave V3 pools to supply tokens to.
    IPool[] internal s_pools;

    /// @notice Initializes the contract.
    /// @param _morphoVaultV2 The Morpho vault v2 contract.
    /// @param _initialSkimRecipient Can skim reward tokens sent to this contract.
    /// @param _poolAddressesProviderRegstry Registry for pool addresses providers.
    constructor(
        address _morphoVaultV2,
        address _initialSkimRecipient,
        address _poolAddressesProviderRegstry
    )
        AdapterBase(_morphoVaultV2, _initialSkimRecipient)
    {
        i_poolAddressesProviderRegstry = IPoolAddressesProviderRegistry(_poolAddressesProviderRegstry);
    }

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

        (address poolAddressesProvider, address asset) = abi.decode(_data, (address, address));
        IPool pool = IPool(IPoolAddressesProvider(poolAddressesProvider).getPool());

        _requireIsAcceptedAsset(asset);
        _requireValidPoolAddressesProvider(poolAddressesProvider);

        if (_assets > 0) {
            pool.supply(asset, _assets, address(this), 0);
        }

        uint256 oldAllocation = allocation(address(pool));
        IERC20 aToken = IERC20(pool.getReserveData(asset).aTokenAddress);
        uint256 newAllocation = aToken.balanceOf(address(this));
        _updatePoolsList(pool, oldAllocation, newAllocation);

        return (getIds(address(pool)), int256(newAllocation) - int256(oldAllocation));
    }

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

        (address poolAddressesProvider, address asset) = abi.decode(_data, (address, address));
        IPool pool = IPool(IPoolAddressesProvider(poolAddressesProvider).getPool());

        _requireIsAcceptedAsset(asset);
        _requireValidPoolAddressesProvider(poolAddressesProvider);

        if (_assets > 0) {
            pool.withdraw(asset, _assets, address(this));
        }

        uint256 oldAllocation = allocation(address(pool));
        IERC20 aToken = IERC20(pool.getReserveData(asset).aTokenAddress);
        uint256 newAllocation = aToken.balanceOf(address(this));
        _updatePoolsList(pool, oldAllocation, newAllocation);

        return (getIds(address(pool)), int256(newAllocation) - int256(oldAllocation));
    }

    function _requireValidPoolAddressesProvider(address _poolAddressesProvider) internal view {
        address[] memory poolAddressesProviders = i_poolAddressesProviderRegstry.getAddressesProvidersList();
        uint256 length = poolAddressesProviders.length;
        bool isValid;

        for (uint256 i; i < length; ++i) {
            if (_poolAddressesProvider == poolAddressesProviders[i]) {
                isValid = true;
                break;
            }
        }

        if (!isValid) revert AaveV3Adapter__InvalidPoolAddressesProvider(_poolAddressesProvider);
    }

    function _updatePoolsList(IPool _pool, uint256 _oldAllocation, uint256 _newAllocation) internal {
        uint256 poolAddressesArrayLength = s_pools.length;

        if (_oldAllocation > 0 && _newAllocation == 0) {
            for (uint256 i = 0; i < poolAddressesArrayLength; i++) {
                if (s_pools[i] == _pool) {
                    s_pools[i] = s_pools[poolAddressesArrayLength - 1];
                    s_pools.pop();
                    break;
                }
            }
        } else if (_oldAllocation == 0 && _newAllocation > 0) {
            s_pools.push(_pool);
        }
    }

    function realAssets() external view returns (uint256) {
        uint256 poolAddressesArrayLength = s_pools.length;
        uint256 amountRealAssets;

        for (uint256 i = 0; i < poolAddressesArrayLength; ++i) {
            IERC20 aToken = IERC20(s_pools[i].getReserveData(i_asset).aTokenAddress);
            amountRealAssets += aToken.balanceOf(address(this));
        }

        return amountRealAssets;
    }

    function getIds(address _pool) public view returns (bytes32[] memory) {
        bytes32[] memory ids = new bytes32[](2);
        ids[0] = i_adapterId;
        ids[1] = keccak256(abi.encode("this/pool", address(this), _pool));

        return ids;
    }

    function allocation(address _pool) public view returns (uint256) {
        return i_morphoVaultV2.allocation(getIds(_pool)[1]);
    }
}
