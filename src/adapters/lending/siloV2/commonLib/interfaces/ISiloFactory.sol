// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice Factory interface used to validate Silo deployments.
interface ISiloFactory {
    /// @notice Returns true if `_silo` is a valid Silo v2 deployment.
    function isSilo(address _silo) external view returns (bool);
}
