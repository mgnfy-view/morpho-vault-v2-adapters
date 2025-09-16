// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IEVault {
    function deposit(uint256 _amount, address _receiver) external returns (uint256);
    function withdraw(uint256 _amount, address _receiver, address _owner) external returns (uint256);

    function asset() external view returns (address);
    function balanceOf(address _account) external view returns (uint256);
    function convertToAssets(uint256 shares) external view returns (uint256);
}
