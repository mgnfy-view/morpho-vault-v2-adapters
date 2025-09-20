// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IAdapterBase } from "@src/adapterBase/interfaces/IAdapterBase.sol";
import { ICompoundV3Adapter } from "@src/adapters/lending/compoundV3/interfaces/ICompoundV3Adapter.sol";

import { CompoundV3AdapterBaseTest } from "@test/lending/compoundV3/utils/CompoundV3AdapterBaseTest.sol";

contract CompoundV3AdapterAllocateTests is CompoundV3AdapterBaseTest {
    bytes internal s_data;
    uint256 internal s_amount;
    uint256 internal s_usdcDelta;

    function setUp() public override {
        super.setUp();

        s_data = abi.encode(address(s_comet));
        s_amount = 100 * s_assetDecimalsScalingFactor;
        s_usdcDelta = (1 * s_assetDecimalsScalingFactor) / 100;
    }

    function test_onlyParentVaultCanAllocate() external {
        vm.prank(s_allocator);
        vm.expectRevert(IAdapterBase.AdapterBase__NotMorphoVault.selector);
        s_adapter.allocate(s_data, s_amount, bytes4(0), address(0));
    }

    function test_canAllocateToValidCometOnly() external {
        address invalidComet = makeAddr("invalidComet");

        vm.prank(s_allocator);
        vm.expectRevert(ICompoundV3Adapter.CompoundV3Adapter__InvalidCometInstance.selector);
        s_vault.allocate(address(s_adapter), abi.encode(invalidComet), s_amount);
    }

    function test_allocatingSucceeds() external {
        vm.prank(s_allocator);
        s_vault.allocate(address(s_adapter), s_data, s_amount);

        assertEq(s_asset.balanceOf(address(s_adapter)), 0);
        assertApproxEqAbs(s_comet.balanceOf(address(s_adapter)), s_amount, s_usdcDelta);
        assertEq(s_adapter.getCometsListLength(), 1);
        assertEq(s_adapter.getComet(0), address(s_comet));
    }

    function test_allocatingEntireVaultLiquiditySucceeds() external {
        uint256 amount = s_asset.balanceOf(address(s_vault));

        vm.prank(s_allocator);
        s_vault.allocate(address(s_adapter), s_data, amount);

        address comet = s_adapter.getComet(0);
        assertEq(s_asset.balanceOf(address(s_adapter)), 0);
        assertApproxEqAbs(s_comet.balanceOf(address(s_adapter)), amount, s_usdcDelta);
        assertEq(s_adapter.getCometsListLength(), 1);
        assertEq(comet, address(s_comet));
    }
}
