// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IAdapterBase } from "@src/adapterBase/interfaces/IAdapterBase.sol";
import { IEulerV2Adapter } from "@src/adapters/lending/eulerV2/interfaces/IEulerV2Adapter.sol";

import { EulerV2AdapterBaseTest } from "@test/lending/eulerV2/utils/EulerV2AdapterBaseTest.sol";

contract EulerV2AdapterAllocateTests is EulerV2AdapterBaseTest {
    bytes internal s_data;
    uint256 internal s_amount;
    uint256 internal s_usdcDelta;

    function setUp() public override {
        super.setUp();

        s_data = abi.encode(address(s_evault1));
        s_amount = 100 * s_assetDecimalsScalingFactor;
        s_usdcDelta = (1 * s_assetDecimalsScalingFactor) / 100;
    }

    function test_onlyParentVaultCanAllocate() external {
        vm.prank(s_allocator);
        vm.expectRevert(IAdapterBase.AdapterBase__NotMorphoVault.selector);
        s_adapter.allocate(s_data, s_amount, bytes4(0), address(0));
    }

    function test_canAllocateToValidEVaultOnly() external {
        address invalidEVault = makeAddr("invalidEVault");

        vm.prank(s_allocator);
        vm.expectRevert(IEulerV2Adapter.EulerV2Adapter__InvalidEVault.selector);
        s_vault.allocate(address(s_adapter), abi.encode(invalidEVault), s_amount);
    }

    function test_allocatingSucceeds() external {
        vm.prank(s_allocator);
        s_vault.allocate(address(s_adapter), s_data, s_amount);

        assertEq(s_asset.balanceOf(address(s_adapter)), 0);
        assertApproxEqAbs(_getEVaultUnderlyingBalance(s_evault1, address(s_adapter)), s_amount, s_usdcDelta);
        assertEq(s_adapter.getVaultsListLength(), 1);
        assertEq(s_adapter.getVault(0), address(s_evault1));
    }

    function test_allocatingEntireVaultLiquiditySucceeds() external {
        uint256 amount = s_asset.balanceOf(address(s_vault));

        vm.prank(s_allocator);
        s_vault.allocate(address(s_adapter), s_data, amount);

        address evault = s_adapter.getVault(0);
        assertEq(s_asset.balanceOf(address(s_adapter)), 0);
        assertApproxEqAbs(_getEVaultUnderlyingBalance(s_evault1, address(s_adapter)), amount, s_usdcDelta);
        assertEq(s_adapter.getVaultsListLength(), 1);
        assertEq(evault, address(s_evault1));
    }

    function test_canAllocateToMultipleEVaults() external {
        uint256 amount = s_amount / 2;

        vm.startPrank(s_allocator);
        s_vault.allocate(address(s_adapter), s_data, amount);
        s_vault.allocate(address(s_adapter), abi.encode(address(s_evault2)), amount);
        vm.stopPrank();

        assertEq(s_asset.balanceOf(address(s_adapter)), 0);
        assertApproxEqAbs(_getEVaultUnderlyingBalance(s_evault1, address(s_adapter)), amount, s_usdcDelta);
        assertApproxEqAbs(_getEVaultUnderlyingBalance(s_evault2, address(s_adapter)), amount, s_usdcDelta);
        assertEq(s_adapter.getVaultsListLength(), 2);
        assertEq(s_adapter.getVault(0), address(s_evault1));
        assertEq(s_adapter.getVault(1), address(s_evault2));
    }
}
