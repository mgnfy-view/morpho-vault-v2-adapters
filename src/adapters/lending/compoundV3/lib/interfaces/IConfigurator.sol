// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { CometConfiguration } from "@src/adapters/lending/compoundV3/lib/libraries/types/CometConfiguration.sol";

interface IConfigurator {
    function getConfiguration(address _cometProxy) external view returns (CometConfiguration.Configuration memory);
}
