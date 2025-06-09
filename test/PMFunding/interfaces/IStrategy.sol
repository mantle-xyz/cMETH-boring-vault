// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

interface IStrategy {
    function totalShares() external view returns(uint totalShares);
}
