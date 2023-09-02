// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./Type.sol";
import "./QuadraticFunding.sol";
import "@openzeppelin/utils/math/Math.sol";
import "@openzeppelin/utils/structs/EnumerableMap.sol";

contract Governance is QuadraticFunding {

    EnumerableMap.AddressToUintMap internal matchingPoolAmount;
    
}