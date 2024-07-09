// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Initializable} from "openzeppelin-upgradeable/proxy/utils/Initializable.sol";
import {ISanctionsListClient} from "./interfaces/ITransferSanctionList.sol";

/**
 * @title SanctionsListClient
 * @notice This abstract contract manages state for upgradeable sanctionsList
 *         clients
 */
abstract contract SanctionsListClientUpgradeable is Initializable, ISanctionsListClient {
    // errors
    /// @notice Error for when caller attempts to set the `sanctionsList` reference to the zero address
    error SanctionsListZeroAddress();
    /// @notice Error for when caller attempts to perform an action on a sanctioned account
    error SanctionedAccount();

    /// @custom:storage-location erc7201:storage.BareVault
    struct SanctionsListStorage {
        address sanctionsList;
    }

    // keccak256(abi.encode(uint256(keccak256("storage.SanctionsList")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant SanctionsListStorageLocation = 0x446d7f77ff282b2aa61ea27272a164f51bf50ee624d04aed3bd04af3b9af8f00;

    function _getSanctionsListStorage() internal pure returns (SanctionsListStorage storage $) {
        assembly {
            $.slot := SanctionsListStorageLocation
        }
    }

    /**
     * @notice Initialize the contract by setting SanctionsList variable
     *
     * @param _sanctionsList Address of the sanctionsList contract
     *
     * @dev Function should be called by the inheriting contract on
     *      initialization
     */
    function __SanctionsListClientInitializable_init(address _sanctionsList) internal onlyInitializing {
        __SanctionsListClientInitializable_init_unchained(_sanctionsList);
    }

    /**
     * @dev Internal function to future-proof parent linearization. Matches OZ
     *      upgradeable suggestions
     */
    function __SanctionsListClientInitializable_init_unchained(address _sanctionsList) internal onlyInitializing {
        _setSanctionsList(_sanctionsList);
    }

    /**
     * @notice Sets the sanctionsList address for this client
     */
    function sanctionsList() public virtual view returns (address) {
        SanctionsListStorage storage $ = _getSanctionsListStorage();
        return $.sanctionsList;
    }

    /**
     * @notice Sets the sanctionsList address for this client
     *
     * @param _sanctionsList The new sanctionsList address
     */
    function setSanctionsList(address _sanctionsList) external virtual {
        _setSanctionsList(_sanctionsList);
    }

    /**
     * @notice Checks whether an address has been blocked
     *
     * @param account The account to check
     */
    function isSanctioned(address account) external virtual view returns (bool) {
        return _isSanctioned(account);
    }

    /**
     * @notice Sets the sanctionsList address for this client
     *
     * @param _sanctionsList The new sanctionsList address
     */
    function _setSanctionsList(address _sanctionsList) internal {
        if (_sanctionsList == address(0)) {
            revert SanctionsListZeroAddress();
        }
        SanctionsListStorage storage $ = _getSanctionsListStorage();
        address oldSanctionsList = address($.sanctionsList);
        $.sanctionsList = _sanctionsList;
        emit SanctionsListSet(oldSanctionsList, _sanctionsList);
    }

    /**
   * @notice Checks whether an address has been blocked
     *
     * @param account The account to check
     */
    function _isSanctioned(address account) internal view returns (bool) {
        SanctionsListStorage storage $ = _getSanctionsListStorage();
        if ($.sanctionsList.code.length != 0) {
            return ISanctionsListClient($.sanctionsList).isSanctioned(account);
        }
        return false;
    }
}
