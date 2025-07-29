// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAdapterBase {
    event SkimRecipientSet(address indexed newSkimRecipient);
    event Skimmed(address indexed token, uint256 indexed balance);

    error AdapterBase__NotMorphoVaultV2Owner();
    error AdapterBase__NotSkimRecipient();

    function setSkimRecipient(address _newSkimRecipient) external;
    function skim(address _token) external;
    function getFactory() external view returns (address);
    function getMorphoVaultV2() external view returns (address);
    function getAsset() external view returns (address);
    function getAdapterId() external view returns (bytes32);
    function getSkimRecipient() external view returns (address);
}
