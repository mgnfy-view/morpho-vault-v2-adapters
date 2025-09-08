// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { VaultV2 } from "morpho-vault-v2-1.0.0/src/VaultV2.sol";

import { Test } from "forge-std-1.9.7/src/Test.sol";

contract BaseTest is Test {
    address internal s_owner;
    address internal s_curator;
    address internal s_allocator;
    address internal s_depositor;
    VaultV2 internal s_vault;

    error BaseTest__ArrayLengthsMismatch();

    function setUp() public virtual {
        s_owner = makeAddr("owner");
        s_curator = makeAddr("curator");
        s_allocator = makeAddr("allocator");
        s_depositor = makeAddr("depositor");
    }

    function _deployMorphoVaultV2Instance(address _asset) internal {
        s_vault = new VaultV2(s_owner, _asset);

        vm.prank(s_owner);
        s_vault.setCurator(s_curator);

        vm.startPrank(s_curator);
        s_vault.submit(abi.encodeCall(VaultV2.setIsAllocator, (s_allocator, true)));
        s_vault.setIsAllocator(s_allocator, true);
        vm.stopPrank();
    }

    function _setAdapter(address _adapter) internal {
        vm.prank(s_curator);
        s_vault.submit(abi.encodeCall(VaultV2.addAdapter, _adapter));
        s_vault.addAdapter(_adapter);
    }

    function _setCaps(bytes[] memory _ids, uint256[] memory _absoluteCaps, uint256[] memory _relativeCaps) internal {
        uint256 idsLength = _ids.length;
        uint256 absoluteCapsLength = _absoluteCaps.length;
        if (idsLength != absoluteCapsLength || absoluteCapsLength != _relativeCaps.length) {
            revert BaseTest__ArrayLengthsMismatch();
        }

        vm.startPrank(s_curator);
        for (uint256 i; i < idsLength; ++i) {
            s_vault.submit(abi.encodeCall(VaultV2.increaseAbsoluteCap, (_ids[i], _absoluteCaps[i])));
            s_vault.increaseAbsoluteCap(_ids[i], _absoluteCaps[i]);

            s_vault.submit(abi.encodeCall(VaultV2.increaseRelativeCap, (_ids[i], _relativeCaps[i])));
            s_vault.increaseRelativeCap(_ids[i], _relativeCaps[i]);
        }
        vm.stopPrank();
    }
}
