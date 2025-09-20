// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { EulerV2AdapterBaseTest } from "@test/lending/eulerV2/utils/EulerV2AdapterBaseTest.sol";

contract EulerV2AdapterMiscellaneousTests is EulerV2AdapterBaseTest {
    bytes internal s_data;
    uint256 internal s_amount;
    uint256 internal s_usdcDelta;

    function setUp() public override {
        super.setUp();

        s_data = abi.encode(address(s_evault1));
        s_amount = 100 * s_assetDecimalsScalingFactor;
        s_usdcDelta = (1 * s_assetDecimalsScalingFactor) / 100;
    }

    function test_checkRealAssets() external {
        // Check when aToken balance is 0
        assertEq(_getEVaultUnderlyingBalance(s_evault1, address(s_adapter)), s_adapter.realAssets());

        vm.prank(s_allocator);
        s_vault.allocate(address(s_adapter), s_data, s_amount);

        assertEq(_getEVaultUnderlyingBalance(s_evault1, address(s_adapter)), s_adapter.realAssets());
    }

    function test_checkEVaultFactory() external view {
        assertEq(s_adapter.getEVaultFactory(), address(s_evaultFactory));
    }

    function test_checkVaultsList() external {
        vm.expectRevert();
        s_adapter.getVault(0);

        vm.prank(s_allocator);
        s_vault.allocate(address(s_adapter), s_data, s_amount);

        assertEq(s_adapter.getVaultsListLength(), 1);
        assertEq(s_adapter.getVault(0), address(s_evault1));
    }

    function test_checkIds() external view {
        bytes32[] memory ids = s_adapter.getIds(address(s_evault1));
        assertEq(ids[0], s_adapter.getAdapterId());
        assertEq(ids[1], keccak256(abi.encode("this/pool", address(s_adapter), address(s_evault1))));
    }

    function test_checkAllocation() external {
        vm.prank(s_allocator);
        s_vault.allocate(address(s_adapter), s_data, s_amount);

        assertApproxEqAbs(s_adapter.getAllocation(address(s_evault1)), s_amount, s_usdcDelta);
    }
}
