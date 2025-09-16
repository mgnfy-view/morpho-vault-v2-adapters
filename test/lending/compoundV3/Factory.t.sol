// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { CompoundV3AdapterFactory } from "@src/adapters/lending/compoundV3/CompoundV3AdapterFactory.sol";
import { CompoundV3AdapterBaseTest } from "@test/lending/compoundV3/utils/CompoundV3AdapterBaseTest.sol";

contract CompoundV3AdapterFactoryTests is CompoundV3AdapterBaseTest {
    CompoundV3AdapterFactory internal s_factory;

    function setUp() public override {
        super.setUp();

        s_factory = new CompoundV3AdapterFactory(s_configurator);
    }

    function test_deployAdapter() external {
        vm.prank(s_allocator);
        address adapter = s_factory.createCompoundV3Adapter(address(s_vault));

        assertNotEq(adapter, address(0));
        assertEq(s_factory.getCompoundV3Adapter(address(s_vault)), adapter);
        assertTrue(s_factory.isCompoundV3Adapter(adapter));
    }
}
