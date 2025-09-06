// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IAdapter as IMorphoVaultV2Adapter } from "morpho-vault-v2-1.0.0/src/interfaces/IAdapter.sol";

/// @title IAdapterBase.
/// @author mgnfy-view.
/// @notice Interface to be implemented by all adapters.
interface IAdapterBase is IMorphoVaultV2Adapter {
    event SkimRecipientSet(address indexed newSkimRecipient);
    event Skimmed(address indexed token, uint256 indexed balance);

    error AdapterBase__NotMorphoVaultV2Owner();
    error AdapterBase__NotSkimRecipient();
    error AdapterBase__NotAcceptedAsset();

    function setSkimRecipient(address _newSkimRecipient) external;
    function skim(address _token) external;

    function getFactory() external view returns (address);
    function getMorphoVaultV2() external view returns (address);
    function getAsset() external view returns (address);
    function getAdapterId() external view returns (bytes32);
    function getSkimRecipient() external view returns (address);
}
