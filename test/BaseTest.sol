// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { VaultV2 } from "morpho-vault-v2-1.0.0/src/VaultV2.sol";

import { Test } from "forge-std-1.9.7/src/Test.sol";

contract BaseTest is Test {
    struct VaultV2InitializationParams {
        address asset;
        bytes[] ids;
        uint256[] absoluteCaps;
        uint256[] relativeCaps;
    }

    address internal s_owner;
    address internal s_curator;
    address internal s_allocator;
    VaultV2 internal s_vault;

    error BaseTest__ArrayLengthsMismatch();

    function setUp() public virtual {
        s_owner = makeAddr("owner");
        s_curator = makeAddr("curator");
        s_allocator = makeAddr("allocator");
    }

    function _deployMorphoVaultV2Instance(VaultV2InitializationParams memory _initializationParams) internal {
        s_vault = new VaultV2(s_owner, _initializationParams.asset);

        vm.prank(s_owner);
        s_vault.setCurator(s_curator);

        vm.startPrank(s_curator);
        uint256 idsLength = _initializationParams.ids.length;
        uint256 absoluteCapsLength = _initializationParams.absoluteCaps.length;
        if (idsLength != absoluteCapsLength || absoluteCapsLength != _initializationParams.relativeCaps.length) {
            revert BaseTest__ArrayLengthsMismatch();
        }

        for (uint256 i; i < idsLength; ++i) {
            s_vault.submit(
                abi.encodeCall(
                    VaultV2.increaseAbsoluteCap, (_initializationParams.ids[i], _initializationParams.absoluteCaps[i])
                )
            );
            s_vault.increaseAbsoluteCap(_initializationParams.ids[i], _initializationParams.absoluteCaps[i]);

            s_vault.submit(
                abi.encodeCall(
                    VaultV2.increaseRelativeCap, (_initializationParams.ids[i], _initializationParams.absoluteCaps[i])
                )
            );
            s_vault.increaseRelativeCap(_initializationParams.ids[i], _initializationParams.relativeCaps[i]);
        }

        s_vault.submit(abi.encodeCall(VaultV2.setIsAllocator, (s_allocator, true)));
        s_vault.setIsAllocator(s_allocator, true);
        vm.stopPrank();
    }

    function _setAdapter(address _adapter) internal {
        vm.prank(s_curator);
        s_vault.submit(abi.encodeCall(VaultV2.addAdapter, _adapter));
        s_vault.addAdapter(_adapter);
    }
}
