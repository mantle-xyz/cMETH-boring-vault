// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

interface ISymbioticPM {
    struct PositionConfig {
        address vault;
    }
    function positionConfig() external view returns(PositionConfig memory);
    function WNATIVE() external view returns(address);
    function collateral() external view returns(address);
    function lastWithdrawalEpochProcessed() external view returns(uint);
    function deposit(uint _collateral_in, uint _min_shares_out) external;
    function startWithdrawal(uint _shares_amount) external;
    function completeNextWithdrawals(uint _min_out) external;
    function getCurrentEpoch() external view returns (uint);
}
