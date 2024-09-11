// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { OptionsBuilder } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/libs/OptionsBuilder.sol";
import { OAppCoreUpgradeable } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/OAppCoreUpgradeable.sol";
import { OAppSenderUpgradeable } from  "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/OAppSenderUpgradeable.sol";
import { OAppReceiverUpgradeable } from  "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/OAppReceiverUpgradeable.sol";
import { AccessControlEnumerableUpgradeable } from"openzeppelin-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";
import { ILayerZeroEndpointV2, MessagingFee, MessagingReceipt, Origin } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";

import {IStatusWrite, IStatusRead, ConfigEvents, PauserEvents} from "./interfaces/IMessagingStatus.sol";
import {ProtocolEvents} from "./interfaces/ProtocolEvents.sol";

/// @title Pauser
/// @notice Keeps the state of all actions that can be paused in case of exceptional circumstances. Pause state
/// is stored as boolean properties on the contract. This design was intentionally chosen to ensure there are explicit
/// compiler checks for the names and states of the different actions.
contract L2MessagingStatus is AccessControlEnumerableUpgradeable, IStatusWrite, ConfigEvents, PauserEvents, ProtocolEvents, OAppSenderUpgradeable, OAppReceiverUpgradeable {
    using OptionsBuilder for bytes;

    // Errors.
    error PauserRoleNotRequired(address sender);
    error UnexpectedInitializeParams();
    error PauseParamsMustBeEqual();
    error UpdateTimeError();
    error LZReceiveError();

    /// @notice Role allowed trigger administrative tasks such as setup configurations
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    /// @notice Pauser role can pause flags in the contract.
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /// @notice Unpauser role can unpause flags in the contract.
    bytes32 public constant UNPAUSER_ROLE = keccak256("UNPAUSER_ROLE");

    /// Flag indicate token transfer is enabled or not
    bool public isTransferPaused;

    // mETH / ETH exchange rate referrals;
    uint256 public exchangeRate;

    // bridging enabled
    uint256 public capacity;

    // bridging enabled
    bool public enabled;

    // record update ts
    uint256 internal lastUpdate;

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

        // grant self to bridging setup
        _grantRole(MANAGER_ROLE, address(this));
        _grantRole(PAUSER_ROLE, address(this));
    }

    /**
     * @notice Retrieves the OApp version information.
     * @return senderVersion The version of the OAppSender.sol implementation.
     * @return receiverVersion The version of the OAppReceiver.sol implementation.
     */
    function oAppVersion() public pure override(OAppSenderUpgradeable, OAppReceiverUpgradeable) returns (uint64 senderVersion, uint64 receiverVersion)
    {
        return (SENDER_VERSION, RECEIVER_VERSION);
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

    /// @notice Pauses or unpauses deposit.
    /// @dev If pausing, checks if the caller has the pauser role. If unpausing,
    /// checks if the caller has the unpauser role.
    function setIsTransferPaused(bool isPaused) public onlyPauserUnpauserRole(isPaused) {
        isTransferPaused = isPaused;
        emit FlagUpdated(this.setIsTransferPaused.selector, isPaused, "setIsTransferPaused");
    }

    /// @notice Pauses or unpauses deposit.
    /// @dev If pausing, checks if the caller has the pauser role. If unpausing,
    /// checks if the caller has the unpauser role.
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

    /// @notice Update set exchange rate.
    function setExchangeRate(uint256 rate) public onlyRole(MANAGER_ROLE) {
        exchangeRate = rate;
        emit ProtocolConfigChanged(this.setExchangeRate.selector, "setExchangeRate(uint256)", abi.encode(rate));
    }

    function setExchangeRateFor(uint32 eid, uint256 rate) external payable onlyRole(MANAGER_ROLE) {
        bytes memory lzPayload = abi.encode(block.timestamp, bytes4(keccak256("setExchangeRate(uint256)")), rate);
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

    /// @notice Update set chain enable.
    function setEnable(bool flag) public onlyRole(MANAGER_ROLE) {
        enabled = flag;
        emit ProtocolConfigChanged(this.setEnable.selector, "setEnable(bool)", abi.encode(flag));
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

    /// @notice Update set chain enable.
    function setCap(uint256 cap) public onlyRole(MANAGER_ROLE) {
        capacity = cap;
        emit ProtocolConfigChanged(this.setCap.selector, "setCap(uint256)", abi.encode(cap));
    }

    function setCapFor(uint32 eid, uint256 cap) external payable onlyRole(MANAGER_ROLE) {
        bytes memory lzPayload = abi.encode(block.timestamp, bytes4(keccak256("setCap(uint256)")), cap);
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

    /**
     * @dev Internal function to handle the receive on the LayerZero endpoint.
     * @param _origin The origin information.
     *  - srcEid: The source chain endpoint ID.
     *  - sender: The sender address from the src chain.
     *  - nonce: The nonce of the LayerZero message.
     * @param _guid The unique identifier for the received LayerZero message.
     * @param _message The encoded message.
     * @dev _executor The address of the executor.
     * @dev _extraData Additional data.
     */
    function _lzReceive(
        Origin calldata _origin,
        bytes32 _guid,
        bytes calldata _message,
        address _executor, // @dev unused in the default implementation.
        bytes calldata _extraData // @dev unused in the default implementation.
    ) internal override {
        uint256 ts = uint256(bytes32(_message[0:32]));
        // check configuration update ts, ignore handle the old massages
        if (ts <= lastUpdate) {
            revert UpdateTimeError();
        }
        lastUpdate = ts;

        // You can send ether and specify a custom gas amount
        (bool success,) = address(this).call{value: 0}(_message[32:]);
        if (!success) {
            revert LZReceiveError();
        }
    }
}
