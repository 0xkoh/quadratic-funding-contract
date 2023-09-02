// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./Type.sol";
import "@openzeppelin/utils/math/Math.sol";
import "@openzeppelin/utils/structs/EnumerableMap.sol";


contract QuadraticFunding is Type {

    using Math for uint256;
    using EnumerableMap for EnumerableMap.AddressToUintMap;

    // amount of matching pool
    EnumerableMap.AddressToUintMap internal matchingPoolAmount;

    // calculate the power of a project.
    function _calcPower(Project calldata _project) pure internal returns(uint256) {
        return (_project.avgDonation.sqrt()*_project.contributors)**2;
    }

    function _calcAvg(uint256 _donation, Project calldata _project) pure internal returns(uint256) {
        return _donation.average(_project.avgDonation);
    }

    // calculate a matched amount from the share pool.
    function _calcMatchingAmount(Project[] calldata projects, uint256 _id) view internal returns(uint256) {
        assert(projects[_id].isProposed && projects[_id].contributors != 0);

        uint256 _totalPower = 0;
        for(uint256 i = 0; i < projects.length; i++) {
            _totalPower += (_calcPower(projects[i]));
        }
        return (_calcPower(projects[_id])/_totalPower)*_getPoolAmount();
    }

    // supported deposit and withdraw.
    function _setPoolAmount(uint256 _amount, address _sender) internal returns(bool) {
        return matchingPoolAmount.set(_sender, _amount);
    }

    function _getPoolAmount() view internal returns(uint256) {
        uint256 _total = 0;
        for(uint256 i = 0; i < matchingPoolAmount.length(); i++) {
            (address sponsor, ) = matchingPoolAmount.at(i);
            _total += matchingPoolAmount.get(sponsor);
        }
        return _total;
    }


}