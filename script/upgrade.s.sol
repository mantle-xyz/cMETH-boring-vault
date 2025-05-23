// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
/* solhint-disable no-console */

import {TimelockController} from "openzeppelin/governance/TimelockController.sol";
import {ITransparentUpgradeableProxy} from "src/lib/TransparentUpgradeableProxy.sol";

import {L1Deployments, L2Deployments, upgradeToAndCall} from "./helpers/Proxy.sol";
import {L1cmETH} from "../src/L1cmETH.sol";
import {L1cmETHAdapter} from "../src/L1cmETHAdapter.sol";
import {L1MessagingStatus} from "../src/L1MessagingStatus.sol";
import {L2cmETH} from "../src/L2cmETH.sol";
import {L2MessagingStatus} from "../src/L2MessagingStatus.sol";
import {ScriptBase} from "forge-std/Base.sol";
import {Base} from "./base.s.sol";

import {console2 as console} from "forge-std/console2.sol";

contract CalldataPrinter is ScriptBase {
    string private _name;
    mapping(bytes4 => string) private _selectorNames;

    constructor(string memory name) {
        _name = name;
    }

    function setSelectorName(bytes4 selector, string memory name) external {
        _selectorNames[selector] = name;
    }

    fallback() external {
        console.log("Calldata to %s [%s]:", _name, _selectorNames[bytes4(msg.data[:4])]);
        console.logBytes(msg.data);
    }
}

contract Upgrade is Base {
    /// @dev Deploys a new implementation contract for a given contract name and returns its proxy address with its new
    /// implementation address.
    /// @param contractName The name of the contract to deploy as implementation.
    /// @return L1 / L2 The index of the network new proxy contract belongs to.
    /// @return proxyAddr The address of the new proxy contract.
    /// @return implAddress The address of the new implementation contract.
    function _deployImplementation(string memory contractName, address token, address l1endpoint, address l2endpoint) internal returns (uint256, address, address) {
        L1Deployments memory l1depls = readL1Deployments();
        L2Deployments memory l2depls = readL2Deployments();

        if (keccak256(bytes(contractName)) == keccak256("L1cmETH")) {
            L1cmETH impl = new L1cmETH();
            return (1, address(l1depls.l1cmETH), address(impl));
        }
        if (keccak256(bytes(contractName)) == keccak256("L1cmETHAdapter")) {
            L1cmETHAdapter impl = new L1cmETHAdapter(token, l1endpoint);
            return (1, address(l1depls.l1Adaptor), address(impl));
        }
        if (keccak256(bytes(contractName)) == keccak256("L1MessagingStatus")) {
            L1MessagingStatus impl = new L1MessagingStatus(l1endpoint);
            return (1, address(l1depls.l1MessagingStatus), address(impl));
        }
        if (keccak256(bytes(contractName)) == keccak256("L2cmETH")) {
            L2cmETH impl = new L2cmETH(l2endpoint);
            return (2, address(l2depls.l2cmETH), address(impl));
        }
        if (keccak256(bytes(contractName)) == keccak256("L2MessagingStatus")) {
            L2MessagingStatus impl = new L2MessagingStatus(l2endpoint);
            return (2, address(l2depls.l2MessagingStatus), address(impl));
        }
        revert("Uknown contract");
    }

    function upgrade(string memory contractName, bool shouldExecute, address token, address l1endpoint, address l2endpoint) public {
        L1Deployments memory l1depls = readL1Deployments();
        L2Deployments memory l2depls = readL2Deployments();

        vm.startBroadcast();
        (uint256 layer, address proxyAddr, address implAddress) = _deployImplementation(contractName, token, l1endpoint, l2endpoint);
        vm.stopBroadcast();

        bytes memory callData = abi.encodeCall(ITransparentUpgradeableProxy.upgradeToAndCall, (implAddress, ""));

        console.log("=============================");
        console.log("Onchain addresses");
        console.log("=============================");
        console.log(string.concat(contractName, " address (proxy):"));
        console.log(proxyAddr);
        console.log("New implementation address:");
        console.log(implAddress);
        console.log();

        if (shouldExecute) {
            console.log("=============================");
            console.log("SUBMITTING UPGRADE TX ONCHAIN");
            console.log("=============================");
            vm.startBroadcast();
        } else {
            console.log("=============================");
            console.log("REQUESTED NOT TO EXECUTE");
            console.log("MUST CALL PROXY ADMIN WITH CALLDATA");
            console.log("=============================");
            console.log("Proxy:");
            console.log(proxyAddr);
            console.log("Calldata to Proxy:");
            console.logBytes(callData);
            CalldataPrinter printer = new CalldataPrinter("ProxyAdmin");
            printer.setSelectorName(ITransparentUpgradeableProxy.upgradeToAndCall.selector, "upgradeToAndCall");

            proxyAddr = address(printer);
        }

        // Run the upgrade.
        upgradeToAndCall(ITransparentUpgradeableProxy(proxyAddr), implAddress, 0, callData);
    }
}
