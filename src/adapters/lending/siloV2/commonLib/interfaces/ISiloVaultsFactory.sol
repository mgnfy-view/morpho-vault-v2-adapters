// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ISiloVaultsFactory {
    /// @notice Returns true if `_siloVault` was deployed/registered by this factory.
    /// @param _siloVault The SiloVault address to validate.
    /// @return True if `_siloVault` is recognized by this factory.
    function isSiloVault(address _siloVault) external view returns (bool);
}
