// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { ArxDiamond, OwnableInternal, SafeOwnable } from '../diamond/ArxDiamond.sol';

contract ArxDiamondMock is ArxDiamond {
    constructor(address owner_) {
        __ArxDiamond_init(owner_);
    }

    function __transferOwnership(address account) public {
        _transferOwnership(account);
    }

    function __getImplementation() public view returns(address) {
        return _getImplementation();
    }
}
