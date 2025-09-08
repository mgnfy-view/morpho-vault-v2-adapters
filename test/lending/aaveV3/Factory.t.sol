// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { AaveV3AdapterFactory } from "@src/adapters/lending/aaveV3/AaveV3AdapterFactory.sol";
import { AaveV3AdapterBaseTest } from "@test/lending/aaveV3/utils/AaveV3AdapterBaseTest.sol";

contract AaveV3AdapterFactoryTests is AaveV3AdapterBaseTest {
    AaveV3AdapterFactory internal s_factory;

    function setUp() public override {
        super.setUp();

        s_factory = new AaveV3AdapterFactory(address(s_poolAddressesProviderRegistry));
    }

    function test_deployAdapter() external {
        vm.prank(s_allocator);
        address adapter = s_factory.createAaveV3Adapter(address(s_vault));

        assertNotEq(adapter, address(0));
        assertEq(s_factory.getAaveV3Adapter(address(s_vault)), adapter);
        assertTrue(s_factory.isAaveV3Adapter(adapter));
    }
}
