// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

interface IStrategyManager {
    function stakerDepositShares(address staker, address strategy) external view returns(uint shares);
}
