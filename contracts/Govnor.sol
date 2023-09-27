// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {GovPool} from "./GovPool.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Governor {

    constructor(string memory _name, string memory _version){

    }

    // EIP712 calldata.
    struct Propose {
        uint256 id;
        string name;
        bytes content;
    }

    struct Ballot {
        uint256 id;
        uint256 amount;
    }

    struct Message {
        string method;
        address sender;
        Propose propose;
        Ballot ballot;
    }

    mapping(uint256 => GovPool) internal _rounds;


    function initialize() external returns(bool) {
        
    }


    function proposeProject() external returns(bool) {

    }

    
    function voteProject() external returns(bool) {

    }


    function poolLock() external {

    }

}