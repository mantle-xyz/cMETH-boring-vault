// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

interface IVault {
    function depositWhitelist() external view returns(bool);
    function isDepositorWhitelisted(address account) external view returns(bool);
    function activeStake() external view returns (uint256);
    function activeShares() external view returns (uint256);
    function activeSharesOf(address account) external view returns (uint256);
    function setDepositorWhitelistStatus(address account, bool status) external;
    function epochDurationInit() external view returns(uint48);
    function epochDuration() external view returns(uint48);
}
