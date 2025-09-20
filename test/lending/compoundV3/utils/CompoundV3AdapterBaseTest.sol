// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "@openzeppelin-contracts-5.3.0/token/ERC20/IERC20.sol";
import { IERC20Metadata } from "@openzeppelin-contracts-5.3.0/token/ERC20/extensions/IERC20Metadata.sol";

import { IComet } from "@src/adapters/lending/compoundV3/lib/interfaces/IComet.sol";

import { CompoundV3Adapter } from "@src/adapters/lending/compoundV3/CompoundV3Adapter.sol";
import { BaseTest } from "@test/BaseTest.sol";

contract CompoundV3AdapterBaseTest is BaseTest {
    IERC20 internal s_asset;
    uint256 internal s_assetDecimalsScalingFactor;
    address internal s_configurator;
    IComet internal s_comet;
    CompoundV3Adapter internal s_adapter;

    function setUp() public virtual override {
        super.setUp();

        string memory rpcUrl = vm.envString("ETHEREUM_MAINNET_RPC_URL");
        vm.createSelectFork(rpcUrl);

        s_asset = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48); // USDC on Ethereum Mainnet
        s_assetDecimalsScalingFactor = 10 ** IERC20Metadata(address(s_asset)).decimals();
        // These addresses have been obtained from https://docs.compound.finance/#protocol-contracts
        s_configurator = 0x316f9708bB98af7dA9c68C1C3b5e79039cD336E3;
        s_comet = IComet(0xc3d688B66703497DAA19211EEdff47f25384cdc3);

        _deployMorphoVaultV2Instance(address(s_asset));

        s_adapter = new CompoundV3Adapter(address(s_vault), s_configurator);
        _setAdapter(address(s_adapter));

        uint256 maxDepositedAssets = 1_000 * s_assetDecimalsScalingFactor;
        bytes[] memory ids = new bytes[](2);
        ids[0] = abi.encode("this", address(s_adapter));
        ids[1] = abi.encode("this/pool", address(s_adapter), address(s_comet));
        uint256[] memory absoluteCaps = new uint256[](2);
        absoluteCaps[0] = maxDepositedAssets;
        absoluteCaps[1] = maxDepositedAssets;
        uint256[] memory relativeCaps = new uint256[](2);
        relativeCaps[0] = 1e18;
        relativeCaps[1] = 1e18;
        _setCaps(ids, absoluteCaps, relativeCaps);

        uint256 usdcDealAmount = maxDepositedAssets;
        deal(address(s_asset), s_depositor, usdcDealAmount);
        vm.startPrank(s_depositor);
        s_asset.approve(address(s_vault), usdcDealAmount);
        s_vault.deposit(usdcDealAmount, s_depositor);
        vm.stopPrank();
    }
}
