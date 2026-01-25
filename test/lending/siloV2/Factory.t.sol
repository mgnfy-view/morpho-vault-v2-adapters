// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { SiloV2CommonAdapterFactory } from "@src/adapters/lending/siloV2/SiloV2CommonAdapterFactory.sol";
import { SiloV2AdapterBaseTest } from "@test/lending/siloV2/utils/SiloV2AdapterBaseTest.sol";

contract SiloV2CommonAdapterFactoryTests is SiloV2AdapterBaseTest {
    SiloV2CommonAdapterFactory internal s_factory;

    function setUp() public override {
        super.setUp();

        s_factory = new SiloV2CommonAdapterFactory(address(s_siloFactory), address(s_siloVaultsFactory));
    }

    function test_deployIsolatedMarketAdapter() external {
        vm.prank(s_allocator);
        address adapter = s_factory.createSiloV2IsolatedMarketAdapter(address(s_vault));

        assertNotEq(adapter, address(0));
        assertEq(s_factory.getSiloV2IsolatedMarketAdapter(address(s_vault)), adapter);
        assertTrue(s_factory.isSiloV2IsolatedMarketAdapter(adapter));
        assertFalse(s_factory.isSiloV2ManagedVaultAdapter(adapter));
    }

    function test_deployManagedVaultAdapter() external {
        vm.prank(s_allocator);
        address adapter = s_factory.createSiloV2ManagedVaultAdapter(address(s_vault));

        assertNotEq(adapter, address(0));
        assertEq(s_factory.getSiloV2ManagedVaultAdapter(address(s_vault)), adapter);
        assertTrue(s_factory.isSiloV2ManagedVaultAdapter(adapter));
        assertFalse(s_factory.isSiloV2IsolatedMarketAdapter(adapter));
    }
}
