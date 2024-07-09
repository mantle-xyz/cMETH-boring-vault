// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { OAppCoreUpgradeable } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/OAppCoreUpgradeable.sol";
import { OAppSenderUpgradeable } from  "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/OAppSenderUpgradeable.sol";
import {AccessControlEnumerableUpgradeable} from"openzeppelin-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";
import { ILayerZeroEndpointV2, MessagingFee, MessagingReceipt, Origin } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";

import {IL1StatusWrite, IStatusRead, PauserEvents} from "./interfaces/IMessagingStatus.sol";

/// @title Pauser
/// @notice Keeps the state of all actions that can be paused in case of exceptional circumstances. Pause state
/// is stored as boolean properties on the contract. This design was intentionally chosen to ensure there are explicit
/// compiler checks for the names and states of the different actions.
contract L1MessagingStatus is AccessControlEnumerableUpgradeable, IL1StatusWrite, PauserEvents, OAppSenderUpgradeable {
    // Errors.
    error PauserRoleNotRequired(address sender);
    error PauseParamsMustBeEqual();

    /// @notice Role allowed trigger administrative tasks such as setup configurations
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    /// @notice Pauser role can pause flags in the contract.
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /// @notice Unpauser role can unpause flags in the contract.
    bytes32 public constant UNPAUSER_ROLE = keccak256("UNPAUSER_ROLE");

    /// Flag indicate token transfer is enabled or not
    bool public isTransferPaused;

    /// Flag indicate original mint / burn is enabled or not
    bool public isOriginalMintBurnPaused;

    /// @notice Configuration for contract initialization.
    struct Init {
        address admin;
        address pauser;
        address unpauser;
        address manager;
    }

    constructor(address _lzEndpoint) OAppCoreUpgradeable(_lzEndpoint) {}

    /// @notice Inititalizes the contract.
    /// @dev MUST be called during the contract upgrade to set up the proxies state.
    function initialize(Init memory init) external initializer {
        __AccessControlEnumerable_init();

        _setRoleAdmin(MANAGER_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(PAUSER_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(UNPAUSER_ROLE, DEFAULT_ADMIN_ROLE);

        _grantRole(DEFAULT_ADMIN_ROLE, init.admin);
        _grantRole(MANAGER_ROLE, init.manager);
        _grantRole(PAUSER_ROLE, init.pauser);
        _grantRole(UNPAUSER_ROLE, init.unpauser);
    }

    /// @notice Pauses or unpauses deposit.
    /// @dev If pausing, checks if the caller has the pauser role. If unpausing,
    /// checks if the caller has the unpauser role.
    function setIsTransferPaused(bool isPaused) external onlyPauserUnpauserRole(isPaused) {
        isTransferPaused = isPaused;
        emit FlagUpdated(this.setIsTransferPaused.selector, isPaused, "setIsTransferPaused");
    }

    /// @notice Pauses or unpauses deposit.
    /// @dev If pausing, checks if the caller has the pauser role. If unpausing,
    /// checks if the caller has the unpauser role.
    function setIsOriginalMintBurnPaused(bool isPaused) external onlyPauserUnpauserRole(isPaused) {
        isOriginalMintBurnPaused = isPaused;
        emit FlagUpdated(this.setIsOriginalMintBurnPaused.selector, isPaused, "setIsOriginalMintBurnPaused");
    }

    /// @notice Pauses or unpauses deposit.
    /// @dev If pausing, checks if the caller has the pauser role. If unpausing,
    /// checks if the caller has the unpauser role.
    function setIsTransferPausedFor(uint32 eid, bool isPaused, address toAddress) external payable onlyRole(MANAGER_ROLE) {
        // _setIsTransferPaused(isPaused);
        // TODO bridging send
    }

    function setExchangeRateFor(uint32 _eid, uint256 _rate, address _toAddress) external payable {
        bytes memory lzPayload = abi.encode(_toAddress, _rate, block.timestamp);

        bytes memory options = "";
        _lzSend(
            _eid,
            lzPayload,
            options,
            MessagingFee(msg.value, 0),
            payable(msg.sender)
        );
        emit BridgingConfigChanged(this.setExchangeRateFor.selector,  "setExchangeRateFor(uint32,uint256,address)", abi.encode(_eid,_rate,_toAddress));
    }

    function setEnableFor(uint32 _eid, bool _flag, address _toAddress) external payable {
        bytes memory lzPayload = abi.encode(_toAddress, _flag, block.timestamp);
        bytes memory options = "";

        _lzSend(
            _eid,
            lzPayload,
            options,
            MessagingFee(msg.value, 0),
            payable(msg.sender)
        );
        emit BridgingConfigChanged(this.setEnableFor.selector,  "setEnableFor(bool)", abi.encode(_flag));
    }

    function setCapFor(uint32 _eid, uint256 _cap, address _toAddress) external payable {
        bytes memory lzPayload = abi.encode(_toAddress, _cap, block.timestamp);
        bytes memory options = "";

        _lzSend(
            _eid,
            lzPayload,
            options,
            MessagingFee(msg.value, 0),
            payable(msg.sender)
        );
        emit BridgingConfigChanged(this.setCapFor.selector,  "setCapFor(bool)", abi.encode(_cap));
    }

    modifier onlyPauserUnpauserRole(bool isPaused) {
        if (isPaused) {
            _checkRole(PAUSER_ROLE);
        } else {
            _checkRole(UNPAUSER_ROLE);
        }
        _;
    }
}
