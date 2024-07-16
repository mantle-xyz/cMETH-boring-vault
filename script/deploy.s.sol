// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
/* solhint-disable no-console */

import {deployL1, deployL2, L1Deployments, L2Deployments, L1DeploymentParams, L2DeploymentParams} from "./helpers/Proxy.sol";
import {console2 as console} from "forge-std/console2.sol";
import {Base} from "./base.s.sol";

contract Deploy is Base {
    function _readL1DeploymentParamsFromEnv() internal view returns (L1DeploymentParams memory) {
        return L1DeploymentParams({
            admin: vm.envAddress("ADMIN_ADDRESS"),
            owner: vm.envAddress("OWNER_ADDRESS"),
            delegate : vm.envAddress("DELEGATE_ADDRESS"),
            upgrader: vm.envAddress("UPGRADER_ADDRESS"),
            manager: vm.envAddress("MANAGER_ADDRESS"),
            l1endpoint: vm.envAddress("L1_ENDPOINT"),
            name: vm.envString("NAME"),
            symbol: vm.envString("SYMBOL"),

            // cmETH setup
            minter: vm.envAddress("MINTER_ADDRESS"),
            burner: vm.envAddress("BURNER_ADDRESS"),
            maxSupply: vm.envUint("MAX_SUPPLY"),

            // messaging setup
            pauser: vm.envAddress("PAUSER_ADDRESS"),
            unpauser: vm.envAddress("UNPAUSER_ADDRESS"),

            blocklist: vm.envAddress("BLOCK_LIST_ADDRESS"),
            sanctionList: vm.envAddress("SANCTION_LIST_ADDRESS")
        });
    }

    function _readL2DeploymentParamsFromEnv() internal view returns (L2DeploymentParams memory) {
        return L2DeploymentParams({
            admin: vm.envAddress("ADMIN_ADDRESS"),
            owner: vm.envAddress("OWNER_ADDRESS"),
            delegate: vm.envAddress("DELEGATE_ADDRESS"),
            upgrader: vm.envAddress("UPGRADER_ADDRESS"),
            manager: vm.envAddress("MANAGER_ADDRESS"),
            l2endpoint: vm.envAddress("L2_ENDPOINT"),
            name: vm.envString("NAME"),
            symbol: vm.envString("SYMBOL"),

            // messaging setup
            pauser: vm.envAddress("PAUSER_ADDRESS"),
            unpauser: vm.envAddress("UNPAUSER_ADDRESS")
        });
    }

    function deployL1Contracts() public {
        L1DeploymentParams memory params = _readL1DeploymentParamsFromEnv();
        vm.startBroadcast();
        L1Deployments memory deps = deployL1(params);
        vm.stopBroadcast();

        logL1Deployments(deps);
        writeL1Deployments(deps);
    }

    function deployL2Contracts() public {
        L2DeploymentParams memory params = _readL2DeploymentParamsFromEnv();
        vm.startBroadcast();
        L2Deployments memory deps = deployL2(params);
        vm.stopBroadcast();

        logL2Deployments(deps);
        writeL2Deployments(deps);
    }

    function logL1Deployments(L1Deployments memory deps) public pure {
        console.log("Deployments:");
        console.log("L1cmETH: %s", address(deps.l1cmETH));
        console.log("L1cmETHAdapter: %s", address(deps.l1Adaptor));
        console.log("L1MessagingStatus: %s", address(deps.l1MessagingStatus));
    }

    function logL2Deployments(L2Deployments memory deps) public pure {
        console.log("Deployments:");
        console.log("L2cmETH: %s", address(deps.l2cmETH));
        console.log("L2MessagingStatus: %s", address(deps.l2MessagingStatus));
    }
}
