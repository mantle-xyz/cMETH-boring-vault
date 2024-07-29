// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {Strings} from "openzeppelin/utils/Strings.sol";
import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";
import {IAccessControl} from "openzeppelin/access/IAccessControl.sol";
import {TimelockController} from "openzeppelin/governance/TimelockController.sol";
import {ITransparentUpgradeableProxy} from "src/lib/TransparentUpgradeableProxy.sol";

import {ProtocolEvents} from "../src/interfaces/ProtocolEvents.sol";
import {L1DeploymentParams, L2DeploymentParams} from "../script/helpers/Proxy.sol";

import {console2 as console} from "forge-std/console2.sol";
import {EndpointV2} from "./mocks/MockEndpoint.sol";
import {Blocklist} from "./mocks/MockBlockList.sol";
import {SanctionsList} from "./mocks/MockSanctionList.sol";

contract BaseTest is Test, ProtocolEvents {
    address public immutable admin = makeAddr("admin");
    address public immutable owner = makeAddr("owner");
    address public immutable delegate = makeAddr("delegate");
    address public immutable upgrader = makeAddr("upgrader");
    address public immutable manager = makeAddr("manager");
    address public immutable pauser = makeAddr("pauser");
    address public immutable unpauser = makeAddr("unpauser");
    address public immutable minter = makeAddr("minter");
    address public immutable burner = makeAddr("burner");

    string public name = string("cmETH");
    string public symbol = string("cmETH");

    uint16 public immutable feeRate = 1;
    uint256 public immutable maxSupply = 1e9 * 1e18;

    address public l1endpoint;
    address public l2endpoint;

    address public blocklist;
    address public sanctionList;

    TimelockController public immutable proxyAdmin;

    constructor() {
        address[] memory operators = new address[](1);
        operators[0] = address(this);
        proxyAdmin = new TimelockController({minDelay: 0, proposers: operators, executors: operators, admin: admin});

        // `timestamps <= 1` have a special meaning in `TimelockController`, so we have to advance past those.
        vm.warp(2);
    }

    function setUp() public virtual {
        vm.startPrank(admin);
        l1endpoint = address(new EndpointV2(1, admin));
        l2endpoint = address(new EndpointV2(2, admin));

        blocklist = address(new Blocklist());
        sanctionList = address(new SanctionsList());
        vm.stopPrank();
    }

    /**
     * @notice Returns the error thrown by OZ's `AccessControl` contract if an account is missing a particular role
     */
    function missingRoleError(address account, bytes32 role) public pure returns (bytes memory) {
        return bytes(
            string.concat(
                "AccessControl: account ", Strings.toHexString(account), " is missing role ", vm.toString(role)
            )
        );
    }

    function assumeMissingRolePrankAndExpectRevert(address vandal, address target, bytes32 role) public {
        vm.assume(vandal != address(proxyAdmin));
        vm.assume(!IAccessControl(target).hasRole(role, vandal));
        vm.expectRevert(missingRoleError(vandal, role));
        vm.prank(vandal);
    }

    /**
     * @notice Fuzzing assumption that a given address is not any of the forge specific contract or in the EVM
     * precompiles range.
     */
    function assumeSafeAddress(address addr) public view {
        vm.assume(addr != CREATE2_FACTORY);
        vm.assume(addr != CONSOLE);
        vm.assume(addr != VM_ADDRESS);
        vm.assume(addr != DEFAULT_TEST_CONTRACT);
        vm.assume(addr != MULTICALL3_ADDRESS);
        vm.assume(addr != address(proxyAdmin));
        vm.assume(uint160(addr) > 9);
    }

    /**
     * @notice Fuzzing assumption that a given private key is in the correct secpk256 curve range.
     */
    function assumeSafePrivateKey(uint256 privateKey) public pure {
        vm.assume(
            privateKey > 0
                && privateKey < 115792089237316195423570985008687907852837564279074904382605163141518161494337
        );
    }

    function assumeNotContract(address addr) public view {
        vm.assume(addr.code.length == 0);
        assumeSafeAddress(addr);
    }

    function expectProtocolConfigEvent(address emitter, string memory setterSignature, bytes memory value) public {
        vm.expectEmit(emitter);
        emit ProtocolConfigChanged(bytes4(keccak256(bytes(setterSignature))), setterSignature, value);
    }

    function l1DeploymentParams() internal view returns (L1DeploymentParams memory) {
        // L1cmETH setup
        return L1DeploymentParams({
            admin: admin,
            owner: owner,
            delegate: delegate,
            upgrader: upgrader,
            manager: manager,
            l1endpoint: l1endpoint,
            minter: minter,
            burner: burner,
            maxSupply: maxSupply,
            pauser: pauser,
            unpauser: unpauser,
            name: name,
            symbol: symbol,
            blocklist: blocklist,
            sanctionList: sanctionList
        });
    }

    function l2DeploymentParams() internal view returns (L2DeploymentParams memory) {
        // L2cmETH setup
        return L2DeploymentParams({
            admin: admin,
            owner: owner,
            delegate: delegate,
            upgrader: upgrader,
            manager: manager,
            l2endpoint: l2endpoint,
            name: name,
            symbol: symbol,
            pauser: pauser,
            unpauser: unpauser
        });
    }
}

contract Utils {
    function testShowBytes32() public pure {
        console.log("storage.SanctionsList");
        console.logBytes32(
            keccak256(abi.encode(uint256(keccak256("storage.SanctionsList")) - 1)) & ~bytes32(uint256(0xff))
        );

        console.log("storage.BlockList");
        console.logBytes32(keccak256(abi.encode(uint256(keccak256("storage.BlockList")) - 1)) & ~bytes32(uint256(0xff)));
    }
}
