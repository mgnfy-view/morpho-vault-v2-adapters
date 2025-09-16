// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IAdapterBase } from "@src/adapterBase/interfaces/IAdapterBase.sol";

import { CompoundV3AdapterBaseTest } from "@test/lending/compoundV3/utils/CompoundV3AdapterBaseTest.sol";

contract CompoundV3AdapterDeallocateTests is CompoundV3AdapterBaseTest {
    bytes internal s_data;
    uint256 internal s_amount;
    uint256 internal s_usdcDelta;

    function setUp() public override {
        super.setUp();

        s_data = abi.encode(address(s_comet));
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
        uint256 adapterSupplyBalanceBefore = s_comet.balanceOf(address(s_adapter));
        uint256 adapterAssetBalanceBefore = s_asset.balanceOf(address(s_adapter));
        uint256 vaultAssetBalanceBefore = s_asset.balanceOf(address(s_vault));

        vm.prank(s_allocator);
        s_vault.deallocate(address(s_adapter), s_data, s_amount);

        uint256 adapterSupplyBalanceAfter = s_comet.balanceOf(address(s_adapter));
        uint256 adapterAssetBalanceAfter = s_asset.balanceOf(address(s_adapter));
        uint256 vaultAssetBalanceAfter = s_asset.balanceOf(address(s_vault));
        assertEq(adapterAssetBalanceBefore - adapterAssetBalanceAfter, 0);
        assertApproxEqAbs(vaultAssetBalanceAfter - vaultAssetBalanceBefore, s_amount, s_usdcDelta);
        assertApproxEqAbs(adapterSupplyBalanceBefore - adapterSupplyBalanceAfter, s_amount, s_usdcDelta);
    }

    function test_deallocatingEntireVaultLiquiditySucceeds() external {
        uint256 amount = s_comet.balanceOf(address(s_adapter));
        uint256 adapterSupplyBalanceBefore = s_comet.balanceOf(address(s_adapter));
        uint256 adapterAssetBalanceBefore = s_asset.balanceOf(address(s_adapter));
        uint256 vaultAssetBalanceBefore = s_asset.balanceOf(address(s_vault));
        vm.prank(s_allocator);
        s_vault.deallocate(address(s_adapter), s_data, amount);

        // The comet instance has been popped off the active comets list
        vm.expectRevert();
        s_adapter.getComet(0);

        uint256 adapterSupplyBalanceAfter = s_comet.balanceOf(address(s_adapter));
        uint256 adapterAssetBalanceAfter = s_asset.balanceOf(address(s_adapter));
        uint256 vaultAssetBalanceAfter = s_asset.balanceOf(address(s_vault));
        assertEq(adapterAssetBalanceBefore - adapterAssetBalanceAfter, 0);
        assertApproxEqAbs(vaultAssetBalanceAfter - vaultAssetBalanceBefore, amount, s_usdcDelta);
        assertEq(adapterSupplyBalanceBefore - adapterSupplyBalanceAfter, amount);
    }
}
