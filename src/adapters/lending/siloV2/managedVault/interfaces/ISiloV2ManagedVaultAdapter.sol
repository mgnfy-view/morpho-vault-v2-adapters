// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IAdapterBase } from "@src/adapterBase/interfaces/IAdapterBase.sol";

interface ISiloV2ManagedVaultAdapter is IAdapterBase {
    error SiloV2ManagedVaultAdapter__InvalidSiloVault(address _siloVault);
}
