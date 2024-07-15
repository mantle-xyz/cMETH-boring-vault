// SPDX-License-Identifier: MIT LICENSE
pragma solidity ^0.8.18;

import "lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";

import {BaseTest} from "./BaseTest.sol";
import {L2MessagingStatus} from "../src/L2MessagingStatus.sol";
import {L2DeploymentParams, L2Deployments} from "../script/helpers/Proxy.sol";
import {testDeployL2, newL2cmETH, newL2MessagingStatus} from "./utils/Deploy.sol";
import {IStatusWrite, IStatusRead, ConfigEvents, PauserEvents} from "../src/interfaces/IMessagingStatus.sol";

import {console2 as console} from "forge-std/console2.sol";

contract L2MessagingStatusTest is BaseTest {
    L2Deployments public dps;
    L2MessagingStatus public l2Status;

    function setUp() virtual public override {
        super.setUp();
        vm.startPrank(admin);
        dps = testDeployL2(l2DeploymentParams(), admin);
        vm.stopPrank();
        l2Status = dps.l2MessagingStatus;
    }
}

contract L2MessagingStatusInitialisationTest is L2MessagingStatusTest {
    function testL2MessagingStatusInitialize() view public {
        assertEq(l2Status.owner(), owner, "l2Status owner not initialized properly");
        assertEq(l2Status.getRoleAdmin(l2Status.MANAGER_ROLE()),
            l2Status.DEFAULT_ADMIN_ROLE(), "l2Status admin not initialized properly");
        assertEq(l2Status.getRoleAdmin(l2Status.PAUSER_ROLE()),
            l2Status.DEFAULT_ADMIN_ROLE(), "l2Status admin not initialized properly");
        assertEq(l2Status.getRoleAdmin(l2Status.UNPAUSER_ROLE()),
            l2Status.DEFAULT_ADMIN_ROLE(), "l2Status admin not initialized properly");
        require(l2Status.hasRole(l2Status.DEFAULT_ADMIN_ROLE(), admin),
            "l2Status DEFAULT_ADMIN_ROLE role not initialized properly");
        require(l2Status.hasRole(l2Status.MANAGER_ROLE(), manager),
            "l2Status MANAGER_ROLE role not initialized properly");
        require(l2Status.hasRole(l2Status.PAUSER_ROLE(), pauser),
            "l2Status PAUSER_ROLE role not initialized properly");
        require(l2Status.hasRole(l2Status.UNPAUSER_ROLE(), unpauser),
            "l2Status UNPAUSER_ROLE role not initialized properly");
    }
}

contract L2MessagingStatusVandalTest is L2MessagingStatusTest {
    address public vandal = makeAddr("vandal");
    uint256 public immutable amount = 100 * 1e18;
    uint256 public immutable rate = 1e18 + 1e16;
    uint32 public immutable eid = 1;

    function testL2SetIsTransferPausedFailed() public {
        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, l2Status.PAUSER_ROLE()));
        vm.prank(vandal);
        l2Status.setIsTransferPaused(true);

        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, l2Status.UNPAUSER_ROLE()));
        vm.prank(vandal);
        l2Status.setIsTransferPaused(false);
    }

    function testL2SetIsTransferPausedForFailed() public {
        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, l2Status.MANAGER_ROLE()));
        vm.prank(vandal);
        l2Status.setIsTransferPausedFor(eid, true);
    }

    function testL2SetExchangeRateFailed() public {
        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, l2Status.MANAGER_ROLE()));
        vm.prank(vandal);
        l2Status.setExchangeRate(rate);
    }

    function testL2SetExchangeRateForFailed() public {
        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, l2Status.MANAGER_ROLE()));
        vm.prank(vandal);
        l2Status.setExchangeRateFor(eid, amount);
    }

    function testL2SetEnableFailed() public {
        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, l2Status.MANAGER_ROLE()));
        vm.prank(vandal);
        l2Status.setEnable(true);
    }

    function testL2SetEnableForFailed() public {
        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, l2Status.MANAGER_ROLE()));
        vm.prank(vandal);
        l2Status.setEnableFor(eid, true);
    }

    function testL2SetCapFailed() public {
        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, l2Status.MANAGER_ROLE()));
        vm.prank(vandal);
        l2Status.setCap(amount);
    }

    function testL2SetCapForFailed() public {
        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, l2Status.MANAGER_ROLE()));
        vm.prank(vandal);
        l2Status.setCapFor(eid, amount);
    }
}

contract L2MessagingStatusFunctionalStakeTest is ConfigEvents, PauserEvents, L2MessagingStatusTest {
    address public immutable sender = makeAddr("sender");
    uint256 public immutable amount = 100 * 1e18;
    uint256 public immutable rate = 1e18 + 1e16;
    uint32 public immutable eid = 1;
    address public immutable peer = makeAddr("peer");

    function setUp() public override {
        super.setUp();
        vm.startPrank(owner);
        l2Status.setPeer(eid, bytes32(uint256(uint160(peer))));
        vm.stopPrank();
    }

    function testL2SetIsTransferPausedSuccess() public {
        assertFalse(l2Status.isTransferPaused());

        vm.expectEmit();
        emit FlagUpdated(l2Status.setIsTransferPaused.selector, true, "setIsTransferPaused");

        vm.prank(pauser);
        l2Status.setIsTransferPaused(true);

        assertTrue(l2Status.isTransferPaused());

        vm.prank(unpauser);
        l2Status.setIsTransferPaused(false);
    }

    function testL2SetIsTransferPausedForSuccess() public {
        vm.expectEmit();
        emit BridgingConfigChanged(l2Status.setIsTransferPausedFor.selector, "setIsTransferPausedFor(uint32,bool)", abi.encode(eid,true));

        vm.prank(manager);
        l2Status.setIsTransferPausedFor(eid, true);
    }

    function testL2SetExchangeRateSuccess() public {
        vm.expectEmit();
        emit ProtocolConfigChanged(l2Status.setExchangeRate.selector, "setExchangeRate(uint256)", abi.encode(rate));

        vm.prank(manager);
        l2Status.setExchangeRate(rate);
    }

    function testL2SetExchangeRateForSuccess() public {
        vm.expectEmit();
        emit BridgingConfigChanged(l2Status.setExchangeRateFor.selector, "setExchangeRateFor(uint32,uint256)", abi.encode(eid,rate));

        vm.prank(manager);
        l2Status.setExchangeRateFor(eid, rate);
    }

    function testL2SetEnableSuccess() public {
        vm.expectEmit();
        emit ProtocolConfigChanged(l2Status.setEnable.selector, "setEnable(bool)", abi.encode(true));

        vm.prank(manager);
        l2Status.setEnable(true);
    }

    function testL2SetEnableForSuccess() public {
        vm.expectEmit();
        emit BridgingConfigChanged(l2Status.setEnableFor.selector, "setEnableFor(uint32,bool)", abi.encode(eid,true));

        vm.prank(manager);
        l2Status.setEnableFor(eid, true);
    }

    function testL2SetCapSuccess() public {
        vm.expectEmit();
        emit ProtocolConfigChanged(l2Status.setCap.selector, "setCap(uint256)", abi.encode(amount));

        vm.prank(manager);
        l2Status.setCap(amount);
    }

    function testL2SetCapForSuccess() public {
        vm.expectEmit();
        emit BridgingConfigChanged(l2Status.setCapFor.selector, "setCapFor(uint32,uint256)", abi.encode(eid,amount));

        vm.prank(manager);
        l2Status.setCapFor(eid, amount);
    }
}
