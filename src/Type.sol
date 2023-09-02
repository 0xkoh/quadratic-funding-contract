// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

contract Type {
    
    // donationsは寄付金の平均値が代入される。
    struct Project {
        string name;
        bytes32 content;
        uint256 contributors;
        uint256 avgDonation;
        uint256 matchAmount;
        bool isProposed;
    }

}