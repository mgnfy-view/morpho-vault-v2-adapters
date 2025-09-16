// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IAToken } from "@src/adapters/lending/aaveV3/lib/interfaces/IAToken.sol";

import { IAdapterBase } from "@src/adapterBase/interfaces/IAdapterBase.sol";
import { IOwnable } from "@test/utils/interfaces/IOwnable.sol";

import { AaveV3AdapterBaseTest } from "@test/lending/aaveV3/utils/AaveV3AdapterBaseTest.sol";

contract AaveV3AdapterDeallocateTests is AaveV3AdapterBaseTest {
    bytes internal s_data;
    uint256 internal s_amount;
    uint256 internal s_usdcDelta;

    function setUp() public override {
        super.setUp();

        s_data = abi.encode(address(s_pool));
        s_amount = 10_000 * s_assetDecimalsScalingFactor;
        s_usdcDelta = (1 * s_assetDecimalsScalingFactor) / 100;

        uint256 amount = s_asset.balanceOf(address(s_vault));
        vm.prank(s_allocator);
        s_vault.allocate(address(s_adapter), s_data, amount);
    }

    function test_onlyParentVaultCanDeallocate() external {
        vm.prank(s_allocator);
        vm.expectRevert(IAdapterBase.AdapterBase__NotMorphoVault.selector);
        s_adapter.deallocate(s_data, s_amount, bytes4(0), address(0));
    }

    function test_deallocatingSucceeds() external {
        IAToken aToken = IAToken(s_pool.getReserveData(address(s_asset)).aTokenAddress);
        uint256 adapterATokenBalanceBefore = aToken.balanceOf(address(s_adapter));
        uint256 adapterAssetBalanceBefore = s_asset.balanceOf(address(s_adapter));
        uint256 vaultAssetBalanceBefore = s_asset.balanceOf(address(s_vault));

        vm.prank(s_allocator);
        s_vault.deallocate(address(s_adapter), s_data, s_amount);

        uint256 adapterATokenBalanceAfter = aToken.balanceOf(address(s_adapter));
        uint256 adapterAssetBalanceAfter = s_asset.balanceOf(address(s_adapter));
        uint256 vaultAssetBalanceAfter = s_asset.balanceOf(address(s_vault));
        assertEq(adapterAssetBalanceBefore - adapterAssetBalanceAfter, 0);
        assertApproxEqAbs(vaultAssetBalanceAfter - vaultAssetBalanceBefore, s_amount, s_usdcDelta);
        assertApproxEqAbs(adapterATokenBalanceBefore - adapterATokenBalanceAfter, s_amount, s_usdcDelta);
    }

    function test_canDeallocateFromUnregisteredPool() external {
        IAToken aToken = IAToken(s_pool.getReserveData(address(s_asset)).aTokenAddress);
        uint256 adapterATokenBalanceBefore = aToken.balanceOf(address(s_adapter));
        uint256 adapterAssetBalanceBefore = s_asset.balanceOf(address(s_adapter));
        uint256 vaultAssetBalanceBefore = s_asset.balanceOf(address(s_vault));

        address owner = IOwnable(address(s_poolAddressesProviderRegistry)).owner();
        address poolAddressesProvider = address(s_pool.ADDRESSES_PROVIDER());
        vm.prank(owner);
        s_poolAddressesProviderRegistry.unregisterAddressesProvider(poolAddressesProvider);

        vm.prank(s_allocator);
        s_vault.deallocate(address(s_adapter), s_data, s_amount);

        uint256 adapterATokenBalanceAfter = aToken.balanceOf(address(s_adapter));
        uint256 adapterAssetBalanceAfter = s_asset.balanceOf(address(s_adapter));
        uint256 vaultAssetBalanceAfter = s_asset.balanceOf(address(s_vault));
        assertEq(adapterAssetBalanceBefore - adapterAssetBalanceAfter, 0);
        assertApproxEqAbs(vaultAssetBalanceAfter - vaultAssetBalanceBefore, s_amount, s_usdcDelta);
        assertApproxEqAbs(adapterATokenBalanceBefore - adapterATokenBalanceAfter, s_amount, s_usdcDelta);
    }

    function test_deallocatingEntireVaultLiquiditySucceeds() external {
        IAToken aToken = IAToken(s_pool.getReserveData(address(s_asset)).aTokenAddress);
        uint256 amount = aToken.balanceOf(address(s_adapter));
        uint256 adapterATokenBalanceBefore = aToken.balanceOf(address(s_adapter));
        uint256 adapterAssetBalanceBefore = s_asset.balanceOf(address(s_adapter));
        uint256 vaultAssetBalanceBefore = s_asset.balanceOf(address(s_vault));

        vm.prank(s_allocator);
        s_vault.deallocate(address(s_adapter), s_data, amount);

        // The pool has been popped off the active pools list
        vm.expectRevert();
        s_adapter.getPool(0);

        uint256 adapterATokenBalanceAfter = aToken.balanceOf(address(s_adapter));
        uint256 adapterAssetBalanceAfter = s_asset.balanceOf(address(s_adapter));
        uint256 vaultAssetBalanceAfter = s_asset.balanceOf(address(s_vault));
        assertEq(adapterAssetBalanceBefore - adapterAssetBalanceAfter, 0);
        assertApproxEqAbs(vaultAssetBalanceAfter - vaultAssetBalanceBefore, amount, s_usdcDelta);
        assertEq(adapterATokenBalanceBefore - adapterATokenBalanceAfter, amount);
    }
}
