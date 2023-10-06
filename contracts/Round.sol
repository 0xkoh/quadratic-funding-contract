// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {QF} from "./QF.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {EnumerableMap} from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ERC2771Context} from "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";


contract Round {

    using Math for uint256;
    using EnumerableMap for EnumerableMap.AddressToUintMap;

    error AlreadyLocked();

    uint256 ROUND;
    IERC20Permit ERC2612;
    IERC20 ERC20;
    address owner;
    bool locked;

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

    
    modifier onlyOwner() {
        if(msg.sender != owner) revert("Not the owner");
        _;
    }


    constructor(
        uint256 _round,
        address _owner,
        address _token
    ) {
        ROUND = _round;
        owner = _owner;
        ERC2612 = IERC20Permit(_token);
        ERC20 = IERC20(_token);
    }


    /// @notice Operation to add a project to the Round.
    /// @dev Registers ipfs content and projectId using _initialize.
    /// @return result Result of the project registration.
    function proposing(
        bytes32 _content,
        uint256 _projectId
    ) external isProposed(_projectId) returns(bool result) {

        if(locked) revert AlreadyLocked();

        // set state.
        QF._initialize(projects[_projectId],  msg.sender, _content);
        index.push(_projectId);

        result = true;
    }


    /// @notice Operation to vote for a Project and send a Donation.
    /// @dev After executing the ERC20 transfer, the Donation to the project and the voter's address are registered with _voting.
    /// @return result Result of voting for the project.
    function voting(
        uint256 _projectId,
        uint256 _amount,
        bytes memory signature
    ) external isProposed(_projectId) returns(bool result) {

        if(locked) revert AlreadyLocked();
        if(_amount > 1) revert();        

        (uint8 v, bytes32 r, bytes32 s) = extractFromSig(signature);
        ERC2612.permit(msg.sender, address(this), _amount, 1200, v, r, s);
        ERC20.transferFrom(msg.sender, address(this), _amount);

        // set state.
        result = QF._voting(projects[_projectId], msg.sender, _amount);
    }


    /// @notice Operation to donate grants to a project on Round.
    /// @dev Operation to store _amount and sender to the matchingPool.
    /// @return result The result of input to the matchingPool.
    function addFund(
        uint256 _amount,
        bytes memory signature
    ) external returns(bool result) {

        if(locked) revert AlreadyLocked();

        (uint8 v, bytes32 r, bytes32 s) = extractFromSig(signature);
        ERC2612.permit(msg.sender, address(this), _amount, 1200, v, r, s);
        ERC20.transferFrom(msg.sender, address(this), _amount);

        totalMatchingPoolVolume += _amount;
        result = QF._setPool(matchingPool ,msg.sender, _amount);
    }


    /// @notice Function to lock the round, executable only by the administrator.
    /// @dev Sets locked to true, making the Round state unmodifiable.
    function lock(bool doExecute) external onlyOwner {
        locked = true;
        if(doExecute) {
            distribute();
        }
    }


    /// @dev Function to distribute from Pool based on the QF equation to the projects in Round.
    /// @return Explicitly returns the result of the distribution run.
    function distribute() internal onlyOwner returns(bool) {
        if(!locked) revert();
        
        for(uint256 i = 0; i < index.length; i++) {
            uint256 amount = calcMatchingAmount(index[i]);
            ERC20.transfer(projects[i].proposer, amount);
        }
        return true;
    }


    /// @dev Refers to the projects mapping using _ProjectId to calculate the amount of grants matching the project.
    /// @return solution The calculated matching amount.
    function calcMatchingAmount(uint256 _projectId) view public returns(uint256 solution) {
        
        if(projects[_projectId].value.contributors != 0) revert();

        uint256 totalPower = 0;
        for(uint256 i = 0; i < index.length; i++) {
            totalPower += QF._calcPower(projects[index[i]].value);
        }

        solution = (QF._calcPower(projects[_projectId].value)/totalPower)*totalMatchingPoolVolume;
    }


    /// @dev Get the amount of mapped an account from matchingPool.
    /// @return return an amount of fund the pool.
    function fundOf(address _account) view public returns(uint256) {
        require(matchingPool.contains(_account));
        return matchingPool.get(_account);
    }


    /// @dev Function to retrieve the donation amount from the DonationPool held by the Project.
    /// @return The donation amount for the Project.
    function donationOf(
        address _account,
        uint256 _ProjectId
    ) view public isProposed(_ProjectId) returns(uint256) {
        require(projects[_ProjectId].donationPool.contains(_account));
        return projects[_ProjectId].donationPool.get(_account);
    }


    /// @dev Return the number of projects represented by the element count of index.
    function projectsOf() view public returns(uint256) {
        require(index.length != 0, "No projects are proposed.");
        return index.length;
    }


    /// @dev Extract v,r,s from signature.
    function extractFromSig(bytes memory signature) internal pure returns (uint8 v, bytes32 r, bytes32 s) {

        if(signature.length == 65) revert("Invalid signature length");

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        return (v, r, s);
    }

}