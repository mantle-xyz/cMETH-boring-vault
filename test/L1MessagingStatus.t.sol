// SPDX-License-Identifier: MIT LICENSE
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {IAccessControl} from "lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/access/IAccessControl.sol";

import {testDeployL1, newL1MessagingStatus} from "./utils/Deploy.sol";
import {L1Deployments, L2Deployments} from "../script/helpers/Proxy.sol";
import {BaseTest} from "./BaseTest.sol";

//contract L1cmETHTest is BaseTest {
//    L1Deployments public dps;
//
//    function setUp() public override {
////        vm.startPrank(admin);
////        dps = testDeployAll(deploymentParams(), admin);
////        vm.stopPrank();
////        allocateRegisterMNT = dps.allocateRegisterMNT;
////        allocateRegisterMETH = dps.allocateRegisterMETH;
////
////        tranche = newStandardTranche(address(allocateRegisterMNT), 100e18);
////        yieldFarm = YieldFarm(newStandardYieldFarm(address(allocateRegisterMNT), address(dps.distributeYield), 100e18, 100, 200, 100e18));
//    }
//}
//
//contract AllocateRegisterInitialisationTest is L1cmETHTest {
//    function testInitialize() public {
////        // Register MNT
////        assertEq(allocateRegisterMNT.getRoleAdmin(allocateRegisterMNT.REGISTER_MANAGER_ROLE()),
////            allocateRegisterMNT.DEFAULT_ADMIN_ROLE(), "allocateRegisterMNT admin not initialized properly");
////        assertEq(allocateRegisterMNT.getRoleAdmin(allocateRegisterMNT.REGISTER_OPERATOR_ROLE()),
////            allocateRegisterMNT.DEFAULT_ADMIN_ROLE(), "allocateRegisterMNT admin not initialized properly");
////        require(allocateRegisterMNT.hasRole(allocateRegisterMNT.DEFAULT_ADMIN_ROLE(), admin),
////            "allocateRegisterMNT DEFAULT_ADMIN_ROLE role not initialized properly");
////        require(allocateRegisterMNT.hasRole(allocateRegisterMNT.REGISTER_MANAGER_ROLE(), registerManager),
////            "allocateRegisterMNT REGISTER_MANAGER_ROLE role not initialized properly");
////        require(allocateRegisterMNT.hasRole(allocateRegisterMNT.REGISTER_OPERATOR_ROLE(), registerOperator),
////            "allocateRegisterMNT REGISTER_OPERATOR_ROLE role not initialized properly");
////
////        // Register METH
////        assertEq(allocateRegisterMETH.getRoleAdmin(allocateRegisterMETH.REGISTER_MANAGER_ROLE()),
////            allocateRegisterMETH.DEFAULT_ADMIN_ROLE(), "allocateRegisterMETH admin not initialized properly");
////        assertEq(allocateRegisterMETH.getRoleAdmin(allocateRegisterMETH.REGISTER_OPERATOR_ROLE()),
////            allocateRegisterMETH.DEFAULT_ADMIN_ROLE(), "allocateRegisterMETH admin not initialized properly");
////        require(allocateRegisterMETH.hasRole(allocateRegisterMETH.DEFAULT_ADMIN_ROLE(), admin),
////            "allocateRegisterMETH DEFAULT_ADMIN_ROLE role not initialized properly");
////        require(allocateRegisterMETH.hasRole(allocateRegisterMETH.REGISTER_MANAGER_ROLE(), registerManager),
////            "allocateRegisterMETH REGISTER_MANAGER_ROLE role not initialized properly");
////        require(allocateRegisterMETH.hasRole(allocateRegisterMETH.REGISTER_OPERATOR_ROLE(), registerOperator),
////            "allocateRegisterMETH REGISTER_OPERATOR_ROLE role not initialized properly");
//
////        // l1MessagingStatus
////        assertEq(dps.l1MessagingStatus.getRoleAdmin(dps.l1MessagingStatus.MANAGER_ROLE()),
////            dps.l1MessagingStatus.DEFAULT_ADMIN_ROLE(), "l1MessagingStatus default admin not initialized properly");
////        assertEq(dps.l1MessagingStatus.getRoleAdmin(dps.l1MessagingStatus.PAUSER_ROLE()),
////            dps.l1MessagingStatus.DEFAULT_ADMIN_ROLE(), "l1MessagingStatus pauser admin not initialized properly");
////        assertEq(dps.l1MessagingStatus.getRoleAdmin(dps.l1MessagingStatus.UNPAUSER_ROLE()),
////            dps.l1MessagingStatus.DEFAULT_ADMIN_ROLE(), "l1MessagingStatus unpauser admin not initialized properly");
////        require(dps.l1MessagingStatus.hasRole(dps.l1MessagingStatus.DEFAULT_ADMIN_ROLE(), admin),
////            "l1MessagingStatus DEFAULT_ADMIN_ROLE role not initialized properly");
////        require(dps.l1MessagingStatus.hasRole(dps.l1MessagingStatus.MANAGER_ROLE(), manager),
////            "l1cmETH MANAGER_ROLE role not initialized properly");
////        require(dps.l1MessagingStatus.hasRole(dps.l1MessagingStatus.PAUSER_ROLE(), pauser),
////            "l1cmETH PAUSER_ROLE role not initialized properly");
////        require(dps.l1MessagingStatus.hasRole(dps.l1MessagingStatus.UNPAUSER_ROLE(), unpauser),
////            "l1cmETH UNPAUSER_ROLE role not initialized properly");
//    }
//}
//
//contract AllocateRegisterVandalTest is AllocateRegisterTest {
//    address public immutable vandal = makeAddr("vandal");
//    uint256 public immutable amount = 100 * 1e18;
//
//    function testListFailed() public {
////        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, allocateRegisterMNT.REGISTER_MANAGER_ROLE()));
////        vm.prank(vandal);
////        allocateRegisterMNT.listTranche(address(tranche));
//    }
//
//    function testRemoveFailed() public {
////        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, allocateRegisterMNT.REGISTER_MANAGER_ROLE()));
////        vm.prank(vandal);
////        allocateRegisterMNT.removeTranche(address(tranche));
//    }
//
//    function testAllocateFailed() public {
////        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, allocateRegisterMNT.REGISTER_OPERATOR_ROLE()));
////        vm.prank(vandal);
////        allocateRegisterMNT.allocate(address(tranche), vandal, amount);
//    }
//
//    function testUnAllocateFailed() public {
////        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, allocateRegisterMNT.REGISTER_OPERATOR_ROLE()));
////        vm.prank(vandal);
////        allocateRegisterMNT.unallocate(address(tranche), vandal, amount);
//    }
//}
//
//contract AllocateRegisterFunctionalTest is AllocateRegisterTest {
//    address public immutable owner = makeAddr("vandal");
//    uint256 public immutable amount = 100 * 1e18;
//
//    function testListAndRemoveSuccess() public {
////        vm.prank(registerManager);
////        allocateRegisterMNT.listTranche(address(tranche));
////        (uint256 _len,) = allocateRegisterMNT.listTranches();
////        assertEq(_len, 1, "listTranches length not equal");
////        vm.prank(registerManager);
////        allocateRegisterMNT.removeTranche(address(tranche));
////        (uint256 len_,) = allocateRegisterMNT.listTranches();
////        assertEq(len_, 0, "removeTranche length not equal");
//    }
//
//    function testChangeAllocateSuccess() public {
////        vm.prank(registerManager);
////        allocateRegisterMNT.listTranche(address(tranche));
////
////        IAllocateRegister.AllocateMsg[] memory msgs = new IAllocateRegister.AllocateMsg[](1);
////        msgs[0] = IAllocateRegister.AllocateMsg({tranche: address(tranche), owner: owner, amount: int256(amount)});
////        vm.prank(registerOperator);
////        allocateRegisterMNT.changeAllocate(msgs);
//    }
//
//    function testAllocateUnAllocateSuccess() public {
////        vm.prank(registerOperator);
////        allocateRegisterMNT.allocate(address(tranche), owner, amount);
////        require(allocateRegisterMNT.totalAllocated(address(tranche)) == amount, "totalAllocated not correct after allocate");
////        require(allocateRegisterMNT.userTotalAllocated(owner) == amount, "userTotalAllocated not correct after allocate");
////
////        vm.prank(registerOperator);
////        allocateRegisterMNT.unallocate(address(tranche), owner, amount);
////        require(allocateRegisterMNT.totalAllocated(address(tranche)) == 0, "totalAllocated not correct after unallocate");
////        require(allocateRegisterMNT.userTotalAllocated(owner) == 0, "userTotalAllocated not correct after unallocate");
//    }
//}
