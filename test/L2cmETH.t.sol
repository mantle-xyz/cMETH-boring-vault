// SPDX-License-Identifier: MIT LICENSE
pragma solidity ^0.8.18;

import {BaseTest} from "./BaseTest.sol";
import {L2cmETH} from "../src/L2cmETH.sol";
import {L2DeploymentParams, L2Deployments} from "../script/helpers/Proxy.sol";
import {testDeployL2, newL2cmETH, newL2MessagingStatus} from "./utils/Deploy.sol";

import {console2 as console} from "forge-std/console2.sol";

contract L2cmETHTest is BaseTest {
    L2Deployments public dps;
    L2cmETH public l2cmETH;

    function setUp() virtual public override {
        super.setUp();
        vm.startPrank(admin);
        dps = testDeployL2(l2DeploymentParams(), admin);
        vm.stopPrank();
        l2cmETH = dps.l2cmETH;
    }
}

contract L2cmETHInitialisationTest is L2cmETHTest {
    function testL2cmETHInitialize() view public {
        assertEq(address(l2cmETH.owner()), owner, "l2cmETH owner not initialized properly");
        assertEq(address(l2cmETH.status()), address(dps.l2MessagingStatus), "l2cmETH status not initialized properly");
        assertEq(l2cmETH.getRoleAdmin(l2cmETH.MANAGER_ROLE()),
            l2cmETH.DEFAULT_ADMIN_ROLE(), "l2cmETH default admin not initialized properly");
        require(l2cmETH.hasRole(l2cmETH.DEFAULT_ADMIN_ROLE(), admin),
            "l2cmETH DEFAULT_ADMIN_ROLE role not initialized properly");
        require(l2cmETH.hasRole(l2cmETH.MANAGER_ROLE(), manager),
            "l2cmETH MANAGER_ROLE role not initialized properly");
    }
}

contract L2cmETHVandalTest is L2cmETHTest {
    address public vandal = makeAddr("vandal");

    function testSetBlocklistFailed() public {
        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, l2cmETH.MANAGER_ROLE()));
        vm.prank(vandal);
        l2cmETH.setBlocklist(blocklist);
    }

    function testSetSanctionsListFailed() public {
        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, l2cmETH.MANAGER_ROLE()));
        vm.prank(vandal);
        l2cmETH.setSanctionsList(sanctionList);
    }
}

contract L2cmETHFunctionalTest is L2cmETHTest {
    address public sender = makeAddr("sender");
    uint256 public amount = 1e18;

    function testSetBlocklistSuccess() public {
        vm.prank(manager);
        l2cmETH.setBlocklist(blocklist);
        address newBlocklist = l2cmETH.blocklist();
        assertEq(newBlocklist, blocklist, "blocklist not equal");
    }

    function testSetSanctionsListSuccess() public {
        vm.prank(manager);
        l2cmETH.setSanctionsList(sanctionList);
        address newSanctionsList = l2cmETH.sanctionsList();
        assertEq(newSanctionsList, sanctionList, "sanctionList not equal");
    }

    function testBlockAndSanction() public {

    }
}
