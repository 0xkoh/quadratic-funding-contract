// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {QF} from "./QF.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {EnumerableMap} from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ERC2771Context} from "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract Round is EIP712 {

    using Math for uint256;
    using EnumerableMap for EnumerableMap.AddressToUintMap;

    uint256 ROUND;
    ERC20 TOKEN;

    mapping(uint256 => QF.Project) internal projects;
    uint256[] internal index;

    // Matching Pool State.
    EnumerableMap.AddressToUintMap internal matchingPool;
    uint256 public totalMatchingPoolVolume;

    // EIP712 calldata.
    struct Propose {
        bytes32 content;
        uint256 projectId;
    }

    struct Ballot {
        uint256 projectId;
        uint256 amount;
    }

    struct Message {
        address sender;
        Propose propose;
        Ballot ballot;
    }

    // check that the project already exists.
    modifier isProposed(uint256 _projectId) {
        require(projects[_projectId].content == "0x00", "The project has already been proposed.");
        _;
    }

    constructor(
        uint256 _round,
        address _token,
        string memory _name,
        string memory _version
    ) EIP712(_name, _version) {
        ROUND = _round;
        TOKEN = IERC20Permit(_token);
    }


    function proposing(
        bytes32 _content,
        uint256 _projectId
    ) external isProposed(_projectId) returns(bool result) {

        // set state.
        QF._initialize(projects[_projectId],  msg.sender, _content);
        index.push(_projectId);

        result = true;
    }


    function voting(
        uint256 _projectId,
        uint256 _amount
    ) external isProposed(_projectId) returns(bool result) {

        // set state.
        result = QF._voting(projects[_projectId], msg.sender, _amount);

    }


    // supported deposit and withdraw.
    function addFund(
        uint256 _amount
    ) external returns(bool) {

        TOKEN.permit({
            owner: msg.sender,
            spender: address(this),
            value: _amount,
            deadline: block.timestamp + 1000000000,
            v: 0,
            r: 0x00,
            s: 0x00
        });

        // set state.
        totalMatchingPoolVolume += _amount;
        return QF._setMatchingPool(matchingPool ,msg.sender, _amount);
    }


    function calcMatchingAmount(uint256 _projectId) view public returns(uint256 solution) {
        
        if(projects[_projectId].value.contributors != 0) revert();
        if(projects[_projectId].proposer == address(0)) revert();
        if(projects[_projectId].content == "0x00") revert();

        uint256 totalPower = 0;
        for(uint256 i = 0; i < index.length; i++) {
            totalPower += QF._calcPower(projects[index[i]].value);
        }

        solution = (QF._calcPower(projects[_projectId].value)/totalPower)*totalMatchingPoolVolume;
    }


     // get the amount of the fund.
    function fundOf(address _account) view public returns(uint256) {
        require(matchingPool.contains(_account));
        return matchingPool.get(_account);
    }


    function donationOf(address _account, uint256 _ProjectId) view public isProposed(_ProjectId) returns(uint256) {
        require(projects[_ProjectId].donationPool.contains(_account));
        return projects[_ProjectId].donationPool.get(_account);
    }


    function avgDonationOf(uint256 _projectId) view public isProposed(_projectId) returns(uint256) {
        return QF._calcAvgDonation(projects[_projectId].value);
    }


    function projectsOf() view public returns(uint256) {
        require(index.length != 0, "No projects are proposed.");
        return index.length;
    }


    function _getMatchingPool() view internal returns(uint256) {
        uint256 _totalAmount = 0;
        for(uint256 i = 0; i < matchingPool.length(); i++) {
            (address sponsor, ) = matchingPool.at(i);
            _totalAmount += matchingPool.get(sponsor);
        }
        return _totalAmount;
    }


    // function _isValidSignature(
    //     bytes calldata _signature,
    //     Message calldata _message
    // ) view internal returns(address signer) {
    //     bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
    //         keccak256("content(address sender,string content,uint256 projectId,uint256 projectId,uint256 amount)"),
    //         _message.sender,
    //         _message.propose.content,
    //         _message.propose.projectId,
    //         _message.ballot.projectId,
    //         _message.ballot.amount
    //     )));
    //     signer = ECDSA.recover(digest, _signature);
    // }

}