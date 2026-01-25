// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC4626 } from "@openzeppelin-contracts-5.3.0/interfaces/IERC4626.sol";

import { SiloV2AdapterBaseTest } from "@test/lending/siloV2/utils/SiloV2AdapterBaseTest.sol";

contract SiloV2IsolatedMarketAdapterMiscellaneousTests is SiloV2AdapterBaseTest {
    bytes internal s_data;
    uint256 internal s_amount;
    uint256 internal s_assetDelta;

    function setUp() public override {
        super.setUp();

        s_data = abi.encode(address(s_silo1));
        s_amount = 100 * s_assetDecimalsScalingFactor;
        s_assetDelta = (1 * s_assetDecimalsScalingFactor) / 100;
    }

    function test_checkRealAssets() external {
        // Check when silo shares balance is 0
        uint256 siloAssets = _getSiloUnderlyingBalance(s_silo1);
        assertEq(siloAssets, s_isolatedAdapter.realAssets());

        vm.prank(s_allocator);
        s_vault.allocate(address(s_isolatedAdapter), s_data, s_amount);

        uint256 siloAssetsAfter = _getSiloUnderlyingBalance(s_silo1);
        assertEq(siloAssetsAfter, s_isolatedAdapter.realAssets());
    }

    function test_checkSiloFactory() external view {
        assertEq(s_isolatedAdapter.getSiloFactory(), address(s_siloFactory));
    }

    function test_checkSilosList() external {
        vm.expectRevert();
        s_isolatedAdapter.getSilo(0);

        vm.prank(s_allocator);
        s_vault.allocate(address(s_isolatedAdapter), s_data, s_amount);

        assertEq(s_isolatedAdapter.getSilosListLength(), 1);
        assertEq(s_isolatedAdapter.getSilo(0), address(s_silo1));
    }

    function test_checkIds() external view {
        bytes32[] memory ids = s_isolatedAdapter.getIds(address(s_silo1));

        assertEq(ids[0], s_isolatedAdapter.getAdapterId());
        assertEq(ids[1], keccak256(abi.encode("this/pool", address(s_isolatedAdapter), address(s_silo1))));
    }

    function test_checkAllocation() external {
        vm.prank(s_allocator);
        s_vault.allocate(address(s_isolatedAdapter), s_data, s_amount);

        assertApproxEqAbs(s_isolatedAdapter.getAllocation(address(s_silo1)), s_amount, s_assetDelta);
    }

    function _getSiloUnderlyingBalance(IERC4626 _silo) internal view returns (uint256) {
        return _silo.previewRedeem(_silo.balanceOf(address(s_isolatedAdapter)));
    }
}
