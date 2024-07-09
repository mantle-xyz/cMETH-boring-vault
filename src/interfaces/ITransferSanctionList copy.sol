// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// @dev inspired by ONDO-USDY
interface ISanctionsListClient {
    /// @notice Returns address of the sanctions list that this client setup
    function sanctionsList() external view returns (address);

    /// @notice Update the sanctions list reference
    function setSanctionsList(address sanctionsList) external;

    // @notice check is the address is sanctioned
    function isSanctioned(address addr) external view returns (bool);

    /**
     * @dev Event for when the sanctions list reference is set
     * @param oldSanctionsList The old list
     * @param newSanctionsList The new list
     */
    event SanctionsListSet(address oldSanctionsList, address newSanctionsList);
}

interface IISanctionsList {
    function addToSanctionsList(address[] calldata accounts) external;
    function removeFromSanctionsList(address[] calldata accounts) external;
    function isSanctioned(address account) external view returns (bool);

    /**
     * @dev Event for when the sanctions list reference is set
     * @param addr The address sanctioned
     */
    event SanctionedAddress(address indexed addr);

    /**
     * @dev Event for when the sanctions list reference is set
     * @param addr The address not sanctioned
     */
    event NonSanctionedAddress(address indexed addr);

    /**
     * @dev Event for when the sanctions list reference is set
     * @param addrs The address list sanctioned
     */
    event SanctionedAddressesAdded(address[] addrs);

    /**
     * @dev Event for when the sanctions list reference is set
     * @param addrs The address list not sanctioned
     */
    event SanctionedAddressesRemoved(address[] addrs);
}
