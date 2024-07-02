// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// @dev inspired by ONDO-USDY
interface IBlockListClient {
    /// @notice Returns the address of the blocklist that this client setup
    function blocklist() external view returns (address);

    /// @notice Update the blocklist address
    function setBlocklist(address registry) external;

    /// @notice Check if a address is blocked or not
    function isBlocked(address account) external view returns (bool);

    /**
     * @dev Event for when the blocklist reference is set
     * @param oldBlocklist The old blocklist
     * @param newBlocklist The new blocklist
     */
    event BlocklistSet(address oldBlocklist, address newBlocklist);
}

interface IBlockList {
    function addToBlocklist(address[] calldata accounts) external;
    function removeFromBlocklist(address[] calldata accounts) external;
    function isBlocked(address account) external view returns (bool);

    /**
     * @notice Event emitted when addresses are added to the blocklist
     * @param accounts The addresses that were added to the blocklist
     */
    event BlockedAddressesAdded(address[] accounts);

    /**
     * @notice Event emitted when addresses are removed from the blocklist
     * @param accounts The addresses that were removed from the blocklist
     */
    event BlockedAddressesRemoved(address[] accounts);
}
