// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {OFTUpgradeable} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/OFTUpgradeable.sol";
import {AccessControlEnumerableUpgradeable} from "openzeppelin-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";
import { ILayerZeroEndpointV2, MessagingFee, MessagingReceipt, Origin } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";

import {SanctionsListClientUpgradeable} from "./ClientSanctionsListUpgradeable.sol";
import {BlockListClientUpgradeable} from "./ClientBlockListUpgradable.sol";
import {IL2StatusRead} from "./interfaces/IMessagingStatus.sol";
import {ProtocolEvents} from "./interfaces/ProtocolEvents.sol";

contract L2cmETH is
    ProtocolEvents,
    OFTUpgradeable,
    AccessControlEnumerableUpgradeable,
    BlockListClientUpgradeable,
    SanctionsListClientUpgradeable
{
    // errors
    error Paused();
    error NotEnabled();
    error MaxSupplyOutOfBound();
    error UnexpectedInitializeParams();

    /// @notice Role allowed trigger administrative tasks such as setup configurations
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    // messaging status setup
    address public status;

    struct Init {
        address admin;
        address owner;
        address delegate;
        address manager;
        address status;
        string name;
        string symbol;
    }

    constructor(address _lzEndpoint) OFTUpgradeable(_lzEndpoint) {}

    /**
     * @dev Initializes the OFT with the provided name, symbol, and delegate.
     * @dev The delegate typically should be set as the admin of the contract.
     * @dev Ownable is not initialized here on purpose. It should be initialized in the child contract to
     * accommodate the different version of Ownable.
     */
    function initialize(Init memory init) external initializer {
        if (
            init.admin == address(0) ||
            init.owner == address(0) ||
            init.delegate == address(0) ||
            init.manager == address(0) ||
            init.status == address(0)
        ) {
            revert UnexpectedInitializeParams();
        }

        __OFT_init(init.name, init.symbol, init.delegate);
        __Ownable_init(init.owner);

        // set admin roles
        _setRoleAdmin(MANAGER_ROLE, DEFAULT_ADMIN_ROLE);

        // grant admin roles
        _grantRole(DEFAULT_ADMIN_ROLE, init.admin);
        _grantRole(MANAGER_ROLE, init.manager);

        status = init.status;
    }

    function setBlocklist(address _blocklist) external override onlyRole(MANAGER_ROLE) {
        _setBlocklist(_blocklist);
    }

    function setSanctionsList(address _sanctionsList) external override onlyRole(MANAGER_ROLE) {
        _setSanctionsList(_sanctionsList);
    }

    /// @dev override transfer update to check blocklist and sanction list
    /// @dev ignore check if it is not set
    function _update(address from, address to, uint256 value) internal override {
        if (IL2StatusRead(status).isTransferPaused()) {
            revert Paused();
        }
        // Check constraints when `transferFrom` is called to facliitate
        // a transfer between two parties that are not `from` or `to`.
        if (from != msg.sender && to != msg.sender) {
            require(!_isBlocked(msg.sender), "cmETH: 'sender' address blocked");
            require(!_isSanctioned(msg.sender), "cmETH: 'sender' address sanctioned");
        }

        if (from != address(0)) {
            // If not minting
            require(!_isBlocked(from), "cmETH: 'from' address blocked");
            require(!_isSanctioned(from), "cmETH: 'from' address sanctioned");
        }

        if (to != address(0)) {
            // If not burning
            require(!_isBlocked(to), "cmETH: 'to' address blocked");
            require(!_isSanctioned(to), "cmETH: 'to' address sanctioned");
        }
        super._update(from, to, value);
    }

    /**
     * @dev Credits tokens to the specified address.
     * @param _to The address to credit the tokens to.
     * @param _amountLD The amount of tokens to credit in local decimals.
     * @dev _srcEid The source chain ID.
     * @return amountReceivedLD The amount of tokens ACTUALLY received in local decimals.
     */
    function _credit(
        address _to,
        uint256 _amountLD,
        uint32 _srcEid
    ) internal override returns (uint256) {
        /// @dev override to check capacity(ignore check if it is not set)
        if (IL2StatusRead(status).capacity() != 0 && totalSupply() + _amountLD > IL2StatusRead(status).capacity()) {
            revert MaxSupplyOutOfBound();
        }
        return super._credit(_to, _amountLD, _srcEid);
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
        /// @dev override to check enable status
        if (!IL2StatusRead(status).enabled()) {
            revert NotEnabled();
        }
        super._lzReceive(_origin, _guid, _message, _executor, _extraData);
    }
}
