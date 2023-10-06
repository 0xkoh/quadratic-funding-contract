// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {EnumerableMap} from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";


/// @title A library with generic functions used in Quadratic Funding.
/// @author @0xkoh on Twitter<X> & Github.
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


    /// @dev Calculates the average amount by dividing totalDonation in ProjectValue by contributors. Used for calculating QF Power for each project.
    /// @return solution The average donation amount for the project.
    function _calcAvgDonation(ProjectValue storage _project) view internal returns(uint256 solution) {

        if (_project.contributors < 1) revert EmptyContributors();
        
        solution = _project.totalDonation / _project.contributors;
    }


    /// @dev Function to calculate the QF Power to determine the allocation from the Matching Pool held by the Project.
    /// Calculated using the equation (√avgDonation * contributors)^2.
    /// @return solution The QF Power of the Project.
    function _calcPower(ProjectValue storage _project) view internal returns(uint256 solution) {
        if(_project.contributors < 1) {
            solution = 0;
        } else {
            solution = (_calcAvgDonation(_project).sqrt()*_project.contributors)**2;
        }
    }


    /// @dev Function to initialize the project by entering the Sender and Content for the Project received in the arguments.
    /// @param _sender The account that proposed the project.
    /// @param _content The ipfs hash value where the project's content is registered.
    function _initialize(Project storage _project, address _sender, bytes32 _content) internal returns(bool) {

        if(_project.content != "0x00" && _project.proposer == address(0)) revert AlreadyExistsProject();
        if(_content == "0x00") revert InvalidContent();

        _project.value = ProjectValue({ contributors: 0, totalDonation: 0 });
        _project.proposer = _sender;
        _project.content = _content;

        return true;
    }


    /// @dev Inserts the votes and Donation amount for the Project into a Mapping called donationPool.
    /// @param _sender The voter.
    /// @param _amount Donation amount.
    function _voting(Project storage _project, address _sender, uint256 _amount) internal returns(bool result) {
        
        if(_project.content == "0x00") revert NoExistsProject();
        if(_project.donationPool.contains(_sender)) revert AlreadyVoted();

        result = _setPool(_project.donationPool, _sender, _amount);
        _project.value.contributors += 1;
        _project.value.totalDonation += _amount;

    }


    /// @dev Function to input a value into the matchingPool or donationPool.
    function _setPool(EnumerableMap.AddressToUintMap storage pool, address sender, uint256 amount) internal returns(bool result) {
            
            if(pool.contains(sender)) revert();
    
            result = pool.set(sender, amount);
            if(!result) revert SetNoSuccessful(sender, amount);

    }


}