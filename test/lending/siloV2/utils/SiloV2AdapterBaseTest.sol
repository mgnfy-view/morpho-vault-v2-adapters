// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC4626 } from "@openzeppelin-contracts-5.3.0/interfaces/IERC4626.sol";
import { IERC20 } from "@openzeppelin-contracts-5.3.0/token/ERC20/IERC20.sol";
import { IERC20Metadata } from "@openzeppelin-contracts-5.3.0/token/ERC20/extensions/IERC20Metadata.sol";
import { ISiloFactory } from "@src/adapters/lending/siloV2/commonLib/interfaces/ISiloFactory.sol";
import { ISiloVault } from "@src/adapters/lending/siloV2/commonLib/interfaces/ISiloVault.sol";
import {
    IIncentivesClaimingLogic,
    IIncentivesClaimingLogicFactory,
    ISiloVaultsFactory
} from "@src/adapters/lending/siloV2/commonLib/interfaces/ISiloVaultsFactory.sol";

import {
    SiloV2IsolatedMarketAdapter
} from "@src/adapters/lending/siloV2/isolatedMarket/SiloV2IsolatedMarketAdapter.sol";
import { SiloV2ManagedVaultAdapter } from "@src/adapters/lending/siloV2/managedVault/SiloV2ManagedVaultAdapter.sol";
import { BaseTest } from "@test/BaseTest.sol";

contract SiloV2AdapterBaseTest is BaseTest {
    IERC20 internal s_asset;
    uint256 internal s_assetDecimalsScalingFactor;
    ISiloFactory internal s_siloFactory;
    ISiloVaultsFactory internal s_siloVaultsFactory;
    IERC4626 internal s_silo1;
    IERC4626 internal s_silo2;
    ISiloVault internal s_siloVault1;
    ISiloVault internal s_siloVault2;
    SiloV2IsolatedMarketAdapter internal s_isolatedAdapter;
    SiloV2ManagedVaultAdapter internal s_managedAdapter;

    function setUp() public virtual override {
        super.setUp();

        string memory rpcUrl = vm.envString("ETHEREUM_MAINNET_RPC_URL");
        vm.createSelectFork(rpcUrl);

        s_siloFactory = ISiloFactory(0x22a3cF6149bFa611bAFc89Fd721918EC3Cf7b581);
        s_siloVaultsFactory = ISiloVaultsFactory(0xB30Ee27f6e19A24Df12dba5Ab4124B6dCE9beeE5);
        s_silo1 = IERC4626(0x02AE6A64a0DC17ffFDC5722Ad8270a7B32Be44db);
        s_silo2 = IERC4626(0x160287E2D3fdCDE9E91317982fc1Cc01C1f94085);

        s_asset = IERC20(s_silo1.asset());
        require(address(s_silo2.asset()) == address(s_asset), "Silo asset mismatch");
        s_assetDecimalsScalingFactor = 10 ** IERC20Metadata(address(s_asset)).decimals();

        _deployMorphoVaultV2Instance(address(s_asset));

        s_siloVault1 = ISiloVault(0x0D2BbA9593b9477aA7171de303Fb48b2BCd36d29);
        s_siloVault2 = ISiloVault(0xAD43BD27A4D7C18C05f78F24D9BD3fA6805C2ff6);

        s_isolatedAdapter = new SiloV2IsolatedMarketAdapter(address(s_vault), address(s_siloFactory));
        s_managedAdapter = new SiloV2ManagedVaultAdapter(address(s_vault), address(s_siloVaultsFactory));

        _setAdapter(address(s_isolatedAdapter));
        _setAdapter(address(s_managedAdapter));

        uint256 maxDepositedAssets = 1_000 * s_assetDecimalsScalingFactor;
        bytes[] memory ids = new bytes[](6);
        ids[0] = abi.encode("this", address(s_isolatedAdapter));
        ids[1] = abi.encode("this/pool", address(s_isolatedAdapter), address(s_silo1));
        ids[2] = abi.encode("this/pool", address(s_isolatedAdapter), address(s_silo2));
        ids[3] = abi.encode("this", address(s_managedAdapter));
        ids[4] = abi.encode("this/pool", address(s_managedAdapter), address(s_siloVault1));
        ids[5] = abi.encode("this/pool", address(s_managedAdapter), address(s_siloVault2));
        uint256[] memory absoluteCaps = new uint256[](6);
        absoluteCaps[0] = maxDepositedAssets;
        absoluteCaps[1] = maxDepositedAssets;
        absoluteCaps[2] = maxDepositedAssets;
        absoluteCaps[3] = maxDepositedAssets;
        absoluteCaps[4] = maxDepositedAssets;
        absoluteCaps[5] = maxDepositedAssets;
        uint256[] memory relativeCaps = new uint256[](6);
        relativeCaps[0] = 1e18;
        relativeCaps[1] = 1e18;
        relativeCaps[2] = 1e18;
        relativeCaps[3] = 1e18;
        relativeCaps[4] = 1e18;
        relativeCaps[5] = 1e18;
        _setCaps(ids, absoluteCaps, relativeCaps);

        deal(address(s_asset), s_depositor, maxDepositedAssets);
        vm.startPrank(s_depositor);
        s_asset.approve(address(s_vault), maxDepositedAssets);
        s_vault.deposit(maxDepositedAssets, s_depositor);
        vm.stopPrank();
    }
}
