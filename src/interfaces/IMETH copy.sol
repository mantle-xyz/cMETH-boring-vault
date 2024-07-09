// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IMETH {
    /// @notice exchange rate for mETH ot ETH.
    function ethToMETH(uint256 ethAmount) external view returns (uint256);
}
