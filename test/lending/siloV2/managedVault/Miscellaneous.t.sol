// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC4626 } from "@openzeppelin-contracts-5.3.0/interfaces/IERC4626.sol";

import { SiloV2AdapterBaseTest } from "@test/lending/siloV2/utils/SiloV2AdapterBaseTest.sol";

contract SiloV2ManagedVaultAdapterMiscellaneousTests is SiloV2AdapterBaseTest {
    bytes internal s_data;
    uint256 internal s_amount;
    uint256 internal s_assetDelta;

    function setUp() public override {
        super.setUp();

        s_data = abi.encode(address(s_siloVault1));
        s_amount = 100 * s_assetDecimalsScalingFactor;
        s_assetDelta = (1 * s_assetDecimalsScalingFactor) / 100;
    }

    function test_checkRealAssets() external {
        // Check when vault shares balance is 0
        uint256 vaultAssets = _getVaultUnderlyingBalance(s_siloVault1);
        assertEq(vaultAssets, s_managedAdapter.realAssets());

        vm.prank(s_allocator);
        s_vault.allocate(address(s_managedAdapter), s_data, s_amount);

        uint256 vaultAssetsAfter = _getVaultUnderlyingBalance(s_siloVault1);
        assertEq(vaultAssetsAfter, s_managedAdapter.realAssets());
    }

    function test_checkSiloVaultsFactory() external view {
        assertEq(s_managedAdapter.getSiloVaultsFactory(), address(s_siloVaultsFactory));
    }

    function test_checkSiloVaultsList() external {
        vm.expectRevert();
        s_managedAdapter.getSiloVault(0);

        vm.prank(s_allocator);
        s_vault.allocate(address(s_managedAdapter), s_data, s_amount);

        assertEq(s_managedAdapter.getSiloVaultsListLength(), 1);
        assertEq(s_managedAdapter.getSiloVault(0), address(s_siloVault1));
    }

    function test_checkIds() external view {
        bytes32[] memory ids = s_managedAdapter.getIds(address(s_siloVault1));
        assertEq(ids[0], s_managedAdapter.getAdapterId());
        assertEq(ids[1], keccak256(abi.encode("this/pool", address(s_managedAdapter), address(s_siloVault1))));
    }

    function test_checkAllocation() external {
        vm.prank(s_allocator);
        s_vault.allocate(address(s_managedAdapter), s_data, s_amount);

        assertApproxEqAbs(s_managedAdapter.getAllocation(address(s_siloVault1)), s_amount, s_assetDelta);
    }

    function _getVaultUnderlyingBalance(IERC4626 _vault) internal view returns (uint256) {
        return _vault.previewRedeem(_vault.balanceOf(address(s_managedAdapter)));
    }
}
