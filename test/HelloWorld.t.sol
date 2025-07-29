// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test, console } from "forge-std-1.9.7/src/Test.sol";

import { HelloWorld } from "@src/HelloWorld.sol";

contract HelloWorldTests is Test {
    HelloWorld public helloWorld;

    function setUp() public {
        helloWorld = new HelloWorld();
    }

    function test_helloWorld() external view {
        assertEq(helloWorld.message(), "Hello World");
    }
}
