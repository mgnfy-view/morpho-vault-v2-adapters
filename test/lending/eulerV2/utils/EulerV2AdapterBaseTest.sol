// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "@openzeppelin-contracts-5.3.0/token/ERC20/IERC20.sol";
import { IERC20Metadata } from "@openzeppelin-contracts-5.3.0/token/ERC20/extensions/IERC20Metadata.sol";

import { IEVault } from "@src/adapters/lending/eulerV2/lib/interfaces/IEVault.sol";
import { IEVaultFactory } from "@src/adapters/lending/eulerV2/lib/interfaces/IEVaultFactory.sol";

import { EulerV2Adapter } from "@src/adapters/lending/eulerV2/EulerV2Adapter.sol";
import { BaseTest } from "@test/BaseTest.sol";

contract EulerV2AdapterBaseTest is BaseTest {
    IERC20 internal s_asset;
    uint256 internal s_assetDecimalsScalingFactor;
    IEVaultFactory internal s_evaultFactory;
    IEVault internal s_evault1;
    IEVault internal s_evault2;
    EulerV2Adapter internal s_adapter;

    function setUp() public virtual override {
        super.setUp();

        string memory rpcUrl = vm.envString("ETHEREUM_MAINNET_RPC_URL");
        vm.createSelectFork(rpcUrl);

        s_asset = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48); // USDC on Ethereum Mainnet
        s_assetDecimalsScalingFactor = 10 ** IERC20Metadata(address(s_asset)).decimals();
        // These addresses have been obtained from https://docs.euler.finance/developers/contract-addresses/
        s_evaultFactory = IEVaultFactory(0x29a56a1b8214D9Cf7c5561811750D5cBDb45CC8e);
        s_evault1 = IEVault(0xe0a80d35bB6618CBA260120b279d357978c42BCE);
        s_evault2 = IEVault(0x3573A84Bee11D49A1CbCe2b291538dE7a7dD81c6);

        _deployMorphoVaultV2Instance(address(s_asset));

        s_adapter = new EulerV2Adapter(address(s_vault), address(s_evaultFactory));
        _setAdapter(address(s_adapter));

        uint256 maxDepositedAssets = 1_000 * s_assetDecimalsScalingFactor;
        bytes[] memory ids = new bytes[](3);
        ids[0] = abi.encode("this", address(s_adapter));
        ids[1] = abi.encode("this/pool", address(s_adapter), address(s_evault1));
        ids[2] = abi.encode("this/pool", address(s_adapter), address(s_evault2));
        uint256[] memory absoluteCaps = new uint256[](3);
        absoluteCaps[0] = maxDepositedAssets;
        absoluteCaps[1] = maxDepositedAssets;
        absoluteCaps[2] = maxDepositedAssets;
        uint256[] memory relativeCaps = new uint256[](3);
        relativeCaps[0] = 1e18;
        relativeCaps[1] = 1e18;
        relativeCaps[2] = 1e18;
        _setCaps(ids, absoluteCaps, relativeCaps);

        uint256 usdcDealAmount = maxDepositedAssets;
        deal(address(s_asset), s_depositor, usdcDealAmount);
        vm.startPrank(s_depositor);
        s_asset.approve(address(s_vault), usdcDealAmount);
        s_vault.deposit(usdcDealAmount, s_depositor);
        vm.stopPrank();
    }

    function _getEVaultUnderlyingBalance(IEVault _evault, address _user) internal view returns (uint256) {
        return _evault.convertToAssets(_evault.balanceOf(_user));
    }
}
