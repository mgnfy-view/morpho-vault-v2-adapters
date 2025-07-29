// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "@openzeppelin-contracts-5.3.0/token/ERC20/IERC20.sol";
import { IVaultV2 } from "morpho-vault-v2-1.0.0/src/interfaces/IVaultV2.sol";

import { SafeERC20 } from "@openzeppelin-contracts-5.3.0/token/ERC20/utils/SafeERC20.sol";

import { IAdapterBase } from "@src/utils/IAdapterBase.sol";

/// @title AdapterBase.
/// @author mgnfy-view.
/// @notice Base contract to be used by all adapters.
abstract contract AdapterBase is IAdapterBase {
    using SafeERC20 for IERC20;

    /// @dev The factory that deployed this contract.
    address internal immutable i_factory;
    /// @dev The Morpho vault v2 contract.
    IVaultV2 internal immutable i_morphoVaultV2;
    /// @dev The asset accepted by the Morpho vault
    address internal immutable i_asset;
    /// @dev a unique identifier for this adapter.
    bytes32 internal immutable i_adapterId;
    /// @dev Can skim reward tokens allocated to this contract.
    address internal s_skimRecipient;

    /// @notice Initializes the contract.
    /// @param _morphoVaultV2 The morpho vault v2 this adapter is attached to.
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
        _requireMorphoVaultV2Owner(msg.sender);

        s_skimRecipient = _newSkimRecipient;

        emit SkimRecipientSet(_newSkimRecipient);
    }

    /// @notice Skims the adapter's balance of `token` and sends it to `skimRecipient`.
    /// This is useful to handle rewards that the adapter has earned.
    /// @param _token The token to skim.
    function skim(address _token) external {
        _requireSkimRecipient(msg.sender);

        IERC20 token = IERC20(_token);
        uint256 balance = token.balanceOf(address(this));

        token.safeTransfer(s_skimRecipient, balance);
        emit Skimmed(_token, balance);
    }

    /// @notice Checks if the caller is the vault owner.
    /// @param _caller The caller address.
    function _requireMorphoVaultV2Owner(address _caller) internal view {
        if (_caller != i_morphoVaultV2.owner()) revert AdapterBase__NotMorphoVaultV2Owner();
    }

    /// @notice Checks if the caller is the skim recipient.
    /// @param _caller The caller address.
    function _requireSkimRecipient(address _caller) internal view {
        if (_caller != s_skimRecipient) revert AdapterBase__NotSkimRecipient();
    }

    /// @notice Gets the factory that deployed this vault.
    /// @return The factory address.
    function getFactory() external view returns (address) {
        return i_factory;
    }

    /// @notice Gets the Morpho vault v2 address.
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
