// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IAdapterBase } from "@src/adapterBase/interfaces/IAdapterBase.sol";

interface ISiloV2IsolatedMarketAdapter is IAdapterBase {
    error SiloV2IsolatedMarketAdapter__InvalidSilo(address _silo);

    function getSiloFactory() external view returns (address);
    function getSilosListLength() external view returns (uint256);
    function getSilo(uint256 _index) external view returns (address);
    function getIds(address _silo) external view returns (bytes32[] memory);
    function getAllocation(address _silo) external view returns (uint256);
}
