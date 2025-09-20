// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IAToken } from "@src/adapters/lending/aaveV3/lib/interfaces/IAToken.sol";

import { AaveV3AdapterBaseTest } from "@test/lending/aaveV3/utils/AaveV3AdapterBaseTest.sol";

contract AaveV3AdapterMiscellaneousTests is AaveV3AdapterBaseTest {
    bytes internal s_data;
    uint256 internal s_amount;
    uint256 internal s_usdcDelta;

    function setUp() public override {
        super.setUp();

        s_data = abi.encode(address(s_pool));
        s_amount = 100 * s_assetDecimalsScalingFactor;
        s_usdcDelta = (1 * s_assetDecimalsScalingFactor) / 100;
    }

    function test_checkRealAssets() external {
        IAToken aToken = IAToken(s_pool.getReserveData(address(s_asset)).aTokenAddress);

        // Check when aToken balance is 0
        assertEq(aToken.balanceOf(address(s_adapter)), s_adapter.realAssets());

        vm.prank(s_allocator);
        s_vault.allocate(address(s_adapter), s_data, s_amount);

        assertEq(aToken.balanceOf(address(s_adapter)), s_adapter.realAssets());
    }

    function test_checkPoolAddressesProviderRegistry() external view {
        assertEq(s_adapter.getPoolAddressesProviderRegistry(), address(s_poolAddressesProviderRegistry));
    }

    function test_checkPoolList() external {
        vm.expectRevert();
        s_adapter.getPool(0);

        vm.prank(s_allocator);
        s_vault.allocate(address(s_adapter), s_data, s_amount);

        assertEq(s_adapter.getPoolsListLength(), 1);
        assertEq(s_adapter.getPool(0), address(s_pool));
    }

    function test_checkIds() external view {
        bytes32[] memory ids = s_adapter.getIds(address(s_pool));
        assertEq(ids[0], s_adapter.getAdapterId());
        assertEq(ids[1], keccak256(abi.encode("this/pool", address(s_adapter), address(s_pool))));
    }

    function test_checkAllocation() external {
        vm.prank(s_allocator);
        s_vault.allocate(address(s_adapter), s_data, s_amount);

        assertApproxEqAbs(s_adapter.getAllocation(address(s_pool)), s_amount, s_usdcDelta);
    }
}
