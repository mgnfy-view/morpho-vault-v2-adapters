// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library SanityChecks {
    error SanityChecks__AddressZero();
    error SanityChecks__ValueZero();

    function requireNotAddressZero(address _address) internal pure {
        if (_address == address(0)) revert SanityChecks__AddressZero();
    }

    function requireNotValueZero(uint256 _value) internal pure {
        if (_value == 0) revert SanityChecks__ValueZero();
    }
}
