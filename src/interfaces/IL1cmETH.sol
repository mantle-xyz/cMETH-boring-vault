// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IL1cmETH {
    /// @notice Mint cmETH when deposit mETH
    /// @param _to The address of the owner.
    /// @param _amount The amount minted.
    function mint(address _to, uint256 _amount) external;

    // @dev Burn cmETH
    /// @notice Burn cmETH when claim mETH withdraw
    /// @param _from The address of the burner
    /// @param _amount The amount will burn
    function burn(address _from, uint256 _amount) external;
}
