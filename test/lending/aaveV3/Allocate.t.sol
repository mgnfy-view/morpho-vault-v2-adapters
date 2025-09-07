// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "@openzeppelin-contracts-5.3.0/token/ERC20/IERC20.sol";
import { IPool } from "@src/adapters/lending/aaveV3/lib/interfaces/IPool.sol";

import { AaveV3Adapter } from "@src/adapters/lending/aaveV3/AaveV3Adapter.sol";
import { BaseTest } from "@test/BaseTest.sol";

contract AaveV3AdapterAllocateTests is BaseTest {
    IERC20 internal s_asset;
    address internal s_poolAddressesProviderRegistry;
    IPool internal s_pool;
    AaveV3Adapter internal s_adapter;

    function setUp() public override {
        super.setUp();

        string memory rpcUrl = vm.envString("ETHEREUM_MAINNET_RPC_URL");
        vm.createSelectFork(rpcUrl);

        s_asset = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48); // USDC on Ethereum Mainnet
        // These Aave v3 associated addresses have been obtained from https://aave.com/docs/resources/addresses
        s_poolAddressesProviderRegistry = 0xbaA999AC55EAce41CcAE355c77809e68Bb345170;
        s_pool = IPool(0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2);

        bytes[] memory ids = new bytes[](2);
        ids[0] = abi.encodePacked();
        ids[1] = abi.encodePacked();
        uint256[] memory absoluteCaps = new uint256[](2);
        absoluteCaps[0] = 0;
        absoluteCaps[1] = 0;
        uint256[] memory relativeCaps = new uint256[](2);
        relativeCaps[0] = 0;
        relativeCaps[1] = 0;
        VaultV2InitializationParams memory initializationParams = VaultV2InitializationParams({
            asset: address(s_asset),
            ids: ids,
            absoluteCaps: absoluteCaps,
            relativeCaps: relativeCaps
        });

        _deployMorphoVaultV2Instance(initializationParams);

        s_adapter = new AaveV3Adapter(address(s_vault), s_poolAddressesProviderRegistry);
        _setAdapter(address(s_adapter));
    }

    function test_healthCheck() external {
        assertTrue(true);
    }
}
