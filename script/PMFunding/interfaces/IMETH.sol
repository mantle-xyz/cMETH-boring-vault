// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

interface IMETH {
    function mint(address staker, uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint amount) external;
}
