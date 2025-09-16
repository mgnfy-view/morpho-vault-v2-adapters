// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { CompoundV3AdapterBaseTest } from "@test/lending/compoundV3/utils/CompoundV3AdapterBaseTest.sol";

contract CompoundV3AdapterMiscellaneousTests is CompoundV3AdapterBaseTest {
    bytes internal s_data;
    uint256 internal s_amount;
    uint256 internal s_usdcDelta;

    function setUp() public override {
        super.setUp();

        s_data = abi.encode(address(s_comet));
        s_amount = 10_000 * s_assetDecimalsScalingFactor;
        s_usdcDelta = (1 * s_assetDecimalsScalingFactor) / 100;
    }

    function test_checkRealAssets() external {
        // Check when aToken balance is 0
        assertEq(s_comet.balanceOf(address(s_adapter)), s_adapter.realAssets());

        vm.prank(s_allocator);
        s_vault.allocate(address(s_adapter), s_data, s_amount);

        assertEq(s_comet.balanceOf(address(s_adapter)), s_adapter.realAssets());
    }

    function test_checkConfigurator() external view {
        assertEq(s_adapter.getConfigurator(), s_configurator);
    }

    function test_checkCometsList() external {
        vm.expectRevert();
        s_adapter.getComet(0);

        vm.prank(s_allocator);
        s_vault.allocate(address(s_adapter), s_data, s_amount);

        assertEq(s_adapter.getCometsListLength(), 1);
        assertEq(s_adapter.getComet(0), address(s_comet));
    }

    function test_checkIds() external view {
        bytes32[] memory ids = s_adapter.getIds(address(s_comet));
        assertEq(ids[0], s_adapter.getAdapterId());
        assertEq(ids[1], keccak256(abi.encode("this/pool", address(s_adapter), address(s_comet))));
    }

    function test_checkAllocation() external {
        vm.prank(s_allocator);
        s_vault.allocate(address(s_adapter), s_data, s_amount);

        assertApproxEqAbs(s_adapter.getAllocation(address(s_comet)), s_amount, s_usdcDelta);
    }
}
