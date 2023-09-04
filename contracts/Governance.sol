// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {QuadraticFunding} from "./QuadraticFunding.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {EnumerableMap} from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ERC2771Context} from "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";


contract Governance is QuadraticFunding, Vote, EIP712 {

    using Math for uint256;
    using Counters for Counters.Counter;

    struct Project {
        bytes32 contents;
        bool isProposed;
        ProjectValue value;
    }

    mapping(uint256 => Project) internal _projects;

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

    constructor(string _name, uint256 _version, address _forwarder) ERC2771Context(_forwarder) {

    }

    function proposeToProject(Project calldata _project, address _sender, bytes32 signature) external returns(bool) {
        assert(isTrustedForwarder());

    }

    function voteToProject() external {

    }

    function fundOf(address _account) view external returns(uint256) {
        require(_matchingPoolAmount.);
        return _matchingPoolAmount.get(_account);
    }

    function getPoolAmount() pure external returns(uint256) {
        return _getPoolAmount();
    }

    function getMatchingAmount(uint256 _id) view external returns(uint256) {
        Project[] mProject;
        for(uint256 i; ) {

        }
        return _calcMatchingAmount(_projects, _id);
    }


}