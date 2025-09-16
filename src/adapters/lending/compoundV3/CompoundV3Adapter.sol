// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ICompoundV3Adapter } from "@src/adapters/lending/compoundV3/interfaces/ICompoundV3Adapter.sol";
import { IComet } from "@src/adapters/lending/compoundV3/lib/interfaces/IComet.sol";
import { IConfigurator } from "@src/adapters/lending/compoundV3/lib/interfaces/IConfigurator.sol";

import { AdapterBase } from "@src/adapterBase/AdapterBase.sol";
import { CometConfiguration } from "@src/adapters/lending/compoundV3/lib/libraries/types/CometConfiguration.sol";

/// @title CompoundV3Adapter.
/// @author mgnfy-view.
/// @notice Compound v3 adapter for Morpho vault v2. This adapter uses two functions `supply` and
/// `withdraw` to allocate to and deallocate from Compound v3 comet instances respectively.
contract CompoundV3Adapter is AdapterBase, ICompoundV3Adapter {
    /// @dev The Compound v3 configurator that can deploy and configure comet instances.
    IConfigurator internal immutable i_configurator;
    /// @dev List of Compound v3 comet instances to supply tokens to.
    IComet[] internal s_comets;

    /// @dev Initializes the contract.
    /// @param _morphoVaultV2 The Morpho vault v2 contract.
    /// @param _configurator The Compound v3 configurator that can deploy and configure comet instances.
    constructor(address _morphoVaultV2, address _configurator) AdapterBase(_morphoVaultV2) {
        i_configurator = IConfigurator(_configurator);
    }

    /// @notice Supplies assets to the given Compound v3 comet instance.
    /// @param _data Abi encoded Compound v3 comet address.
    /// @param _assets The amount of assets to supply.
    /// @return A list of IDs associated with the Compound v3 comet instance.
    /// @return The delta change in the amount of assets held by this adapter.
    function allocate(
        bytes memory _data,
        uint256 _assets,
        bytes4,
        address
    )
        external
        returns (bytes32[] memory, int256)
    {
        _requireCallerIsMorphoVault(msg.sender);

        (address cometAddr) = abi.decode(_data, (address));
        IComet comet = IComet(cometAddr);

        _requireValidCometInstance(comet);

        if (_assets > 0) {
            i_asset.approve(cometAddr, _assets);
            comet.supply(address(i_asset), _assets);
        }

        uint256 oldAllocation = getAllocation(cometAddr);
        uint256 newAllocation = comet.balanceOf(address(this));
        _updateCometsList(comet, oldAllocation, newAllocation);

        // forge-lint: disable-next-line(unsafe-typecast)
        return (getIds(cometAddr), int256(newAllocation) - int256(oldAllocation));
    }

    /// @notice Withdraws assets from the given Aave v3 pool.
    /// @param _data Abi encoded Aave v3 pool address.
    /// @param _assets The amount of assets to withdraw.
    /// @return A list of IDs associated with the Aave v3 pool.
    /// @return The delta change in the amount of assets held by this adapter.
    function deallocate(
        bytes memory _data,
        uint256 _assets,
        bytes4,
        address
    )
        external
        returns (bytes32[] memory, int256)
    {
        _requireCallerIsMorphoVault(msg.sender);

        (address cometAddr) = abi.decode(_data, (address));
        IComet comet = IComet(cometAddr);

        _requireValidCometInstance(comet);

        if (_assets > 0) {
            comet.withdraw(address(i_asset), _assets);
        }

        uint256 oldAllocation = getAllocation(cometAddr);
        uint256 newAllocation = comet.balanceOf(address(this));
        _updateCometsList(comet, oldAllocation, newAllocation);

        // forge-lint: disable-next-line(unsafe-typecast)
        return (getIds(cometAddr), int256(newAllocation) - int256(oldAllocation));
    }

    /// @dev Reverts if the given comet instance is not a valid one. A comet instance is not valid if its
    /// base token is not the same as the Morpho vault's accepted asset.
    /// @param _comet The Compound v3 comet instance.
    function _requireValidCometInstance(IComet _comet) internal view {
        CometConfiguration.Configuration memory config = i_configurator.getConfiguration(address(_comet));
        if (config.governor == address(0) || config.baseToken == address(0) || _comet.baseToken() != address(i_asset)) {
            revert CompoundV3Adapter__InvalidCometInstance();
        }
    }

    /// @dev Updates the list of Compound v3 comet instances the adapter has supplied to. If the allocation to a
    /// pool becomes 0, the pool is popped from the list.
    /// @param _comet The comet instance to add/pop. Or no-op if allocation is greater than 0 and the comet address
    /// is already in the list.
    /// @param _oldAllocation The amount of assets held by the adapter in the given pool before the
    /// allocate/deallocate call.
    /// @param _newAllocation The amount of assets held by the adapter in the given pool after the
    /// allocate/deallocate call.
    function _updateCometsList(IComet _comet, uint256 _oldAllocation, uint256 _newAllocation) internal {
        uint256 cometAddressesArrayLength = s_comets.length;

        if (_oldAllocation > 0 && _newAllocation == 0) {
            for (uint256 i = 0; i < cometAddressesArrayLength; i++) {
                if (s_comets[i] == _comet) {
                    s_comets[i] = s_comets[cometAddressesArrayLength - 1];
                    s_comets.pop();
                    break;
                }
            }
        } else if (_oldAllocation == 0 && _newAllocation > 0) {
            s_comets.push(_comet);
        }
    }

    /// @notice Gets the total amount of assets held by this adapter in Aave v3 pools.
    /// @return Real assets held by this adapter in Aave v3 pools.
    function realAssets() external view returns (uint256) {
        uint256 cometAddressesArrayLength = s_comets.length;
        uint256 amountRealAssets;

        for (uint256 i = 0; i < cometAddressesArrayLength; ++i) {
            amountRealAssets += s_comets[i].balanceOf(address(this));
        }

        return amountRealAssets;
    }

    /// @notice Gets the comet configurator address.
    /// @return The comet configurator address.
    function getConfigurator() external view returns (address) {
        return address(i_configurator);
    }

    /// @notice Gets the number of comet instances this adapter has supplied tokens to.
    /// @return The number of comet instances this adapter has supplied tokens to.
    function getCometsListLength() external view returns (uint256) {
        return s_comets.length;
    }

    /// @notice Gets the comet address at the given index in the active comets list.
    /// @param _index The array index.
    /// @return The comet address at the given index.
    function getComet(uint256 _index) external view returns (address) {
        return address(s_comets[_index]);
    }

    /// @notice Gets all the IDs associated with the given Aave v3 pool.
    /// @param _comet The Compound v3 comet address.
    /// @return A list of bytes32 IDs.
    function getIds(address _comet) public view returns (bytes32[] memory) {
        bytes32[] memory ids = new bytes32[](2);
        ids[0] = i_adapterId;
        ids[1] = keccak256(abi.encode("this/pool", address(this), _comet));

        return ids;
    }

    /// @notice Gets the assets allocated to the given Compound v3 comet.
    /// @param _comet The Compound v3 comet address.
    /// @return The amount allocated to the comet instance.
    function getAllocation(address _comet) public view returns (uint256) {
        return i_morphoVaultV2.allocation(getIds(_comet)[1]);
    }
}
