// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script } from "forge-std-1.9.7/src/Script.sol";

import { HelloWorld } from "@src/HelloWorld.sol";

contract DeployHelloWorld is Script {
    HelloWorld public helloWorld;

    function run() public returns (HelloWorld) {
        vm.startBroadcast();
        helloWorld = new HelloWorld();
        vm.stopBroadcast();

        return helloWorld;
    }
}
