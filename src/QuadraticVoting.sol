// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./Type.sol";
import "@openzeppelin/utils/math/Math.sol";

contract QuadraticFunding {
  using Math for uint256;
	
  struct Project {
    uint256 id;
    uint256 contributors;
    uint256 donations;
    uint256 matchAmount;
  }

  function _calcPower(Project calldata _p) 
    view
    internal
    returns(uint256)
  {
    return (_p.donations.sqrt()*_p.contributor)**2;
  }

}