// SPDX-License-Identifier: MIT LICENSE
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {IAccessControl} from "lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/access/IAccessControl.sol";

import {L1cmETHAdapter} from "../src/L1cmETHAdapter.sol";
import {testDeployL1, newL1MessagingStatus} from "./utils/Deploy.sol";
import {L1Deployments, L2Deployments} from "../script/helpers/Proxy.sol";
import {BaseTest} from "./BaseTest.sol";

contract L1AdapterTest is BaseTest {
    L1Deployments public dps;
    L1cmETHAdapter public l1Adapter;

    function setUp() public override {
        super.setUp();
        vm.startPrank(admin);
        dps = testDeployL1(l1DeploymentParams(), admin);
        vm.stopPrank();
        l1Adapter = dps.l1Adaptor;
    }
}

contract L1AdapterInitialisationTest is L1AdapterTest {
    function testInitialize() public view {
        // l1Adapter
        assertEq(l1Adapter.getRoleAdmin(l1Adapter.MANAGER_ROLE()),
            l1Adapter.DEFAULT_ADMIN_ROLE(), "l1Adapter default admin not initialized properly");
        require(l1Adapter.hasRole(l1Adapter.DEFAULT_ADMIN_ROLE(), admin),
            "l1Adapter DEFAULT_ADMIN_ROLE role not initialized properly");
        require(l1Adapter.hasRole(l1Adapter.MANAGER_ROLE(), manager),
            "l1Adapter MANAGER_ROLE role not initialized properly");
    }
}

contract L1AdapterVandalTest is L1AdapterTest {
    address public immutable vandal = makeAddr("vandal");
    uint16 public immutable newFeeRate = 2;

    function testSetFeeRateFailed() public {
        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, l1Adapter.MANAGER_ROLE()));
        vm.prank(vandal);
        l1Adapter.setFeeRate(newFeeRate);
    }
}

contract L1AdapterFunctionalTest is L1AdapterTest {
    address public immutable owner = makeAddr("vandal");
    uint16 public immutable newFeeRate = 2;

    function testSetFeeRateSuccess() public {
        vm.prank(manager);
        l1Adapter.setFeeRate(newFeeRate);
        uint256 feeRate_ = l1Adapter.feeRate();
        assertEq(feeRate_, newFeeRate, "feeRate not equal");
    }
}
