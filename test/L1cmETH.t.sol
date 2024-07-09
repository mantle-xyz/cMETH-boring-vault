// SPDX-License-Identifier: MIT LICENSE
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import {IAccessControl} from "lib/openzeppelin-contracts-upgradeable/lib/openzeppelin-contracts/contracts/access/IAccessControl.sol";

import {L1cmETH} from "../src/L1cmETH.sol";
import {testDeployL1, newL1MessagingStatus} from "./utils/Deploy.sol";
import {L1Deployments, L2Deployments} from "../script/helpers/Proxy.sol";
import {BaseTest} from "./BaseTest.sol";

contract L1cmETHTest is BaseTest {
    L1Deployments public dps;
    L1cmETH public l1cmETH;

    function setUp() public override {
        super.setUp();
        vm.startPrank(admin);
        dps = testDeployL1(l1DeploymentParams(), admin);
        vm.stopPrank();
        l1cmETH = dps.l1cmETH;
    }
}

contract L1cmETHInitialisationTest is L1cmETHTest {
    function testInitialize() public view {
        // l1cmETH
        assertEq(l1cmETH.getRoleAdmin(l1cmETH.MANAGER_ROLE()),
            l1cmETH.DEFAULT_ADMIN_ROLE(), "l1cmETH default admin not initialized properly");
        assertEq(l1cmETH.getRoleAdmin(l1cmETH.MINTER_ROLE()),
            l1cmETH.DEFAULT_ADMIN_ROLE(), "l1cmETH minter admin not initialized properly");
        assertEq(l1cmETH.getRoleAdmin(l1cmETH.BURNER_ROLE()),
            l1cmETH.DEFAULT_ADMIN_ROLE(), "l1cmETH burner admin not initialized properly");
        require(l1cmETH.hasRole(l1cmETH.DEFAULT_ADMIN_ROLE(), admin),
            "l1cmETH DEFAULT_ADMIN_ROLE role not initialized properly");
        require(l1cmETH.hasRole(l1cmETH.MANAGER_ROLE(), manager),
            "l1cmETH MANAGER_ROLE role not initialized properly");
        require(l1cmETH.hasRole(l1cmETH.MINTER_ROLE(), minter),
            "l1cmETH MINTER_ROLE role not initialized properly");
        require(l1cmETH.hasRole(l1cmETH.BURNER_ROLE(), burner),
            "l1cmETH BURNER_ROLE role not initialized properly");
    }
}

contract L1cmETHVandalTest is L1cmETHTest {
    address public immutable vandal = makeAddr("vandal");
    uint256 public immutable amount = 100 * 1e18;
    uint16 public immutable newFeeRate = 2;

    function testSetMaxTotalSupplyFailed() public {
        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, l1cmETH.MANAGER_ROLE()));
        vm.prank(vandal);
        l1cmETH.setMaxTotalSupply(amount);
    }

    function testSetBlocklistFailed() public {
        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, l1cmETH.MANAGER_ROLE()));
        vm.prank(vandal);
        l1cmETH.setBlocklist(blocklist);
    }

    function testSetSanctionsListFailed() public {
        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, l1cmETH.MANAGER_ROLE()));
        vm.prank(vandal);
        l1cmETH.setSanctionsList(sanctionList);
    }

    function testMintFailed() public {
        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, l1cmETH.MINTER_ROLE()));
        vm.prank(vandal);
        l1cmETH.mint(vandal, amount);
    }

    function testBurnFailed() public {
        vm.expectRevert(abi.encodeWithSignature("AccessControlUnauthorizedAccount(address,bytes32)", vandal, l1cmETH.BURNER_ROLE()));
        vm.prank(vandal);
        l1cmETH.burn(vandal, amount);
    }
}

contract L1cmETHFunctionalTest is L1cmETHTest {
    address public immutable owner = makeAddr("vandal");
    uint256 public immutable amount = 100 * 1e18;

    function testSetMaxTotalSupplySuccess() public {
        vm.prank(manager);
        l1cmETH.setMaxTotalSupply(amount);
        uint256 maxTotalSupply = l1cmETH.maxTotalSupply();
        assertEq(maxTotalSupply, amount, "maxTotalSupply not equal");
    }

    function testSetBlocklistSuccess() public {
        vm.prank(manager);
        l1cmETH.setBlocklist(blocklist);
        address newBlocklist = l1cmETH.blocklist();
        assertEq(newBlocklist, blocklist, "blocklist not equal");
    }

    function testSetSanctionsListSuccess() public {
        vm.prank(manager);
        l1cmETH.setSanctionsList(sanctionList);
        address newSanctionsList = l1cmETH.sanctionsList();
        assertEq(newSanctionsList, sanctionList, "sanctionList not equal");
    }

    function testMintBurnSuccess() public {
        vm.prank(minter);
        l1cmETH.mint(owner, amount);
        uint256 _balance = l1cmETH.balanceOf(owner);
        assertEq(_balance, amount, "_balance not equal");
        vm.prank(burner);
        l1cmETH.burn(owner, amount);
        uint256 balance_ = l1cmETH.balanceOf(owner);
        assertEq(balance_, 0, "balance_ not equal");
    }
}
