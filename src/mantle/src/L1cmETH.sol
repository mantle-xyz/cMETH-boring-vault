// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import {AccessControlEnumerableUpgradeable} from "openzeppelin-upgradeable/access/extensions/AccessControlEnumerableUpgradeable.sol";
import {ERC20Upgradeable} from "openzeppelin-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {OFTAdapterUpgradeable} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/OFTAdapterUpgradeable.sol";

import "./interfaces/ProtocolEvents.sol";
import "./interfaces/IL1cmETH.sol";
import {IStatusRead} from "./interfaces/IMessagingStatus.sol";
import "./interfaces/IMETH.sol";
import {SanctionsListClientUpgradeable} from "./ClientSanctionsListUpgradeable.sol";
import {BlockListClientUpgradeable} from "./ClientBlockListUpgradable.sol";
import {console2 as console} from "forge-std/console2.sol";

contract L1cmETH is
    IL1cmETH,
    ProtocolEvents,
    ERC20Upgradeable,
    AccessControlEnumerableUpgradeable,
    BlockListClientUpgradeable,
    SanctionsListClientUpgradeable
{
    // errors
    error Paused();
    error ChainNotExpected();
    error MaxSupplyOutOfBound();
    error UnexpectedInitializeParams();

    /// @notice Role allowed trigger administrative tasks such as setup configurations
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    /// @notice Role to request mint / burn.
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    /// @notice The maximum amount of cmETH that can be minted during the original mint process.
    /// @dev This is used as an additional safeguard to create a maximum supply amount in the protocol. As the protocol
    /// scales up this value will be increased to allow for more deposit.
    uint256 public maxTotalSupply;

    // messaging status setup
    address public status;

    struct Init {
        address admin;
        address manager;
        address minter;
        address burner;
        address status;
        string name;
        string symbol;
        uint256 maxSupply;
        address blocklist;
        address sanctionList;
    }

    // @dev _token is the proxy address of L1cmETH
    constructor() {
        _disableInitializers();
    }

    /**
     * @dev Initializes the OFT with the provided name, symbol, and delegate.
     * @dev The delegate typically should be set as the admin of the contract.
     * @dev Ownable is not initialized here on purpose. It should be initialized in the child contract to
     * accommodate the different version of Ownable.
     */
    function initialize(Init memory init) external initializer {
        if (init.admin == address(0) || init.manager == address(0) || init.minter == address(0) || init.burner == address(0) || init.status == address(0)) {
            revert UnexpectedInitializeParams();
        }
        __ERC20_init(init.name, init.symbol);

        // set admin roles
        _setRoleAdmin(MANAGER_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(MINTER_ROLE, DEFAULT_ADMIN_ROLE);
        _setRoleAdmin(BURNER_ROLE, DEFAULT_ADMIN_ROLE);

        // grant admin roles
        _grantRole(DEFAULT_ADMIN_ROLE, init.admin);

        // grant sub roles
        _grantRole(MANAGER_ROLE, init.manager);
        _grantRole(MINTER_ROLE, init.minter);
        _grantRole(BURNER_ROLE, init.burner);

        status = init.status;
        maxTotalSupply = init.maxSupply;

        _setBlocklist(init.blocklist);
        _setSanctionsList(init.sanctionList);
    }

    // @notice Original mint when deposit mETH.
    function mint(address _to, uint256 _amount) external onlyRole(MINTER_ROLE) {
        if (IStatusRead(status).isOriginalMintBurnPaused()) {
            revert Paused();
        }
        if (maxTotalSupply != 0 && totalSupply() + _amount > maxTotalSupply) {
            revert MaxSupplyOutOfBound();
        }
        _mint(_to, _amount);
    }

    // @notice Original burn when withdraw mETH.
    function burn(address _from, uint256 _amount) external onlyRole(BURNER_ROLE) {
        if (IStatusRead(status).isOriginalMintBurnPaused()) {
            revert Paused();
        }
        _burn(_from, _amount);
    }

    /// @notice Sets the maxTotalSupply variable.
    /// Note: We intentionally allow this to be set lower than the current totalSupply so that the amount can be
    /// adjusted downwards by withdraw.
    /// See also {maxTotalSupply}.
    function setMaxTotalSupply(uint256 newMaxTotalSupply) external payable onlyRole(MANAGER_ROLE) {
        maxTotalSupply = newMaxTotalSupply;
        emit ProtocolConfigChanged(
            this.setMaxTotalSupply.selector, "setMaxTotalSupply(uint256)", abi.encode(newMaxTotalSupply)
        );
    }

    function setBlocklist(address _blocklist) external override onlyRole(MANAGER_ROLE) {
        _setBlocklist(_blocklist);
    }

    function setSanctionsList(address _sanctionsList) external override onlyRole(MANAGER_ROLE) {
        _setSanctionsList(_sanctionsList);
    }

    function _update(address from, address to, uint256 value) internal override {
        if (IStatusRead(status).isTransferPaused()) {
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
}
