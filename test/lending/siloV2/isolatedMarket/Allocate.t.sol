// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC4626 } from "@openzeppelin-contracts-5.3.0/interfaces/IERC4626.sol";
import { IAdapterBase } from "@src/adapterBase/interfaces/IAdapterBase.sol";
import {
    ISiloV2IsolatedMarketAdapter
} from "@src/adapters/lending/siloV2/isolatedMarket/interfaces/ISiloV2IsolatedMarketAdapter.sol";

import { SiloV2AdapterBaseTest } from "@test/lending/siloV2/utils/SiloV2AdapterBaseTest.sol";

contract SiloV2IsolatedMarketAdapterAllocateTests is SiloV2AdapterBaseTest {
    bytes internal s_data;
    uint256 internal s_amount;
    uint256 internal s_assetDelta;

    function setUp() public override {
        super.setUp();

        s_data = abi.encode(address(s_silo1));
        s_amount = 100 * s_assetDecimalsScalingFactor;
        s_assetDelta = (1 * s_assetDecimalsScalingFactor) / 100;
    }

    function test_onlyParentVaultCanAllocate() external {
        vm.prank(s_allocator);
        vm.expectRevert(IAdapterBase.AdapterBase__NotMorphoVault.selector);
        s_isolatedAdapter.allocate(s_data, s_amount, bytes4(0), address(0));
    }

    function test_canAllocateToValidSiloOnly() external {
        address invalidSilo = makeAddr("invalidSilo");

        vm.prank(s_allocator);
        vm.expectRevert(
            abi.encodeWithSelector(
                ISiloV2IsolatedMarketAdapter.SiloV2IsolatedMarketAdapter__InvalidSilo.selector, invalidSilo
            )
        );
        s_vault.allocate(address(s_isolatedAdapter), abi.encode(invalidSilo), s_amount);
    }

    function test_allocatingSucceeds() external {
        vm.prank(s_allocator);
        s_vault.allocate(address(s_isolatedAdapter), s_data, s_amount);

        assertEq(s_asset.balanceOf(address(s_isolatedAdapter)), 0);
        assertApproxEqAbs(_getSiloUnderlyingBalance(s_silo1), s_amount, s_assetDelta);
        assertEq(s_isolatedAdapter.getSilosListLength(), 1);
        assertEq(s_isolatedAdapter.getSilo(0), address(s_silo1));
    }

    function test_allocatingEntireVaultLiquiditySucceeds() external {
        vm.prank(s_allocator);
        s_vault.allocate(address(s_isolatedAdapter), s_data, s_amount);

        address silo = s_isolatedAdapter.getSilo(0);
        assertEq(s_asset.balanceOf(address(s_isolatedAdapter)), 0);
        assertApproxEqAbs(_getSiloUnderlyingBalance(s_silo1), s_amount, s_assetDelta);
        assertEq(s_isolatedAdapter.getSilosListLength(), 1);
        assertEq(silo, address(s_silo1));
    }

    function test_canAllocateToMultipleSilos() external {
        uint256 amount = s_amount / 2;

        vm.startPrank(s_allocator);
        s_vault.allocate(address(s_isolatedAdapter), s_data, amount);
        s_vault.allocate(address(s_isolatedAdapter), abi.encode(address(s_silo2)), amount);
        vm.stopPrank();

        assertEq(s_asset.balanceOf(address(s_isolatedAdapter)), 0);
        assertApproxEqAbs(_getSiloUnderlyingBalance(s_silo1), amount, s_assetDelta);
        assertApproxEqAbs(_getSiloUnderlyingBalance(s_silo2), amount, s_assetDelta);
        assertEq(s_isolatedAdapter.getSilosListLength(), 2);
        assertEq(s_isolatedAdapter.getSilo(0), address(s_silo1));
        assertEq(s_isolatedAdapter.getSilo(1), address(s_silo2));
    }

    function _getSiloUnderlyingBalance(IERC4626 _silo) internal view returns (uint256) {
        return _silo.previewRedeem(_silo.balanceOf(address(s_isolatedAdapter)));
    }
}
