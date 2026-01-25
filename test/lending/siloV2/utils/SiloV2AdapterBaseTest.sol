// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC4626 } from "@openzeppelin-contracts-5.3.0/interfaces/IERC4626.sol";
import { IERC20 } from "@openzeppelin-contracts-5.3.0/token/ERC20/IERC20.sol";
import { IERC20Metadata } from "@openzeppelin-contracts-5.3.0/token/ERC20/extensions/IERC20Metadata.sol";

import { ISilo } from "@src/adapters/lending/siloV2/commonLib/interfaces/ISilo.sol";
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
    ISilo internal s_silo;
    ISiloVault internal s_siloVault;
    SiloV2IsolatedMarketAdapter internal s_isolatedAdapter;
    SiloV2ManagedVaultAdapter internal s_managedAdapter;

    function setUp() public virtual override {
        super.setUp();

        string memory rpcUrl = vm.envString("ARBITRUM_MAINNET_RPC_URL");
        vm.createSelectFork(rpcUrl);

        s_siloVaultsFactory = ISiloVaultsFactory(0xCF9452Ccb68e99582bc033C47621A70D2E6Bc763);
        s_siloFactory = ISiloFactory(0x384DC7759d35313F0b567D42bf2f611B285B657C);
        s_silo = ISilo(0x038722A3b78A10816Ae0EDC6afA768B03048a0cC);

        s_asset = IERC20(s_silo.asset());
        s_assetDecimalsScalingFactor = 10 ** IERC20Metadata(address(s_asset)).decimals();

        _deployMorphoVaultV2Instance(address(s_asset));

        s_siloVault = _createSiloVault();

        s_isolatedAdapter = new SiloV2IsolatedMarketAdapter(address(s_vault), address(s_siloFactory));
        s_managedAdapter = new SiloV2ManagedVaultAdapter(address(s_vault), address(s_siloVaultsFactory));

        _setAdapter(address(s_isolatedAdapter));
        _setAdapter(address(s_managedAdapter));

        uint256 maxDepositedAssets = 1_000 * s_assetDecimalsScalingFactor;
        bytes[] memory ids = new bytes[](4);
        ids[0] = abi.encode("this", address(s_isolatedAdapter));
        ids[1] = abi.encode("this/pool", address(s_isolatedAdapter), address(s_silo));
        ids[2] = abi.encode("this", address(s_managedAdapter));
        ids[3] = abi.encode("this/pool", address(s_managedAdapter), address(s_siloVault));
        uint256[] memory absoluteCaps = new uint256[](4);
        absoluteCaps[0] = maxDepositedAssets;
        absoluteCaps[1] = maxDepositedAssets;
        absoluteCaps[2] = maxDepositedAssets;
        absoluteCaps[3] = maxDepositedAssets;
        uint256[] memory relativeCaps = new uint256[](4);
        relativeCaps[0] = 1e18;
        relativeCaps[1] = 1e18;
        relativeCaps[2] = 1e18;
        relativeCaps[3] = 1e18;
        _setCaps(ids, absoluteCaps, relativeCaps);

        deal(address(s_asset), s_depositor, maxDepositedAssets);
        vm.startPrank(s_depositor);
        s_asset.approve(address(s_vault), maxDepositedAssets);
        s_vault.deposit(maxDepositedAssets, s_depositor);
        vm.stopPrank();
    }

    function _createSiloVault() internal returns (ISiloVault) {
        IIncentivesClaimingLogic[] memory claimingLogics = new IIncentivesClaimingLogic[](0);
        IERC4626[] memory marketsWithIncentives = new IERC4626[](0);
        IIncentivesClaimingLogicFactory[] memory trustedFactories = new IIncentivesClaimingLogicFactory[](0);
        bytes32 salt = keccak256(abi.encode("morpho-silo-v2", address(this), blockhash(block.number - 1)));
        uint256 initialTimelock = 1 days;

        return s_siloVaultsFactory.createSiloVault(
            s_owner,
            initialTimelock,
            address(s_asset),
            "Morpho Silo Vault",
            "MSV",
            salt,
            address(0),
            claimingLogics,
            marketsWithIncentives,
            trustedFactories
        );
    }
}
