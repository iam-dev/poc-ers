// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import { ISafeOwnable, IOwnable } from "@solidstate/contracts/access/ownable/ISafeOwnable.sol";
import { IERC165 } from "@solidstate/contracts/interfaces/IERC165.sol";
import { IERC173 } from "@solidstate/contracts/interfaces/IERC173.sol";

import { IDiamondBase } from "@solidstate/contracts/proxy/diamond/base/IDiamondBase.sol";
import { IDiamondFallback } from "@solidstate/contracts/proxy/diamond/fallback/IDiamondFallback.sol";
import { IDiamondReadable } from "@solidstate/contracts/proxy/diamond/readable/IDiamondReadable.sol";
import { IDiamondWritable } from "@solidstate/contracts/proxy/diamond/writable/IDiamondWritable.sol";

interface IArxDiamond is
    IDiamondBase,
    IDiamondFallback,
    IDiamondReadable,
    IDiamondWritable,
    ISafeOwnable,
    IERC165
{
    receive() external payable;
}
