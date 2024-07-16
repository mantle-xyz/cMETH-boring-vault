// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ITransparentUpgradeableProxy} from "src/lib/TransparentUpgradeableProxy.sol";
import {Initializable} from "openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import {TimelockController} from "openzeppelin/governance/TimelockController.sol";
import {L1DeploymentParams, L1Deployments, L2DeploymentParams, L2Deployments} from "../script/helpers/Proxy.sol";
import {testDeployL1, testDeployL2} from "./utils/Deploy.sol";
import {BaseTest} from "./BaseTest.sol";

interface DummyUpgradeEvents {
    event DummyUpgraded(string message);
}

contract DummyUpgrade is Initializable, DummyUpgradeEvents {
    function reinitialize(string memory message) public reinitializer(69) {
        emit DummyUpgraded(message);
    }
}

/// @dev Demonstrates that all contracts set up using `deployAll` are upgradeable..
contract UpgradeableTest is BaseTest, DummyUpgradeEvents {
    DummyUpgrade newImpl;
    L1Deployments l1dps;
    L2Deployments l2dps;

    function setUp() public override {
        super.setUp();
        newImpl = new DummyUpgrade();
        vm.startPrank(admin);
        l1dps = testDeployL1(l1DeploymentParams(), admin);
        l2dps = testDeployL2(l2DeploymentParams(), admin);
        vm.stopPrank();
    }

    function _testUpgradeL1(ITransparentUpgradeableProxy proxy) internal {
        vm.startPrank(upgrader);

        string memory message = "Dummy upgraded";
        proxy.upgradeToAndCall(address(newImpl), abi.encodeCall(DummyUpgrade.reinitialize, (message)));
        emit DummyUpgraded(message);
        vm.stopPrank();
    }

    function _testUpgradeL2(ITransparentUpgradeableProxy proxy) internal {
        vm.startPrank(upgrader);

        string memory message = "Dummy upgraded";
        proxy.upgradeToAndCall(address(newImpl), abi.encodeCall(DummyUpgrade.reinitialize, (message)));
        emit DummyUpgraded(message);
        vm.stopPrank();
    }

    function testUpgradeL1cmETH() public {
        _testUpgradeL1(ITransparentUpgradeableProxy(address(l1dps.l1cmETH)));
    }

    function testUpgradeL1MessagingStatus() public {
        _testUpgradeL1(ITransparentUpgradeableProxy(address(l1dps.l1MessagingStatus)));
    }

    function testUpgradeL2cmETH() public {
        _testUpgradeL2(ITransparentUpgradeableProxy(address(l2dps.l2cmETH)));
    }

    function testUpgradeL2MessagingStatus() public {
        _testUpgradeL2(ITransparentUpgradeableProxy(address(l2dps.l2MessagingStatus)));
    }
}
