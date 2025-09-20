// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "@openzeppelin-contracts-5.3.0/token/ERC20/IERC20.sol";
import { IERC20Metadata } from "@openzeppelin-contracts-5.3.0/token/ERC20/extensions/IERC20Metadata.sol";
import { IPool } from "@src/adapters/lending/aaveV3/lib/interfaces/IPool.sol";
import { IPoolAddressesProviderRegistry } from
    "@src/adapters/lending/aaveV3/lib/interfaces/IPoolAddressesProviderRegistry.sol";

import { AaveV3Adapter } from "@src/adapters/lending/aaveV3/AaveV3Adapter.sol";
import { BaseTest } from "@test/BaseTest.sol";

contract AaveV3AdapterBaseTest is BaseTest {
    IERC20 internal s_asset;
    uint256 internal s_assetDecimalsScalingFactor;
    IPoolAddressesProviderRegistry internal s_poolAddressesProviderRegistry;
    IPool internal s_pool;
    AaveV3Adapter internal s_adapter;

    function setUp() public virtual override {
        super.setUp();

        string memory rpcUrl = vm.envString("ETHEREUM_MAINNET_RPC_URL");
        vm.createSelectFork(rpcUrl);

        s_asset = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48); // USDC on Ethereum Mainnet
        s_assetDecimalsScalingFactor = 10 ** IERC20Metadata(address(s_asset)).decimals();
        // These Aave v3 associated addresses have been obtained from https://aave.com/docs/resources/addresses
        s_poolAddressesProviderRegistry = IPoolAddressesProviderRegistry(0xbaA999AC55EAce41CcAE355c77809e68Bb345170);
        s_pool = IPool(0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2);

        _deployMorphoVaultV2Instance(address(s_asset));

        s_adapter = new AaveV3Adapter(address(s_vault), address(s_poolAddressesProviderRegistry));
        _setAdapter(address(s_adapter));

        uint256 maxDepositedAssets = 1_000 * s_assetDecimalsScalingFactor;
        bytes[] memory ids = new bytes[](2);
        ids[0] = abi.encode("this", address(s_adapter));
        ids[1] = abi.encode("this/pool", address(s_adapter), address(s_pool));
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
