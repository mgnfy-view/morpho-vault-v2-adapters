// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IAdapterBase } from "@src/adapterBase/interfaces/IAdapterBase.sol";

import { EulerV2AdapterBaseTest } from "@test/lending/eulerV2/utils/EulerV2AdapterBaseTest.sol";

contract EulerV2AdapterDeallocateTests is EulerV2AdapterBaseTest {
    bytes internal s_data;
    uint256 internal s_amount;
    uint256 internal s_usdcDelta;

    function setUp() public override {
        super.setUp();

        s_data = abi.encode(address(s_evault1));
        s_amount = 100 * s_assetDecimalsScalingFactor;
        s_usdcDelta = (1 * s_assetDecimalsScalingFactor) / 100;

        vm.startPrank(s_allocator);
        s_vault.allocate(address(s_adapter), s_data, s_amount);
        s_vault.allocate(address(s_adapter), abi.encode(address(s_evault2)), s_amount);
        vm.stopPrank();
    }

    function test_onlyParentVaultCanDeallocate() external {
        vm.prank(s_allocator);
        vm.expectRevert(IAdapterBase.AdapterBase__NotMorphoVault.selector);
        s_adapter.deallocate(s_data, s_amount, bytes4(0), address(0));
    }

    function test_deallocatingSucceeds() external {
        uint256 amount = s_amount / 2;
        uint256 adapterSupplyBalanceBefore = _getEVaultUnderlyingBalance(s_evault1, address(s_adapter));
        uint256 adapterAssetBalanceBefore = s_asset.balanceOf(address(s_adapter));
        uint256 vaultAssetBalanceBefore = s_asset.balanceOf(address(s_vault));

        vm.prank(s_allocator);
        s_vault.deallocate(address(s_adapter), s_data, amount);

        uint256 adapterSupplyBalanceAfter = _getEVaultUnderlyingBalance(s_evault1, address(s_adapter));
        uint256 adapterAssetBalanceAfter = s_asset.balanceOf(address(s_adapter));
        uint256 vaultAssetBalanceAfter = s_asset.balanceOf(address(s_vault));
        assertEq(adapterAssetBalanceBefore - adapterAssetBalanceAfter, 0);
        assertApproxEqAbs(vaultAssetBalanceAfter - vaultAssetBalanceBefore, amount, s_usdcDelta);
        assertApproxEqAbs(adapterSupplyBalanceBefore - adapterSupplyBalanceAfter, amount, s_usdcDelta);
    }

    function test_deallocatingEntireVaultLiquiditySucceeds() external {
        uint256 amount = _getEVaultUnderlyingBalance(s_evault1, address(s_adapter));
        uint256 adapterSupplyBalanceBefore = _getEVaultUnderlyingBalance(s_evault1, address(s_adapter));
        uint256 adapterAssetBalanceBefore = s_asset.balanceOf(address(s_adapter));
        uint256 vaultAssetBalanceBefore = s_asset.balanceOf(address(s_vault));
        vm.prank(s_allocator);
        s_vault.deallocate(address(s_adapter), s_data, amount);

        uint256 adapterSupplyBalanceAfter = _getEVaultUnderlyingBalance(s_evault1, address(s_adapter));
        uint256 adapterAssetBalanceAfter = s_asset.balanceOf(address(s_adapter));
        uint256 vaultAssetBalanceAfter = s_asset.balanceOf(address(s_vault));
        assertEq(s_adapter.getVaultsListLength(), 1);
        assertEq(adapterAssetBalanceBefore - adapterAssetBalanceAfter, 0);
        assertApproxEqAbs(vaultAssetBalanceAfter - vaultAssetBalanceBefore, amount, s_usdcDelta);
        assertEq(adapterSupplyBalanceBefore - adapterSupplyBalanceAfter, amount);
    }

    function test_canDeallocateFromMultipleEVaults() external {
        uint256 amount = _getEVaultUnderlyingBalance(s_evault1, address(s_adapter));

        vm.startPrank(s_allocator);
        s_vault.deallocate(address(s_adapter), s_data, amount);
        s_vault.deallocate(address(s_adapter), abi.encode(address(s_evault2)), amount);
        vm.stopPrank();

        assertEq(s_asset.balanceOf(address(s_adapter)), 0);
        assertApproxEqAbs(_getEVaultUnderlyingBalance(s_evault1, address(s_adapter)), 0, s_usdcDelta);
        assertApproxEqAbs(_getEVaultUnderlyingBalance(s_evault2, address(s_adapter)), 0, s_usdcDelta);
        assertEq(s_adapter.getVaultsListLength(), 0);
    }
}
