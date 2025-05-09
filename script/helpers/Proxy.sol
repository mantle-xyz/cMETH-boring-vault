// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AccessControl} from "openzeppelin/access/AccessControl.sol";
import {TimelockController} from "openzeppelin/governance/TimelockController.sol";
import {ERC1967Utils} from "openzeppelin/proxy/ERC1967/ERC1967Utils.sol";
import {AccessControlUpgradeable} from "openzeppelin-upgradeable/access/AccessControlUpgradeable.sol";
import {ITransparentUpgradeableProxy, TransparentUpgradeableProxy} from "src/lib/TransparentUpgradeableProxy.sol";

import {console2 as console} from "forge-std/console2.sol";
import {BlockListClientUpgradeable} from "../../src/ClientBlockListUpgradable.sol";
import {SanctionsListClientUpgradeable} from "../../src/ClientSanctionsListUpgradeable.sol";
import {L1cmETH} from "../../src/L1cmETH.sol";
import {L1cmETHAdapter} from "../../src/L1cmETHAdapter.sol";
import {L1MessagingStatus} from "../../src/L1MessagingStatus.sol";
import {L2cmETH} from "../../src/L2cmETH.sol";
import {L2MessagingStatus} from "../../src/L2MessagingStatus.sol";

// EmptyContract serves as a dud implementation for the proxy, which lets us point
// to something and deploy the proxy before we deploy the implementation.
// This helps avoid the cyclic dependencies in init.
contract EmptyContract {}

struct L1Deployments {
    L1cmETH l1cmETH;
    L1cmETHAdapter l1Adaptor;
    L1MessagingStatus l1MessagingStatus;
}

struct L2Deployments {
    L2cmETH l2cmETH;
    L2MessagingStatus l2MessagingStatus;
}

/// @notice Deployment paramaters for the protocol contract
struct L1DeploymentParams {
    address admin;
    address owner;
    address delegate;
    address upgrader;
    address manager;
    address l1endpoint;
    string name;
    string symbol;

    // L1cmETH setup
    address minter;
    address burner;
    uint256 maxSupply;

    // L1MessagingStatus setup
    address pauser;
    address unpauser;

    address blocklist;
    address sanctionList;
}

struct L2DeploymentParams {
    address admin;
    address owner;
    address delegate;
    address upgrader;
    address manager;
    address l2endpoint;
    string name;
    string symbol;

    // L2MessagingStatus setup
    address pauser;
    address unpauser;
}

function deployL1(L1DeploymentParams memory params) returns (L1Deployments memory) {
    return deployL1(params, msg.sender);
}

function deployL2(L2DeploymentParams memory params) returns (L2Deployments memory) {
    return deployL2(params, msg.sender);
}

/// @notice Deploys all proxy and implementation contract, initializes them and returns a struct containing all the
/// addresses.
/// @dev All upgradeable contracts are deployed using the transparent proxy pattern, with the proxy admin being a
/// timelock controller with `params.upgrader` as proposer and executor, and `params.admin` as timelock admin.
/// The `deployer` will be added as admin, proposer and executer for the duration of the deployment. The permissions are
/// renounced accordingly at the end of the deployment.
/// @param params the configuration to use for the deployment.
/// @param deployer the address executing this function. While this will always be `msg.sender` in deployement scripts,
/// it will need to be set in tests as `prank`s will not affect `msg.sender` in free functions.
function deployL1(L1DeploymentParams memory params, address deployer) returns (L1Deployments memory) {

    // Create empty contract for proxy pointer
    EmptyContract empty = new EmptyContract();
    // Create proxies for all contracts
    L1Deployments memory ds = L1Deployments({
        l1cmETH: L1cmETH(payable(address(newProxy(empty, deployer)))),
        l1Adaptor: L1cmETHAdapter(payable(address(newProxy(empty, deployer)))),
        l1MessagingStatus: L1MessagingStatus(payable(address(newProxy(empty, deployer))))
    });
    console.log("Implementations: ");
    // Upgrade and initialize contracts
    ds.l1cmETH = initL1cmETH(
        ITransparentUpgradeableProxy(address(ds.l1cmETH)),
        L1cmETH.Init({
            admin: params.admin,
            manager: params.manager,
            minter: params.minter,
            burner: params.burner,
            status: address(ds.l1MessagingStatus),
            name: params.name,
            symbol: params.symbol,
            maxSupply: params.maxSupply,
            blocklist: params.blocklist,
            sanctionList: params.sanctionList
        })
    );
    ds.l1Adaptor = initL1cmETHAdaptor(
        ITransparentUpgradeableProxy(address(ds.l1Adaptor)),
        L1cmETHAdapter.Init({
            delegate: params.delegate,
            owner: params.owner
        }),
        address(ds.l1cmETH),
        params.l1endpoint
    );
    ds.l1MessagingStatus = initL1MessagingStatus(
        ITransparentUpgradeableProxy(address(ds.l1MessagingStatus)),
        L1MessagingStatus.Init({
            admin: params.admin,
            owner: params.owner,
            pauser: params.pauser,
            unpauser: params.unpauser,
            manager: params.manager
        }),
        params.l1endpoint
    );

    // Renounce all roles, now that we have deployed everything
    // Keep roles only if the deployer was also set as admin or upgrader, repspectively.
    if (deployer != params.upgrader) {
        TransparentUpgradeableProxy(payable(address(ds.l1cmETH))).changeAdmin(params.upgrader);
        TransparentUpgradeableProxy(payable(address(ds.l1Adaptor))).changeAdmin(params.upgrader);
        TransparentUpgradeableProxy(payable(address(ds.l1MessagingStatus))).changeAdmin(params.upgrader);
    }

    return ds;
}

/// @notice Deploys all proxy and implementation contract, initializes them and returns a struct containing all the
/// addresses.
/// @dev All upgradeable contracts are deployed using the transparent proxy pattern, with the proxy admin being a
/// timelock controller with `params.upgrader` as proposer and executor, and `params.admin` as timelock admin.
/// The `deployer` will be added as admin, proposer and executer for the duration of the deployment. The permissions are
/// renounced accordingly at the end of the deployment.
/// @param params the configuration to use for the deployment.
/// @param deployer the address executing this function. While this will always be `msg.sender` in deployement scripts,
/// it will need to be set in tests as `prank`s will not affect `msg.sender` in free functions.
function deployL2(L2DeploymentParams memory params, address deployer) returns (L2Deployments memory) {
    // Create empty contract for proxy pointer
    EmptyContract empty = new EmptyContract();
    // Create proxies for all contracts
    L2Deployments memory ds = L2Deployments({
        l2cmETH: L2cmETH(payable(address(newProxy(empty, deployer)))),
        l2MessagingStatus: L2MessagingStatus(payable(address(newProxy(empty, deployer))))
    });
    console.log("Implementations: ");
    // Upgrade and iniitialize contracts
    ds.l2cmETH = initL2cmETH(
        ITransparentUpgradeableProxy(address(ds.l2cmETH)),
        L2cmETH.Init({
            admin: params.admin,
            owner: params.owner,
            delegate: params.delegate,
            manager: params.manager,
            status: address(ds.l2MessagingStatus),
            name: params.name,
            symbol: params.symbol
        }),
        params.l2endpoint
    );
    ds.l2MessagingStatus = initL2MessagingStatus(
        ITransparentUpgradeableProxy(address(ds.l2MessagingStatus)),
        L2MessagingStatus.Init({
            admin: params.admin,
            owner: params.owner,
            pauser: params.pauser,
            unpauser: params.unpauser,
            manager: params.manager
        }),
        params.l2endpoint
    );

    // Renounce all roles, now that we have deployed everything
    // Keep roles only if the deployer was also set as admin or upgrader, repspectively.
    if (deployer != params.upgrader) {
        TransparentUpgradeableProxy(payable(address(ds.l2cmETH))).changeAdmin(params.upgrader);
        TransparentUpgradeableProxy(payable(address(ds.l2MessagingStatus))).changeAdmin(params.upgrader);
    }

    return ds;
}

function newProxy(EmptyContract empty, address deployer) returns (TransparentUpgradeableProxy) {
    return new TransparentUpgradeableProxy(address(empty), address(deployer), "");
}

function upgradeToAndCall(
    ITransparentUpgradeableProxy proxy,
    address implementation,
    uint256 value,
    bytes memory data
) {
    proxy.upgradeToAndCall{value: value}(implementation, data);
}

function upgradeToAndCall(
    ITransparentUpgradeableProxy proxy,
    address implementation,
    bytes memory data
) {
    upgradeToAndCall(proxy, implementation, 0, data);
}

function initL1cmETH(
    ITransparentUpgradeableProxy proxy,
    L1cmETH.Init memory init
) returns (L1cmETH) {
    L1cmETH impl = new L1cmETH();
    console.log("L1cmETH Impl:", address(impl));
    upgradeToAndCall(proxy, address(impl), abi.encodeCall(L1cmETH.initialize, init));
    return L1cmETH(payable(address(proxy)));
}

function initL1cmETHAdaptor(
    ITransparentUpgradeableProxy proxy,
    L1cmETHAdapter.Init memory init,
    address token,
    address endpoint
) returns (L1cmETHAdapter) {
    L1cmETHAdapter impl = new L1cmETHAdapter(token, endpoint);
    console.log("L1cmETHAdapter Impl:", address(impl));
    upgradeToAndCall(proxy, address(impl), abi.encodeCall(L1cmETHAdapter.initialize, init));
    return L1cmETHAdapter(payable(address(proxy)));
}

function initL1MessagingStatus(
    ITransparentUpgradeableProxy proxy,
    L1MessagingStatus.Init memory init,
    address endpoint
) returns (L1MessagingStatus) {
    L1MessagingStatus impl = new L1MessagingStatus(endpoint);
    console.log("L1MessagingStatus Impl:", address(impl));
    upgradeToAndCall(proxy, address(impl), abi.encodeCall(L1MessagingStatus.initialize, init));
    return L1MessagingStatus(payable(address(proxy)));
}

function initL2cmETH(
    ITransparentUpgradeableProxy proxy,
    L2cmETH.Init memory init,
    address endpoint
) returns (L2cmETH) {
    L2cmETH impl = new L2cmETH(endpoint);
    console.log("L2cmETH Impl:", address(impl));
    upgradeToAndCall(proxy, address(impl), abi.encodeCall(L2cmETH.initialize, init));
    return L2cmETH(address(proxy));
}

function initL2MessagingStatus(
    ITransparentUpgradeableProxy proxy,
    L2MessagingStatus.Init memory init,
    address endpoint
) returns (L2MessagingStatus) {
    L2MessagingStatus impl = new L2MessagingStatus(endpoint);
    console.log("L2MessagingStatus Impl:", address(impl));
    upgradeToAndCall(proxy, address(impl), abi.encodeCall(L2MessagingStatus.initialize, init));
    return L2MessagingStatus(payable(address(proxy)));
}

function grantAndRenounce(AccessControlUpgradeable controllable, bytes32 role, address sender, address newAccount) {
    grantAndRenounce(AccessControl(address(controllable)), role, sender, newAccount);
}

function grantAndRenounce(AccessControl controllable, bytes32 role, address sender, address newAccount) {
    // To prevent reassigning to self and renouncing later leaving the role empty
    if (sender != newAccount) {
        controllable.grantRole(role, newAccount);
        controllable.renounceRole(role, sender);
    }
}

function grantRole(AccessControlUpgradeable controllable, bytes32 role, address newAccount) {
    grantRole(AccessControl(address(controllable)), role, newAccount);
}

function grantRole(AccessControl controllable, bytes32 role, address newAccount) {
    controllable.grantRole(role, newAccount);
}
