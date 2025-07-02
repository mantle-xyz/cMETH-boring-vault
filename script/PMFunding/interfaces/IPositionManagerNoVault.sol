// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

interface IPositionManagerNoVault {
  function getTotalCollateral() external view returns (uint);
}
