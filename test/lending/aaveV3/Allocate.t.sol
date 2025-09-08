// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IAToken } from "@src/adapters/lending/aaveV3/lib/interfaces/IAToken.sol";

import { IAdapterBase } from "@src/adapterBase/interfaces/IAdapterBase.sol";
import { IAaveV3Adapter } from "@src/adapters/lending/aaveV3/interfaces/IAaveV3Adapter.sol";
import { IOwnable } from "@test/utils/interfaces/IOwnable.sol";

import { AaveV3AdapterBaseTest } from "@test/lending/aaveV3/utils/AaveV3AdapterBaseTest.sol";

contract AaveV3AdapterAllocateTests is AaveV3AdapterBaseTest {
    bytes internal s_data;
    uint256 internal s_amount;
    uint256 internal s_usdcDelta;

    function setUp() public override {
        super.setUp();

        s_data = abi.encode(address(s_pool));
        s_amount = 10_000 * s_assetDecimalsScalingFactor;
        s_usdcDelta = (1 * s_assetDecimalsScalingFactor) / 100;
    }

    function test_onlyParentVaultCanAllocate() external {
        vm.prank(s_allocator);
        vm.expectRevert(IAdapterBase.AdapterBase__NotMorphoVault.selector);
        s_adapter.allocate(s_data, s_amount, bytes4(0), address(0));
    }

    function test_canAllocateToValidPoolOnly() external {
        address owner = IOwnable(address(s_poolAddressesProviderRegistry)).owner();
        address poolAddressesProvider = address(s_pool.ADDRESSES_PROVIDER());
        vm.prank(owner);
        s_poolAddressesProviderRegistry.unregisterAddressesProvider(poolAddressesProvider);

        vm.prank(s_allocator);
        vm.expectRevert(abi.encodeWithSelector(IAaveV3Adapter.AaveV3Adapter__InvalidPool.selector, address(s_pool)));
        s_vault.allocate(address(s_adapter), s_data, s_amount);
    }

    function test_allocatingSucceeds() external {
        vm.prank(s_allocator);
        s_vault.allocate(address(s_adapter), s_data, s_amount);

        IAToken aToken = IAToken(s_pool.getReserveData(address(s_asset)).aTokenAddress);
        address pool = s_adapter.getPool(0);

        assertEq(s_asset.balanceOf(address(s_adapter)), 0);
        assertApproxEqAbs(aToken.balanceOf(address(s_adapter)), s_amount, s_usdcDelta);
        assertEq(pool, address(s_pool));
    }

    function test_allocatingEntireVaultLiquiditySucceeds() external {
        uint256 amount = s_asset.balanceOf(address(s_vault));

        vm.prank(s_allocator);
        s_vault.allocate(address(s_adapter), s_data, amount);

        IAToken aToken = IAToken(s_pool.getReserveData(address(s_asset)).aTokenAddress);
        address pool = s_adapter.getPool(0);

        assertEq(s_asset.balanceOf(address(s_adapter)), 0);
        assertApproxEqAbs(aToken.balanceOf(address(s_adapter)), amount, s_usdcDelta);
        assertEq(pool, address(s_pool));
    }
}
