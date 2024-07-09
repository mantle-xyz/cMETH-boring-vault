// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC20Upgradeable} from "openzeppelin-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {OFTAdapterUpgradeable} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/OFTAdapterUpgradeable.sol";
import {AccessControlEnumerableUpgradeable} from
    "openzeppelin-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";

import {SanctionsListClientUpgradeable} from "./ClientSanctionsListUpgradeable.sol";
import {BlockListClientUpgradeable} from "./ClientBlockListUpgradable.sol";
import {IStatusRead} from "./interfaces/IMessagingStatus.sol";
import {ProtocolEvents} from "./interfaces/ProtocolEvents.sol";
import {IL1cmETH} from "./interfaces/IL1cmETH.sol";
import {IMETH} from "./interfaces/IMETH.sol";

contract L1cmETHAdapter is ProtocolEvents, OFTAdapterUpgradeable, AccessControlEnumerableUpgradeable {
    // errors
    error Paused();
    error ChainNotExpected();
    error MaxSupplyOutOfBound();
    error UnexpectedInitializeParams();

    /// @notice Role allowed trigger administrative tasks such as setup configurations
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    /// @dev A basis point (often denoted as bp, 1bp = 0.01%) is a unit of measure used in finance to describe
    /// the percentage change in a financial instrument. This is a constant value set as 10000 which represents
    /// 100% in basis point terms.
    uint16 internal constant _BASIS_POINTS_DENOMINATOR = 10_000;

    /// As the adjustment to the bridging rate, the result is reflected in any user interface which shows the
    /// amount of cmETH received when bridging-transfer.
    /// @dev The value is in basis points (1/10000).
    uint16 public feeRate;

    // messaging status setup
    address public status;

    struct Init {
        address admin;
        address manager;
        address status;
        uint16 feeRate;
    }

    // @dev _token is the proxy address of L1cmETH
    constructor(address _token, address _lzEndpoint) OFTAdapterUpgradeable(_token, _lzEndpoint) {}

    /**
     * @dev Initializes the OFTAdapter.
     * @dev The delegate typically should be set as the admin of the contract.
     * @dev Ownable is not initialized here on purpose. It should be initialized in the child contract to
     * accommodate the different version of Ownable.
     */
    function initialize(Init memory init) external initializer {
        if (init.admin == address(0) || init.manager == address(0) || init.status == address(0)) {
            revert UnexpectedInitializeParams();
        }
        __OFTAdapter_init(init.admin);
        __Ownable_init(_msgSender());
        _transferOwnership(init.admin);
        // set admin roles
        _setRoleAdmin(MANAGER_ROLE, DEFAULT_ADMIN_ROLE);

        // grant admin roles
        _grantRole(DEFAULT_ADMIN_ROLE, init.admin);

        // grant sub roles
        _grantRole(MANAGER_ROLE, init.manager);

        status = init.status;
        feeRate = init.feeRate;
    }

    function sharedDecimals() public pure override returns (uint8) {
        return 18;
    }

    /// @notice Sets the bridging fee rate.
    function setFeeRate(uint16 newFeeRate) external onlyRole(MANAGER_ROLE) {
        // even though this check is redundant with the one above, this function will be rarely used so we keep it as a
        // reminder for future upgrades that this must never be violated.
        assert(newFeeRate <= _BASIS_POINTS_DENOMINATOR);

        feeRate = newFeeRate;
        emit ProtocolConfigChanged(this.setFeeRate.selector, "setFeeRate(uint16)", abi.encode(newFeeRate));
    }
}
