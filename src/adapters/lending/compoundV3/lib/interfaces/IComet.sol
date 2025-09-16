// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IComet {
    function supply(address _asset, uint256 _amount) external;
    function withdraw(address _asset, uint256 _amount) external;

    function balanceOf(address _account) external view returns (uint256);
    function baseToken() external view returns (address);
}
