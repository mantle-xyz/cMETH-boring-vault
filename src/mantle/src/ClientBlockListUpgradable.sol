// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {AccessControlEnumerableUpgradeable} from
    "src/mantle/lib/openzeppelin-contracts-upgradeable/contracts/access/extensions/AccessControlEnumerableUpgradeable.sol";
import {Initializable} from "src/mantle/lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import "./interfaces/ITransferBlockList.sol";

/**
 * @title BlocklistClient
 * @notice This abstract contract manages state for upgradeable blocklist
 *         clients
 */
abstract contract BlockListClientUpgradeable is Initializable, IBlockListClient, AccessControlEnumerableUpgradeable {
    // errors
    error BlocklistZeroAddress();
    error BlockedAccount();

    /// @custom:storage-location erc7201:storage.BlockList
    struct BlocklistStorage {
        address blocklist;
    }

    // keccak256(abi.encode(uint256(keccak256("storage.BlockList")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant BlocklistStorageLocation =
        0x8b10dc3a8ffcc75bc517f513160e5993f2893462bfc79b47d34bca818016ba00;

    function _getBlocklistStorage() internal pure returns (BlocklistStorage storage $) {
        assembly {
            $.slot := BlocklistStorageLocation
        }
    }

    /**
     * @notice Initialize the contract by setting blocklist variable
     *
     * @param _blocklist Address of the blocklist contract
     *
     * @dev Function should be called by the inheriting contract on
     *      initialization
     */
    function __BlocklistClientInitializable_init(address _blocklist) internal onlyInitializing {
        __AccessControlEnumerable_init();
        __BlocklistClientInitializable_init_unchained(_blocklist);
    }

    /**
     * @dev Internal function to future-proof parent linearization. Matches OZ
     *      upgradeable suggestions
     */
    function __BlocklistClientInitializable_init_unchained(address _blocklist) internal onlyInitializing {
        _setBlocklist(_blocklist);
    }

    /**
     * @notice Get the blocklist address for this client
     */
    function blocklist() public view virtual returns (address) {
        BlocklistStorage storage $ = _getBlocklistStorage();
        return $.blocklist;
    }

    /**
     * @notice Sets the blocklist address for this client
     *
     * @param _blocklist The new blocklist address
     */
    function setBlocklist(address _blocklist) external virtual {
        _setBlocklist(_blocklist);
    }

    /**
     * @notice Checks whether an address has been blocked
     *
     * @param account The account to check
     */
    function isBlocked(address account) external view virtual returns (bool) {
        return _isBlocked(account);
    }

    /**
     * @notice Sets the blocklist address for this client
     *
     * @param _blocklist The new blocklist address
     */
    function _setBlocklist(address _blocklist) internal {
        if (_blocklist == address(0)) {
            revert BlocklistZeroAddress();
        }
        BlocklistStorage storage $ = _getBlocklistStorage();
        address oldBlocklist = address($.blocklist);
        $.blocklist = _blocklist;
        emit BlocklistSet(oldBlocklist, _blocklist);
    }

    /**
     * @notice Checks whether an address has been blocked
     *
     * @param account The account to check
     */
    function _isBlocked(address account) internal view returns (bool) {
        BlocklistStorage storage $ = _getBlocklistStorage();
        if ($.blocklist.code.length != 0) {
            return IBlockListClient($.blocklist).isBlocked(account);
        }
        return false;
    }
}
