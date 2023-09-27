// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {EnumerableMap} from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";


library QF {

    using Math for uint256;
    using EnumerableMap for EnumerableMap.AddressToUintMap;

    error EmptyContributors();

    error InvalidContent();

    error NoExistsProject();

    error AlreadyVoted();

    error AlreadyExistsProject();

    error SetNoSuccessful(address sender, uint256 amount);

    struct ProjectValue {
        uint256 contributors;
        uint256 totalDonation;
    }

    struct Project {
        address proposer;
        bytes32 content;
        ProjectValue value;
        uint256 totalDonations;
        EnumerableMap.AddressToUintMap donationPool;
    }


    /**
    * @dev calculate the average donation with a project.
    * @param _project The value to be processed.
    */
    function _calcAvgDonation(ProjectValue storage _project) view internal returns(uint256 solution) {

        if (_project.contributors < 1) revert EmptyContributors();
        
        solution = _project.totalDonation / _project.contributors;
    }


    /**
    * @dev calculate the power of a project.
    * @param _project The value to be processed.
    */
    function _calcPower(ProjectValue storage _project) view internal returns(uint256 solution) {
        solution = (_calcAvgDonation(_project).sqrt()*_project.contributors)**2;
    }
 

    /**
    * @dev calculate a matched amount from the pool.
    * @param _totalMatchingPoolVolume The value to be processed.
    */
    function _calcMatchingVolume(ProjectValue[] storage _projects, uint256 _projectId, uint256 _totalMatchingPoolVolume) view internal returns(uint256 solution) {

        if(_projects[_projectId].contributors != 0) revert EmptyContributors();

        uint256 _totalPower = 0;
        for(uint256 i = 0; i < _projects.length; i++) {
            _totalPower += _calcPower(_projects[i]);
        }
        solution = (_calcPower(_projects[_projectId])/_totalPower)*_totalMatchingPoolVolume;
    }


    /**
    * @dev This function does something interesting.
    * @param _project The value to be processed.
    */
    function _initialize(Project storage _project, address _sender, bytes32 _content) internal {

        if(_project.content != "0x00" && _project.proposer == address(0)) revert AlreadyExistsProject();
        if(_content == "0x00") revert InvalidContent();

        _project.value = ProjectValue({ contributors: 0, totalDonation: 0 });
        _project.proposer = _sender;
        _project.content = _content;

    }


    /**
    * @dev This function does something interesting.
    * @param _project The value to be processed.
    */
    function _voting(Project storage _project, address _sender, uint256 _amount) internal returns(bool result) {
        
        if(_project.content == "0x00") revert NoExistsProject();
        if(_project.donationPool.contains(_sender)) revert AlreadyVoted();

        result = _project.donationPool.set(_sender, _amount);
        if(!result) revert SetNoSuccessful(_sender, _amount);

        _project.value.contributors += 1;
        _project.value.totalDonation += _amount;

    }


    /**
    * @dev This function does something interesting.
    * @param matchingPool The value to be processed.
    */
    function _setMatchingPool(EnumerableMap.AddressToUintMap storage matchingPool, address sender, uint256 amount) internal returns(bool result) {
        
        if(matchingPool.contains(sender)) revert();

        result = matchingPool.set(sender, amount);
        if(!result) revert SetNoSuccessful(sender, amount);
    }

}