// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IAdapterBase } from "@src/adapterBase/interfaces/IAdapterBase.sol";

import { SiloV2AdapterBaseTest } from "@test/lending/siloV2/utils/SiloV2AdapterBaseTest.sol";

contract SiloV2ManagedVaultAdapterDeallocateTests is SiloV2AdapterBaseTest {
    bytes internal s_data;
    uint256 internal s_amount;
    uint256 internal s_assetDelta;

    function setUp() public override {
        super.setUp();

        s_data = abi.encode(address(s_siloVault1));
        s_amount = 100 * s_assetDecimalsScalingFactor;
        s_assetDelta = (1 * s_assetDecimalsScalingFactor) / 100;

        vm.startPrank(s_allocator);
        s_vault.allocate(address(s_managedAdapter), s_data, s_amount);
        s_vault.allocate(address(s_managedAdapter), abi.encode(address(s_siloVault2)), s_amount);
        vm.stopPrank();
    }

    function test_onlyParentVaultCanDeallocate() external {
        vm.prank(s_allocator);
        vm.expectRevert(IAdapterBase.AdapterBase__NotMorphoVault.selector);
        s_managedAdapter.deallocate(s_data, s_amount, bytes4(0), address(0));
    }

    function test_deallocatingSucceeds() external {
        uint256 amount = s_amount / 2;
        uint256 adapterSupplyBalanceBefore =
            s_siloVault1.previewRedeem(s_siloVault1.balanceOf(address(s_managedAdapter)));
        uint256 adapterAssetBalanceBefore = s_asset.balanceOf(address(s_managedAdapter));
        uint256 vaultAssetBalanceBefore = s_asset.balanceOf(address(s_vault));

        vm.prank(s_allocator);
        s_vault.deallocate(address(s_managedAdapter), s_data, amount);

        uint256 adapterSupplyBalanceAfter =
            s_siloVault1.previewRedeem(s_siloVault1.balanceOf(address(s_managedAdapter)));
        uint256 adapterAssetBalanceAfter = s_asset.balanceOf(address(s_managedAdapter));
        uint256 vaultAssetBalanceAfter = s_asset.balanceOf(address(s_vault));

        assertEq(adapterAssetBalanceBefore - adapterAssetBalanceAfter, 0);
        assertApproxEqAbs(vaultAssetBalanceAfter - vaultAssetBalanceBefore, amount, s_assetDelta);
        assertApproxEqAbs(adapterSupplyBalanceBefore - adapterSupplyBalanceAfter, amount, s_assetDelta);
    }

    function test_deallocatingEntireVaultLiquiditySucceeds() external {
        uint256 amount = s_siloVault1.previewRedeem(s_siloVault1.balanceOf(address(s_managedAdapter)));
        uint256 adapterSupplyBalanceBefore =
            s_siloVault1.previewRedeem(s_siloVault1.balanceOf(address(s_managedAdapter)));
        uint256 adapterAssetBalanceBefore = s_asset.balanceOf(address(s_managedAdapter));
        uint256 vaultAssetBalanceBefore = s_asset.balanceOf(address(s_vault));

        vm.prank(s_allocator);
        s_vault.deallocate(address(s_managedAdapter), s_data, amount);

        uint256 adapterSupplyBalanceAfter =
            s_siloVault1.previewRedeem(s_siloVault1.balanceOf(address(s_managedAdapter)));
        uint256 adapterAssetBalanceAfter = s_asset.balanceOf(address(s_managedAdapter));
        uint256 vaultAssetBalanceAfter = s_asset.balanceOf(address(s_vault));
        assertEq(s_managedAdapter.getSiloVaultsListLength(), 1);
        assertEq(adapterAssetBalanceBefore - adapterAssetBalanceAfter, 0);
        assertApproxEqAbs(vaultAssetBalanceAfter - vaultAssetBalanceBefore, amount, s_assetDelta);
        assertApproxEqAbs(adapterSupplyBalanceBefore - adapterSupplyBalanceAfter, amount, s_assetDelta);
    }

    function test_deallocatingFromMultipleVaultsSucceeds() external {
        uint256 amount = s_siloVault1.previewRedeem(s_siloVault1.balanceOf(address(s_managedAdapter)));

        vm.startPrank(s_allocator);
        s_vault.deallocate(address(s_managedAdapter), s_data, amount);
        s_vault.deallocate(address(s_managedAdapter), abi.encode(address(s_siloVault2)), amount);
        vm.stopPrank();

        assertEq(s_asset.balanceOf(address(s_managedAdapter)), 0);
        assertApproxEqAbs(
            s_siloVault1.previewRedeem(s_siloVault1.balanceOf(address(s_managedAdapter))),
            0,
            s_assetDelta
        );
        assertApproxEqAbs(
            s_siloVault2.previewRedeem(s_siloVault2.balanceOf(address(s_managedAdapter))),
            0,
            s_assetDelta
        );
        assertEq(s_managedAdapter.getSiloVaultsListLength(), 0);
    }
}
