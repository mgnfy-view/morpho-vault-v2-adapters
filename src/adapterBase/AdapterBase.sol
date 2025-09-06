// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "@openzeppelin-contracts-5.3.0/token/ERC20/IERC20.sol";
import { IVaultV2 } from "morpho-vault-v2-1.0.0/src/interfaces/IVaultV2.sol";

import { SafeERC20 } from "@openzeppelin-contracts-5.3.0/token/ERC20/utils/SafeERC20.sol";

import { IAdapterBase } from "@src/adapterBase/interfaces/IAdapterBase.sol";

import { SanityChecks } from "@src/utils/SanityChecks.sol";

/// @title AdapterBase.
/// @author mgnfy-view.
/// @notice Base contract that holds utility functionality to be used by all
/// adapters by means of composition.
abstract contract AdapterBase is IAdapterBase {
    using SafeERC20 for IERC20;
    using SanityChecks for address;
    using SanityChecks for uint256;

    /// @dev The factory that deployed this contract.
    address internal immutable i_factory;
    /// @dev The Morpho vault v2 contract.
    IVaultV2 internal immutable i_morphoVaultV2;
    /// @dev The asset accepted by the Morpho vault
    address internal immutable i_asset;
    /// @dev A unique identifier for this adapter.
    bytes32 internal immutable i_adapterId;
    /// @dev Address that can skim tokens sent to this contract. These tokens may be
    /// airdrop tokens, reward tokens from Merkl campaigns, etc. The skim recipient
    /// should have the necessary infrastructure to fairly distribute these tokens
    /// to the vault depositors.
    address internal s_skimRecipient;

    /// @notice Initializes the contract.
    /// @param _morphoVaultV2 The morpho vault v2 instance this adapter is attached to.
    /// @param _initialSkimRecipient The initial skm recipient address.
    constructor(address _morphoVaultV2, address _initialSkimRecipient) {
        i_factory = msg.sender;
        i_morphoVaultV2 = IVaultV2(_morphoVaultV2);
        i_asset = i_morphoVaultV2.asset();
        i_adapterId = keccak256(abi.encode("this", address(this)));
        s_skimRecipient = _initialSkimRecipient;
    }

    /// @notice Sets the new skim recipient.
    /// @param _newSkimRecipient The new skim recipient address.
    function setSkimRecipient(address _newSkimRecipient) external {
        _requireCallerIsMorphoVaultV2Owner(msg.sender);
        _newSkimRecipient.requireNotAddressZero();

        s_skimRecipient = _newSkimRecipient;

        emit SkimRecipientSet(_newSkimRecipient);
    }

    /// @notice Skims the adapter's balance of `_token` and sends it to `skimRecipient`.
    /// This is useful to handle rewards that the adapter has earned.
    /// @param _token The token to skim.
    function skim(address _token) external {
        _requireCallerIsSkimRecipient(msg.sender);

        IERC20 token = IERC20(_token);
        uint256 balance = token.balanceOf(address(this));

        token.safeTransfer(s_skimRecipient, balance);

        emit Skimmed(_token, balance);
    }

    /// @dev Reverts if the caller is not Morpho vault v2 instance this adapter
    /// is attached to.
    /// @param _caller The caller address.
    function _requireCallerIsMorphoVault(address _caller) internal view {
        if (_caller != address(i_morphoVaultV2)) revert AdapterBase__NotMorphoVault();
    }

    /// @dev Reverts if the caller is not the vault owner.
    /// @param _caller The caller address.
    function _requireCallerIsMorphoVaultV2Owner(address _caller) internal view {
        if (_caller != i_morphoVaultV2.owner()) revert AdapterBase__NotMorphoVaultV2Owner();
    }

    /// @dev Reverts if the `_asset` is not the asset accepted by the vault.
    /// @param _asset The asset address.
    function _requireIsAcceptedAsset(address _asset) internal view {
        if (_asset != i_morphoVaultV2.asset()) revert AdapterBase__NotAcceptedAsset();
    }

    /// @dev Reverts if the caller is not the skim recipient.
    /// @param _caller The caller address.
    function _requireCallerIsSkimRecipient(address _caller) internal view {
        if (_caller != s_skimRecipient) revert AdapterBase__NotSkimRecipient();
    }

    /// @notice Gets the factory address that deployed this vault.
    /// @return The factory address.
    function getFactory() external view returns (address) {
        return i_factory;
    }

    /// @notice Gets the Morpho vault v2 address this adapter is attached to.
    /// @return The vault address.
    function getMorphoVaultV2() external view returns (address) {
        return address(i_morphoVaultV2);
    }

    /// @notice Gets the asset accepted by the vault.
    /// @return The asset address.
    function getAsset() external view returns (address) {
        return i_asset;
    }

    /// @notice Gets the adapter ID.
    /// @return The bytes32 adapter ID.
    function getAdapterId() external view returns (bytes32) {
        return i_adapterId;
    }

    /// @notice Gets the skim recipient address.
    /// @return The skim recipient address.
    function getSkimRecipient() external view returns (address) {
        return s_skimRecipient;
    }
}
