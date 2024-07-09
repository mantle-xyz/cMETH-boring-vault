// SPDX-License-Identifier: MIT LICENSE
pragma solidity ^0.8.18;

import {testDeployL2, newL2cmETH, newL2MessagingStatus} from "./utils/Deploy.sol";
import {L2DeploymentParams, L2Deployments} from "../script/helpers/Proxy.sol";

import {BaseTest} from "./BaseTest.sol";

import {console2 as console} from "forge-std/console2.sol";

contract L2cmETHTest is BaseTest {
    L2Deployments public dps;

    function setUp() public override {
//        vm.startPrank(admin);
//        dps = testDeployAll(deploymentParams(), admin);
//        vm.stopPrank();
//        allocateRegisterMNT = dps.allocateRegisterMNT;
//        stakingMNT = dps.stakingMNT;
//        pauser = dps.pauser;
    }
}

contract StakingInitialisationTest is L2cmETHTest {
    function testInitialize() view public {
//        // staking MNT
//        assertEq(stakingMNT.getRoleAdmin(stakingMNT.STAKING_OPERATOR_ROLE()),
//            stakingMNT.DEFAULT_ADMIN_ROLE(), "stakingMNT admin not initialized properly");
//        require(stakingMNT.hasRole(stakingMNT.DEFAULT_ADMIN_ROLE(), admin),
//            "stakingMNT DEFAULT_ADMIN_ROLE role not initialized properly");
//        require(stakingMNT.hasRole(stakingMNT.STAKING_OPERATOR_ROLE(), address(operator)),
//            "stakingMNT REGISTER_MANAGER_ROLE role not initialized properly");
//
//        assertEq(address(stakingMNT.pauser()), address(pauser), "stakingMNT pauser not initialized properly");
//        assertEq(address(stakingMNT.asset()), address(address(0)), "stakingMNT asset not initialized properly");
//        assertEq(uint256(stakingMNT.cooldown()), uint256(cooldown), "stakingMNT cooldown not initialized properly");
//        assertEq(uint256(stakingMNT.minStake()), uint256(minStake), "stakingMNT minStake not initialized properly");
//        assertEq(uint256(stakingMNT.maxStakeSupply()), uint256(maxStakeSupply), "stakingMNT maxStakeSupply not initialized properly");
//        assertEq(address(stakingMNT.allocator()), address(allocateRegisterMNT), "stakingMNT allocator not initialized properly");
    }
}

contract StakingVandalTest is L2cmETHTest {
    address public vandal = makeAddr("vandal");

    function testSetCooldownFailed() public {
//        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, stakingMNT.STAKING_OPERATOR_ROLE()));
//        vm.prank(vandal);
//        stakingMNT.setCooldown(200);
    }

    function testSetMinStakeFailed() public {
//        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, stakingMNT.STAKING_OPERATOR_ROLE()));
//        vm.prank(vandal);
//        stakingMNT.setMinStake(200);
    }

    function testSetMaxStakeSupplyFailed() public {
//        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, stakingMNT.STAKING_OPERATOR_ROLE()));
//        vm.prank(vandal);
//        stakingMNT.setMaxStakeSupply(200);
    }

    function testAddLockDurationFailed() public {
//        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, stakingMNT.STAKING_OPERATOR_ROLE()));
//        vm.prank(vandal);
//        stakingMNT.addLockDuration(200);
    }

    function testRemoveLockDurationFailed() public {
//        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, stakingMNT.STAKING_OPERATOR_ROLE()));
//        vm.prank(vandal);
//        stakingMNT.removeLockDuration(200);
    }

    function testUnlockLockupsFailed() public {
//        address[] memory addresses = new address[](1);
//        uint256[] memory amounts = new uint256[](1);
//        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, stakingMNT.STAKING_OPERATOR_ROLE()));
//        vm.prank(vandal);
//        stakingMNT.unlockLockups(addresses, amounts);
    }
}

contract StakingMNTFunctionalStakeTest is L2cmETHTest {
    address public owner = makeAddr("owner");
    uint256 public amount = 1e18;

    function testDepositWithdrawSuccess() public {
//        vm.deal(owner, 2*amount);
//        vm.prank(owner);
//        (bool ok, bytes memory data) = address(stakingMNT).call{value: amount}(
//            abi.encodeWithSignature("deposit(uint256)", amount));
//        require(ok, "stakingMNT.deposit() failed.");
//        assertEq(uint256(bytes32(data)), amount, "deposit amount not expected");
//        assertEq(owner.balance, amount, "amount after deposit not correct");
//
//        (bool inCooldown, uint256 cooldown) = stakingMNT.userStakeCooldown(owner);
//        require(inCooldown, "cooldown status expected after stake");
//        assertEq(cooldown, uint256(10), "cooldown expected");
//
//        vm.warp(100);
//        vm.prank(owner);
//        uint256 assets = stakingMNT.withdraw(amount, owner);
//        assertEq(uint256(assets), uint256(amount), "withdraw amount not expected");
//        assertEq(owner.balance, 2*amount, "balance after withdraw not correct");
    }

    function testDepositWithLockupFuzzed() public {
//        vm.deal(owner, 2*amount);
//        vm.prank(owner);
//        (bool ok, bytes memory data) = address(stakingMNT).call{value: amount}(
//            abi.encodeWithSignature("depositWithLockup(uint256,uint256)", amount, 50));
//        require(ok, "stakingMNT.depositWithLockup() failed.");
//        assertEq(uint256(bytes32(data)), amount, "depositWithLockup amount not expected");
//        assertEq(owner.balance, amount, "amount after depositWithLockup not correct");
//        uint256 lockUps = stakingMNT.getUserLockUps(owner);
//        assertEq(lockUps, amount, "amount after depositWithLockup not correct");
//
//        vm.expectRevert(StakingMNT.Cooldown.selector);
//        vm.prank(owner);
//        stakingMNT.withdraw(amount, owner);
//
//        vm.warp(block.timestamp + stakingMNT.cooldown());
//        vm.expectRevert(StakingMNT.InsufficientWithdrawableBalance.selector);
//        vm.prank(owner);
//        stakingMNT.withdraw(amount, owner);
//
//        vm.warp(block.timestamp + 50 days);
//        vm.prank(owner);
//        uint256 asset_ = stakingMNT.withdraw(amount, owner);
//        assertEq(asset_, amount, "withdraw amount not expected");
//        assertEq(owner.balance, 2*amount, "amount after withdraw not correct");
    }

    function testSetCooldownSuccess() public {
//        vm.prank(operator);
//        stakingMNT.setCooldown(200);
//        assertEq(stakingMNT.cooldown(), 200, "withdraw amount not expected");
    }

    function testSetMinStakeSuccess() public {
//        vm.prank(operator);
//        stakingMNT.setMinStake(200);
//        assertEq(stakingMNT.minStake(), 200, "minStake amount not expected");
    }

    function testSetMaxStakeSupplySuccess() public {
//        vm.prank(operator);
//        stakingMNT.setMaxStakeSupply(200);
//        assertEq(stakingMNT.maxStakeSupply(), 200, "maxStakeSupply amount not expected");
    }

    function testAddLockDurationSuccess() public {
//        vm.prank(operator);
//        stakingMNT.addLockDuration(400 days);
//        assertEq(stakingMNT.durations().length, 5, "durations amount not expected");
    }

    function testRemoveLockDurationSuccess() public {
//        vm.prank(operator);
//        stakingMNT.removeLockDuration(200 days);
//        assertEq(stakingMNT.durations().length, 3, "durations amount not expected");
    }

    function testUnlockLockupsSuccess() public {
//        vm.deal(owner, 2*amount);
//        vm.prank(owner);
//        (bool ok, bytes memory data) = address(stakingMNT).call{value: amount}(
//            abi.encodeWithSignature("depositWithLockup(uint256,uint256)", amount, 50));
//        require(ok, "stakingMNT.depositWithLockup() failed.");
//        assertEq(uint256(bytes32(data)), amount, "depositWithLockup amount not expected");
//        assertEq(owner.balance, amount, "amount after depositWithLockup not correct");
//        uint256 lockUps = stakingMNT.getUserLockUps(owner);
//        assertEq(lockUps, amount, "amount after depositWithLockup not correct");
//
//        vm.expectRevert(StakingMNT.Cooldown.selector);
//        vm.prank(owner);
//        stakingMNT.withdraw(amount, owner);
//
//        vm.warp(block.timestamp + stakingMNT.cooldown());
//        vm.expectRevert(StakingMNT.InsufficientWithdrawableBalance.selector);
//        vm.prank(owner);
//        stakingMNT.withdraw(amount, owner);
//
//        address[] memory addresses = new address[](1);
//        uint256[] memory amounts = new uint256[](1);
//        addresses[0] = owner;
//        amounts[0] = amount;
//        vm.prank(operator);
//        stakingMNT.unlockLockups(addresses, amounts);
//
//        vm.prank(owner);
//        stakingMNT.withdraw(amount, owner);
//        assertEq(owner.balance, 2*amount, "user balance amount after withdraw not correct");
//        uint256 lockUps_ = stakingMNT.getUserLockUps(owner);
//        assertEq(lockUps_, 0, "user lockups amount after withdraw not correct");
    }
}
