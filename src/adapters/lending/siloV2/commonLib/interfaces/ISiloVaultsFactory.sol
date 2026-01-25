// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC4626 } from "@openzeppelin-contracts-5.3.0/interfaces/IERC4626.sol";

import { ISiloVault } from "@src/adapters/lending/siloV2/commonLib/interfaces/ISiloVault.sol";

interface IIncentivesClaimingLogic { }

interface IIncentivesClaimingLogicFactory { }

interface ISiloVaultsFactory {
    /// @notice Returns true if `_siloVault` was deployed/registered by this factory.
    /// @param _siloVault The SiloVault address to validate.
    /// @return True if `_siloVault` is recognized by this factory.
    function isSiloVault(address _siloVault) external view returns (bool);

    /// @notice Creates a new SiloVault vault.
    /// @param _initialOwner The owner of the vault.
    /// @param _initialTimelock The initial timelock of the vault.
    /// @param _asset The address of the underlying asset.
    /// @param _name The name of the vault.
    /// @param _symbol The symbol of the vault.
    /// @param _externalSalt The external salt to use for the creation of the SiloVault vault.
    /// @param _notificationReceiver The notification receiver for the vault pre-configuration.
    /// @param _claimingLogics Incentive claiming logics for the vault pre-configuration.
    /// @param _marketsWithIncentives The markets with incentives for the vault pre-configuration.
    /// @param _trustedFactories Trusted factories for the vault pre-configuration.
    function createSiloVault(
        address _initialOwner,
        uint256 _initialTimelock,
        address _asset,
        string memory _name,
        string memory _symbol,
        bytes32 _externalSalt,
        address _notificationReceiver,
        IIncentivesClaimingLogic[] memory _claimingLogics,
        IERC4626[] memory _marketsWithIncentives,
        IIncentivesClaimingLogicFactory[] memory _trustedFactories
    )
        external
        returns (ISiloVault SiloVault);
}
