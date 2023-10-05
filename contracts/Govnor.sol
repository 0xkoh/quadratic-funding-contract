// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Round} from "./Round.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Governor {

    constructor(string memory _name, string memory _version){

    }

    mapping(uint256 => Round) internal _rounds;


    function initialize() external returns(bool) {
        
    }


    function proposeProject() external returns(bool) {

    }

    
    function voteProject() external returns(bool) {

    }


    function poolLock() external {

    }

}