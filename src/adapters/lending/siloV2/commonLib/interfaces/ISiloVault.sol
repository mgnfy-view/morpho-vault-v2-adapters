// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC4626 } from "@openzeppelin-contracts-5.3.0/token/ERC20/extensions/ERC4626.sol";

/// @notice Silo managed vault interface.
/// @dev ERC4626 meta-vault that allocates into Silo markets via queues.
interface ISiloVault is IERC4626 {
    /// @notice Returns the market vault at index `_index` in the supply queue.
    function supplyQueue(uint256 _index) external view returns (IERC4626);
    /// @notice Returns the market vault at index `_index` in the withdraw queue.
    function withdrawQueue(uint256 _index) external view returns (IERC4626);
    /// @notice Returns the length of the supply queue.
    function supplyQueueLength() external view returns (uint256);
    /// @notice Returns the length of the withdraw queue.
    function withdrawQueueLength() external view returns (uint256);
    /// @notice Returns true if the vault is in a reentrancy-protected state.
    function reentrancyGuardEntered() external view returns (bool);
}
