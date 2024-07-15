// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITransparentUpgradeableProxy, TransparentUpgradeableProxy} from "src/lib/TransparentUpgradeableProxy.sol";
import {TimelockController} from "openzeppelin/governance/TimelockController.sol";

import {L1cmETH} from "../../src/L1cmETH.sol";
import {L1cmETHAdapter} from "../../src/L1cmETHAdapter.sol";
import {L2cmETH} from "../../src/L2cmETH.sol";
import {L1MessagingStatus} from "../../src/L1MessagingStatus.sol";
import {L2MessagingStatus} from "../../src/L2MessagingStatus.sol";

import {initL1cmETH, initL1MessagingStatus, initL2cmETH, initL1cmETHAdaptor, initL2MessagingStatus} from "../../script/helpers/Proxy.sol";
import {EmptyContract, deployL1, L1DeploymentParams, L1Deployments, deployL2, L2DeploymentParams, L2Deployments} from "../../script/helpers/Proxy.sol";

import {console2 as console} from "forge-std/console2.sol";

function newProxyWithAdmin(TimelockController admin) returns (ITransparentUpgradeableProxy) {
    EmptyContract empty = new EmptyContract();
    return ITransparentUpgradeableProxy(
        address(
            new TransparentUpgradeableProxy(
                    address(empty),
                    address(admin),
                    ""
                )
        )
    );
}

function newL1cmETH(ITransparentUpgradeableProxy proxy, L1cmETH.Init memory init) returns (L1cmETH) {
    return initL1cmETH(proxy, init);
}

function newL1cmETHAdaptor(ITransparentUpgradeableProxy proxy, L1cmETHAdapter.Init memory init, address token, address endpoint) returns (L1cmETHAdapter) {
    return initL1cmETHAdaptor(proxy, init, token, endpoint);
}

function newL1MessagingStatus(ITransparentUpgradeableProxy proxy, L1MessagingStatus.Init memory init, address endpoint) returns (L1MessagingStatus) {
    return initL1MessagingStatus(proxy, init, endpoint);
}

function newL2cmETH(ITransparentUpgradeableProxy proxy,  L2cmETH.Init memory init, address endpoint) returns (L2cmETH) {
    return initL2cmETH(proxy, init, endpoint);
}

function newL2MessagingStatus(ITransparentUpgradeableProxy proxy, L2MessagingStatus.Init memory init, address endpoint) returns (L2MessagingStatus) {
    return initL2MessagingStatus(proxy, init, endpoint);
}

function testDeployL1(L1DeploymentParams memory params, address deployer) returns(L1Deployments memory) {
    L1Deployments memory deps = deployL1(params, deployer);
    return deps;
}

function testDeployL2(L2DeploymentParams memory params, address deployer) returns(L2Deployments memory) {
    L2Deployments memory deps = deployL2(params, deployer);
    return deps;
}
