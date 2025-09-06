// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IAdapterBase } from "@src/adapterBase/interfaces/IAdapterBase.sol";

interface IAaveV3Adapter is IAdapterBase {
    error AaveV3Adapter__InvalidPoolAddressesProvider(address poolAddressesProvider);
}
