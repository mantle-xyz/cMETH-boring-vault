// SPDX-License-Identifier: MIT LICENSE
pragma solidity ^0.8.18;

import "lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";

import {testDeployL2, newL2cmETH, newL2MessagingStatus} from "./utils/Deploy.sol";
import {L2DeploymentParams, L2Deployments} from "../script/helpers/Proxy.sol";
import {BaseTest} from "./BaseTest.sol";

import {console2 as console} from "forge-std/console2.sol";

contract StakingMETHTest is BaseTest {
    L2Deployments public dps;

    function setUp() public override {
//        vm.startPrank(admin);
//        dps = testDeployAll(deploymentParams(), admin);
//        vm.stopPrank();
//        allocateRegisterMETH = dps.allocateRegisterMETH;
//        stakingMETH = dps.stakingMETH;
//        pauser = dps.pauser;
    }
}

contract StakingInitialisationTest is StakingMETHTest {
    function testInitialize() view public {
//        // staking MNT
//        assertEq(stakingMETH.getRoleAdmin(stakingMETH.STAKING_OPERATOR_ROLE()),
//            stakingMETH.DEFAULT_ADMIN_ROLE(), "stakingMETH admin not initialized properly");
//        require(stakingMETH.hasRole(stakingMETH.DEFAULT_ADMIN_ROLE(), admin),
//            "stakingMETH DEFAULT_ADMIN_ROLE role not initialized properly");
//        require(stakingMETH.hasRole(stakingMETH.STAKING_OPERATOR_ROLE(), address(operator)),
//            "stakingMETH REGISTER_MANAGER_ROLE role not initialized properly");
//
//        assertEq(address(stakingMETH.pauser()), address(pauser), "stakingMETH pauser not initialized properly");
//        assertEq(address(stakingMETH.asset()), address(assetMETH), "stakingMETH asset not initialized properly");
//        assertEq(uint256(stakingMETH.cooldown()), uint256(cooldown), "stakingMETH cooldown not initialized properly");
//        assertEq(uint256(stakingMETH.minStake()), uint256(minStake), "stakingMETH minStake not initialized properly");
//        assertEq(uint256(stakingMETH.maxStakeSupply()), uint256(maxStakeSupply), "stakingMETH maxStakeSupply not initialized properly");
//        assertEq(address(stakingMETH.allocator()), address(allocateRegisterMETH), "stakingMETH allocator not initialized properly");
    }
}

contract StakingVandalTest is StakingMETHTest {
    address public vandal = makeAddr("vandal");

    function testSetCooldownFailed() public {
//        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, stakingMETH.STAKING_OPERATOR_ROLE()));
//        vm.prank(vandal);
//        stakingMETH.setCooldown(200);
    }

    function testSetMinStakeFailed() public {
//        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, stakingMETH.STAKING_OPERATOR_ROLE()));
//        vm.prank(vandal);
//        stakingMETH.setMinStake(200);
    }

    function testSetMaxStakeSupplyFailed() public {
//        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, stakingMETH.STAKING_OPERATOR_ROLE()));
//        vm.prank(vandal);
//        stakingMETH.setMaxStakeSupply(200);
    }
}

contract StakingMETHFunctionalStakeTest is StakingMETHTest {
    address public owner = makeAddr("owner");
    uint256 public amount = 1e18;

    function testMETHDepositWithdrawSuccess() public {
//        ERC20Mock token = new ERC20Mock();
//        bytes memory code = address(token).code;
//
//        vm.etch(assetMETH, code);
//        ERC20Mock(assetMETH).mint(owner, amount);
//
//        vm.startPrank(owner);
//        ERC20Mock(assetMETH).approve(address(stakingMETH), amount);
//        uint256 amount_ = stakingMETH.deposit(amount);
//        vm.stopPrank();
//        assertEq(amount_, amount, "deposit amount not expected");
//        assertEq(ERC20Mock(assetMETH).balanceOf(owner), 0, "user amount after deposit not correct");
//        assertEq(ERC20Mock(assetMETH).balanceOf(address(stakingMETH)), amount, "vault amount after deposit not correct");
//
//        (bool inCooldown, uint256 cooldown) = stakingMETH.userStakeCooldown(owner);
//        require(inCooldown, "cooldown status expected after stake");
//        assertEq(cooldown, uint256(10), "cooldown expected");
//
//        vm.warp(100);
//        vm.prank(owner);
//        uint256 assets = stakingMETH.withdraw(amount, owner);
//        assertEq(uint256(assets), uint256(amount), "withdraw amount not expected");
//        assertEq(ERC20Mock(assetMETH).balanceOf(owner), amount, "balance after withdraw not correct");
    }

    function testMETHDepositWithLockupFuzzed() public {
//        ERC20Mock token = new ERC20Mock();
//        bytes memory code = address(token).code;
//
//        vm.etch(assetMETH, code);
//        ERC20Mock(assetMETH).mint(owner, amount);
//
//        vm.startPrank(owner);
//        ERC20Mock(assetMETH).approve(address(stakingMETH), amount);
//        uint256 amount_ = stakingMETH.depositWithLockup(amount, 50);
//        vm.stopPrank();
//        assertEq(amount_, amount, "deposit amount not expected");
//        assertEq(ERC20Mock(assetMETH).balanceOf(owner), 0, "user amount after deposit not correct");
//        assertEq(ERC20Mock(assetMETH).balanceOf(address(stakingMETH)), amount, "vault amount after deposit not correct");
//
//        (bool inCooldown, uint256 cooldown) = stakingMETH.userStakeCooldown(owner);
//        require(inCooldown, "cooldown status expected after stake");
//        assertEq(cooldown, uint256(10), "cooldown expected");
//
//        vm.expectRevert(StakingMETH.Cooldown.selector);
//        vm.prank(owner);
//        stakingMETH.withdraw(amount, owner);
//
//        vm.warp(block.timestamp + stakingMETH.cooldown());
//        vm.expectRevert(StakingMETH.InsufficientWithdrawableBalance.selector);
//        vm.prank(owner);
//        stakingMETH.withdraw(amount, owner);
//
//        vm.warp(block.timestamp + 60 days);
//        vm.prank(owner);
//        uint256 assets = stakingMETH.withdraw(amount, owner);
//        assertEq(uint256(assets), uint256(amount), "withdraw amount not expected");
//        assertEq(ERC20Mock(assetMETH).balanceOf(owner), amount, "balance after withdraw not correct");
    }

    function testMETHSetCooldownSuccess() public {
//        vm.prank(operator);
//        stakingMETH.setCooldown(200);
    }

    function testMETHSetMinStakeSuccess() public {
//        vm.prank(operator);
//        stakingMETH.setMinStake(200);
    }

    function testMETHSetMaxStakeSupplySuccess() public {
//        vm.prank(operator);
//        stakingMETH.setMaxStakeSupply(200);
    }

    function testMETHAddLockDurationSuccess() public {
//        vm.prank(operator);
//        stakingMETH.addLockDuration(400 days);
//        assertEq(stakingMETH.durations().length, 5, "durations amount not expected");
    }

    function testMETHRemoveLockDurationSuccess() public {
//        vm.prank(operator);
//        stakingMETH.removeLockDuration(200 days);
//        assertEq(stakingMETH.durations().length, 3, "durations amount not expected");
    }
}
