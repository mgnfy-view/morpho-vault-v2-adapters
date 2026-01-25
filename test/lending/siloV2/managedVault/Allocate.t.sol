// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IAdapterBase } from "@src/adapterBase/interfaces/IAdapterBase.sol";
import {
    ISiloV2ManagedVaultAdapter
} from "@src/adapters/lending/siloV2/managedVault/interfaces/ISiloV2ManagedVaultAdapter.sol";
import { IERC4626 } from "@openzeppelin-contracts-5.3.0/interfaces/IERC4626.sol";

import { SiloV2AdapterBaseTest } from "@test/lending/siloV2/utils/SiloV2AdapterBaseTest.sol";

contract SiloV2ManagedVaultAdapterAllocateTests is SiloV2AdapterBaseTest {
    bytes internal s_data;
    uint256 internal s_amount;
    uint256 internal s_assetDelta;

    function setUp() public override {
        super.setUp();

        s_data = abi.encode(address(s_siloVault1));
        s_amount = 100 * s_assetDecimalsScalingFactor;
        s_assetDelta = (1 * s_assetDecimalsScalingFactor) / 100;
    }

    function test_onlyParentVaultCanAllocate() external {
        vm.prank(s_allocator);
        vm.expectRevert(IAdapterBase.AdapterBase__NotMorphoVault.selector);
        s_managedAdapter.allocate(s_data, s_amount, bytes4(0), address(0));
    }

    function test_canAllocateToValidSiloVaultOnly() external {
        address invalidVault = makeAddr("invalidVault");

        vm.prank(s_allocator);
        vm.expectRevert(
            abi.encodeWithSelector(
                ISiloV2ManagedVaultAdapter.SiloV2ManagedVaultAdapter__InvalidSiloVault.selector, invalidVault
            )
        );
        s_vault.allocate(address(s_managedAdapter), abi.encode(invalidVault), s_amount);
    }

    function test_allocatingSucceeds() external {
        vm.prank(s_allocator);
        s_vault.allocate(address(s_managedAdapter), s_data, s_amount);

        assertEq(s_asset.balanceOf(address(s_managedAdapter)), 0);
        assertApproxEqAbs(_getVaultUnderlyingBalance(s_siloVault1), s_amount, s_assetDelta);
        assertEq(s_managedAdapter.getSiloVaultsListLength(), 1);
        assertEq(s_managedAdapter.getSiloVault(0), address(s_siloVault1));
    }

    function test_allocatingEntireVaultLiquiditySucceeds() external {
        uint256 amount = s_asset.balanceOf(address(s_vault));

        vm.prank(s_allocator);
        s_vault.allocate(address(s_managedAdapter), s_data, amount);

        address siloVault = s_managedAdapter.getSiloVault(0);
        assertEq(s_asset.balanceOf(address(s_managedAdapter)), 0);
        assertApproxEqAbs(_getVaultUnderlyingBalance(s_siloVault1), amount, s_assetDelta);
        assertEq(s_managedAdapter.getSiloVaultsListLength(), 1);
        assertEq(siloVault, address(s_siloVault1));
    }

    function test_canAllocateToMultipleSiloVaults() external {
        uint256 amount = s_amount / 2;

        vm.startPrank(s_allocator);
        s_vault.allocate(address(s_managedAdapter), s_data, amount);
        s_vault.allocate(address(s_managedAdapter), abi.encode(address(s_siloVault2)), amount);
        vm.stopPrank();

        assertEq(s_asset.balanceOf(address(s_managedAdapter)), 0);
        assertApproxEqAbs(_getVaultUnderlyingBalance(s_siloVault1), amount, s_assetDelta);
        assertApproxEqAbs(_getVaultUnderlyingBalance(s_siloVault2), amount, s_assetDelta);
        assertEq(s_managedAdapter.getSiloVaultsListLength(), 2);
        assertEq(s_managedAdapter.getSiloVault(0), address(s_siloVault1));
        assertEq(s_managedAdapter.getSiloVault(1), address(s_siloVault2));
    }

    function _getVaultUnderlyingBalance(IERC4626 _vault) internal view returns (uint256) {
        return _vault.previewRedeem(_vault.balanceOf(address(s_managedAdapter)));
    }
}
