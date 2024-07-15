// SPDX-License-Identifier: MIT LICENSE
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {IAccessControl} from "lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/access/IAccessControl.sol";

import {L1MessagingStatus} from "../src/L1MessagingStatus.sol";
import {testDeployL1, newL1MessagingStatus} from "./utils/Deploy.sol";
import {L1Deployments, L2Deployments} from "../script/helpers/Proxy.sol";
import {IStatusWrite, IStatusRead, ConfigEvents, PauserEvents} from "../src/interfaces/IMessagingStatus.sol";
import {BaseTest} from "./BaseTest.sol";

contract L1MessagingStatusTest is BaseTest {
    L1Deployments public dps;
    L1MessagingStatus public l1Status;

    function setUp() virtual public override {
        super.setUp();
        vm.startPrank(admin);
        dps = testDeployL1(l1DeploymentParams(), admin);
        vm.stopPrank();
        l1Status = dps.l1MessagingStatus;
    }
}

contract L1MessagingStatusInitializeTest is L1MessagingStatusTest {
    function testL1MessagingStatusInitialize() public {
        assertEq(l1Status.owner(), owner, "l1Status owner not initialized properly");
        assertEq(l1Status.getRoleAdmin(l1Status.MANAGER_ROLE()),
            l1Status.DEFAULT_ADMIN_ROLE(), "l1Status admin not initialized properly");
        assertEq(l1Status.getRoleAdmin(l1Status.PAUSER_ROLE()),
            l1Status.DEFAULT_ADMIN_ROLE(), "l1Status admin not initialized properly");
        assertEq(l1Status.getRoleAdmin(l1Status.UNPAUSER_ROLE()),
            l1Status.DEFAULT_ADMIN_ROLE(), "l1Status admin not initialized properly");
        require(l1Status.hasRole(l1Status.DEFAULT_ADMIN_ROLE(), admin),
            "l1Status DEFAULT_ADMIN_ROLE role not initialized properly");
        require(l1Status.hasRole(l1Status.MANAGER_ROLE(), manager),
            "l1Status MANAGER_ROLE role not initialized properly");
        require(l1Status.hasRole(l1Status.PAUSER_ROLE(), pauser),
            "l1Status PAUSER_ROLE role not initialized properly");
        require(l1Status.hasRole(l1Status.UNPAUSER_ROLE(), unpauser),
            "l1Status UNPAUSER_ROLE role not initialized properly");
    }
}

contract L1MessagingStatusVandalTest is L1MessagingStatusTest {
    address public immutable vandal = makeAddr("vandal");
    uint256 public immutable amount = 100 * 1e18;
    uint32 public immutable eid = 1;

    function testSetIsOriginalMintBurnPausedFailed() public {
        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, l1Status.PAUSER_ROLE()));
        vm.prank(vandal);
        l1Status.setIsOriginalMintBurnPaused(true);

        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, l1Status.UNPAUSER_ROLE()));
        vm.prank(vandal);
        l1Status.setIsOriginalMintBurnPaused(false);
    }

    function testSetIsTransferPausedFailed() public {
        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, l1Status.PAUSER_ROLE()));
        vm.prank(vandal);
        l1Status.setIsTransferPaused(true);

        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, l1Status.UNPAUSER_ROLE()));
        vm.prank(vandal);
        l1Status.setIsTransferPaused(false);
    }

    function testSetIsTransferPausedForFailed() public {
        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, l1Status.MANAGER_ROLE()));
        vm.prank(vandal);
        l1Status.setIsTransferPausedFor(eid, true);
    }

    function testSetExchangeRateForFailed() public {
        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, l1Status.MANAGER_ROLE()));
        vm.prank(vandal);
        l1Status.setExchangeRateFor(eid, amount);
    }

    function testSetEnableForFailed() public {
        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, l1Status.MANAGER_ROLE()));
        vm.prank(vandal);
        l1Status.setEnableFor(eid, true);
    }

    function testSetCapForFailed() public {
        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, l1Status.MANAGER_ROLE()));
        vm.prank(vandal);
        l1Status.setCapFor(eid, amount);
    }
}

contract L1MessagingStatusFunctionalTest is ConfigEvents, PauserEvents, L1MessagingStatusTest {
    address public immutable sender = makeAddr("sender");
    uint256 public immutable amount = 100 * 1e18;
    uint256 public immutable rate = 1e18 + 1e16;
    uint32 public immutable eid = 1;
    address public immutable peer = makeAddr("peer");

    function setUp() public override {
        super.setUp();
        vm.startPrank(owner);
        l1Status.setPeer(eid, bytes32(uint256(uint160(peer))));
        vm.stopPrank();
    }

    function testSetIsOriginalMintBurnPausedSuccess() public {
        assertFalse(l1Status.isOriginalMintBurnPaused());

        vm.expectEmit();
        emit FlagUpdated(l1Status.setIsOriginalMintBurnPaused.selector, true, "setIsOriginalMintBurnPaused");

        vm.prank(pauser);
        l1Status.setIsOriginalMintBurnPaused(true);

        assertTrue(l1Status.isOriginalMintBurnPaused());

        vm.prank(unpauser);
        l1Status.setIsOriginalMintBurnPaused(false);
    }

    function testSetIsTransferPausedSuccess() public {
        assertFalse(l1Status.isTransferPaused());

        vm.expectEmit();
        emit FlagUpdated(l1Status.setIsTransferPaused.selector, true, "setIsTransferPaused");

        vm.prank(pauser);
        l1Status.setIsTransferPaused(true);

        assertTrue(l1Status.isTransferPaused());

        vm.prank(unpauser);
        l1Status.setIsTransferPaused(false);
    }

    function testSetIsTransferPausedForSuccess() public {
        vm.expectEmit();
        emit BridgingConfigChanged(l1Status.setIsTransferPausedFor.selector, "setIsTransferPausedFor(uint32,bool)", abi.encode(eid,true));

        vm.prank(manager);
        l1Status.setIsTransferPausedFor(eid, true);
    }

    function testSetExchangeRateForSuccess() public {
        vm.expectEmit();
        emit BridgingConfigChanged(l1Status.setExchangeRateFor.selector, "setExchangeRateFor(uint32,uint256)", abi.encode(eid,rate));

        vm.prank(manager);
        l1Status.setExchangeRateFor(eid, rate);
    }

    function testSetEnableForSuccess() public {
        vm.expectEmit();
        emit BridgingConfigChanged(l1Status.setEnableFor.selector, "setEnableFor(uint32,bool)", abi.encode(eid,true));

        vm.prank(manager);
        l1Status.setEnableFor(eid, true);
    }

    function testSetCapForSuccess() public {
        vm.expectEmit();
        emit BridgingConfigChanged(l1Status.setCapFor.selector, "setCapFor(uint32,uint256)", abi.encode(eid,amount));

        vm.prank(manager);
        l1Status.setCapFor(eid, amount);
    }
}
