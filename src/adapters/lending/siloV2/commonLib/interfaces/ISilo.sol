// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { IERC20 } from "@openzeppelin-contracts-5.3.0/token/ERC20/IERC20.sol";
import { IERC4626 } from "@openzeppelin-contracts-5.3.0/token/ERC20/extensions/ERC4626.sol";

/// @notice Core Silo market interface for isolated lending markets.
interface ISilo is IERC4626 {
    /// @notice Returns the underlying asset of this silo vault.
    function siloAsset() external view returns (address);
    /// @notice Accrues interest for a specific asset.
    function accrueInterest(address _asset) external;
    /// @notice Deposit assets into the silo.
    function deposit(address _asset, uint256 _amount, bool _collateralOnly) external;
    /// @notice Deposit assets on behalf of a depositor.
    function depositFor(address _asset, address _depositor, uint256 _amount, bool _collateralOnly) external;
    /// @notice Withdraw assets from the silo.
    function withdraw(address _asset, uint256 _amount, bool _collateralOnly) external;
    /// @notice Withdraw assets on behalf of a depositor.
    function withdrawFor(
        address _asset,
        address _depositor,
        address _receiver,
        uint256 _amount,
        bool _collateralOnly
    )
        external;
    /// @notice Returns all assets supported by this silo.
    function getAssets() external view returns (address[] memory);
    /// @notice Returns silo state for a specific asset.
    function state(address _asset)
        external
        view
        returns (
            IERC20 _collateralToken,
            IERC20 _collateralOnlyToken,
            IERC20 _debtToken,
            uint256 _totalDeposits,
            uint256 _collateralOnlyDeposits,
            uint256 _totalBorrowAmount
        );
}

