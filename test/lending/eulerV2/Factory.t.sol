// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { EulerV2AdapterFactory } from "@src/adapters/lending/eulerV2/EulerV2AdapterFactory.sol";
import { EulerV2AdapterBaseTest } from "@test/lending/eulerV2/utils/EulerV2AdapterBaseTest.sol";

contract EulerV2AdapterFactoryTests is EulerV2AdapterBaseTest {
    EulerV2AdapterFactory internal s_factory;

    function setUp() public override {
        super.setUp();

        s_factory = new EulerV2AdapterFactory(address(s_evaultFactory));
    }

    function test_deployAdapter() external {
        vm.prank(s_allocator);
        address adapter = s_factory.createEulerV2Adapter(address(s_vault));

        assertNotEq(adapter, address(0));
        assertEq(s_factory.getEulerV2Adapter(address(s_vault)), adapter);
        assertTrue(s_factory.isEulerV2Adapter(adapter));
    }
}
