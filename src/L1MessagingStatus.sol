// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { OptionsBuilder } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/libs/OptionsBuilder.sol";
import { OAppCoreUpgradeable } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/OAppCoreUpgradeable.sol";
import { OAppSenderUpgradeable } from  "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/OAppSenderUpgradeable.sol";
import {AccessControlEnumerableUpgradeable} from"openzeppelin-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";
import { ILayerZeroEndpointV2, MessagingFee, MessagingReceipt, Origin } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";

import {IL1StatusWrite, IStatusRead, ConfigEvents, PauserEvents} from "./interfaces/IMessagingStatus.sol";

/// @title Pauser
/// @notice Keeps the state of all actions that can be paused in case of exceptional circumstances. Pause state
/// is stored as boolean properties on the contract. This design was intentionally chosen to ensure there are explicit
/// compiler checks for the names and states of the different actions.
contract L1MessagingStatus is AccessControlEnumerableUpgradeable, IL1StatusWrite, ConfigEvents, PauserEvents, OAppSenderUpgradeable {
    using OptionsBuilder for bytes;

    // Errors.
    error PauserRoleNotRequired(address sender);
    error UnexpectedInitializeParams();
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

    modifier onlyPauserUnpauserRole(bool isPaused) {
        if (isPaused) {
            _checkRole(PAUSER_ROLE);
        } else {
            _checkRole(UNPAUSER_ROLE);
        }
        _;
    }

    /// @notice Configuration for contract initialization.
    struct Init {
        address admin;
        address owner;
        address pauser;
        address unpauser;
        address manager;
    }

    constructor(address _lzEndpoint) OAppCoreUpgradeable(_lzEndpoint) {}

    /// @notice Inititalizes the contract.
    /// @dev MUST be called during the contract upgrade to set up the proxies state.
    function initialize(Init memory init) external initializer {
        if (
            init.admin == address(0) ||
            init.owner == address(0) ||
            init.pauser == address(0) ||
            init.unpauser == address(0) ||
            init.manager == address(0)
        ) {
            revert UnexpectedInitializeParams();
        }
        __AccessControlEnumerable_init();
        __Ownable_init(init.owner);

        _setRoleAdmin(MANAGER_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(PAUSER_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(UNPAUSER_ROLE, DEFAULT_ADMIN_ROLE);

        _grantRole(DEFAULT_ADMIN_ROLE, init.admin);
        _grantRole(MANAGER_ROLE, init.manager);
        _grantRole(PAUSER_ROLE, init.pauser);
        _grantRole(UNPAUSER_ROLE, init.unpauser);
    }

    /// @notice Quote entrance for set configurations for
    function quote(
        uint32 eid,
        bytes memory message,
        bytes calldata options
    ) public view returns (uint256 nativeFee, uint256 lzTokenFee) {
        MessagingFee memory fee = _quote(eid, message, options, false);
        return (fee.nativeFee, fee.lzTokenFee);
    }

    /// @notice Pauses or unpauses original mint / burn.
    /// @dev If pausing, checks if the caller has the pauser role. If unpausing,
    /// checks if the caller has the unpauser role.
    /// entrance only on L1
    function setIsOriginalMintBurnPaused(bool isPaused) external onlyPauserUnpauserRole(isPaused) {
        isOriginalMintBurnPaused = isPaused;
        emit FlagUpdated(this.setIsOriginalMintBurnPaused.selector, isPaused, "setIsOriginalMintBurnPaused");
    }

    /// @notice Pauses or unpauses token transfer.
    /// @dev If pausing, checks if the caller has the pauser role. If unpausing,
    /// checks if the caller has the unpauser role.
    function setIsTransferPaused(bool isPaused) external onlyPauserUnpauserRole(isPaused) {
        isTransferPaused = isPaused;
        emit FlagUpdated(this.setIsTransferPaused.selector, isPaused, "setIsTransferPaused");
    }

    /// @notice Set pauses or unpauses transfer to target chain.
    function setIsTransferPausedFor(uint32 eid, bool isPaused) external payable onlyRole(MANAGER_ROLE) {
        bytes memory lzPayload = abi.encodePacked(block.timestamp, bytes4(keccak256("setIsTransferPaused(bool)")), abi.encode(isPaused));
        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        _lzSend(
            eid,
            lzPayload,
            options,
            MessagingFee(msg.value, 0),
            payable(msg.sender)
        );
        emit BridgingConfigChanged(this.setIsTransferPausedFor.selector,  "setIsTransferPausedFor(uint32,bool)", abi.encode(eid,isPaused));
    }

    function setExchangeRateFor(uint32 eid, uint256 rate) external payable onlyRole(MANAGER_ROLE) {
        bytes memory lzPayload = abi.encodePacked(block.timestamp, bytes4(keccak256("setExchangeRate(uint256)")), rate);
        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        _lzSend(
            eid,
            lzPayload,
            options,
            MessagingFee(msg.value, 0),
            payable(msg.sender)
        );
        emit BridgingConfigChanged(this.setExchangeRateFor.selector,  "setExchangeRateFor(uint32,uint256)", abi.encode(eid,rate));
    }

    function setEnableFor(uint32 eid, bool flag) external payable onlyRole(MANAGER_ROLE) {
        bytes memory lzPayload = abi.encodePacked(block.timestamp, bytes4(keccak256("setEnable(bool)")), abi.encode(flag));
        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        _lzSend(
            eid,
            lzPayload,
            options,
            MessagingFee(msg.value, 0),
            payable(msg.sender)
        );
        emit BridgingConfigChanged(this.setEnableFor.selector,  "setEnableFor(uint32,bool)", abi.encode(eid,flag));
    }

    function setCapFor(uint32 eid, uint256 cap) external payable onlyRole(MANAGER_ROLE) {
        bytes memory lzPayload = abi.encodePacked(block.timestamp, bytes4(keccak256("setCap(uint256)")), cap);
        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        _lzSend(
            eid,
            lzPayload,
            options,
            MessagingFee(msg.value, 0),
            payable(msg.sender)
        );
        emit BridgingConfigChanged(this.setCapFor.selector,  "setCapFor(uint32,uint256)", abi.encode(eid,cap));
    }
}
