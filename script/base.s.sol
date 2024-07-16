// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {L1Deployments, L2Deployments} from "./helpers/Proxy.sol";
import {L1ProxyAdminDeployments, L2ProxyAdminDeployments} from "./helpers/ProxyAdminProxy.sol";

contract Base is Script {

    function setUp() public virtual {
        require(vm.envUint("CHAIN_ID") == block.chainid, "wrong chain id");
    }

    function _deploymentsFile() internal view returns (string memory) {
        string memory root = vm.projectRoot();
        return string.concat(root, "/deployments/", vm.toString(block.chainid));
    }

    function writeL1Deployments(L1Deployments memory deps) public {
        vm.writeFileBinary(_deploymentsFile(), abi.encode(deps));
    }

    function writeL2Deployments(L2Deployments memory deps) public {
        vm.writeFileBinary(_deploymentsFile(), abi.encode(deps));
    }

    function readL1Deployments() public view returns (L1Deployments memory) {
        bytes memory data = vm.readFileBinary(_deploymentsFile());
        L1Deployments memory depls = abi.decode(data, (L1Deployments));

        require(address(depls.l1cmETH).code.length > 0, "contracts are not deployed yet");
        require(address(depls.l1MessagingStatus).code.length > 0, "contracts are not deployed yet");
        return depls;
    }

    function readL2Deployments() public view returns (L2Deployments memory) {
        bytes memory data = vm.readFileBinary(_deploymentsFile());
        L2Deployments memory depls = abi.decode(data, (L2Deployments));

        require(address(depls.l2cmETH).code.length > 0, "contracts are not deployed yet");
        require(address(depls.l2MessagingStatus).code.length > 0, "contracts are not deployed yet");
        return depls;
    }

    function readL1ProxyAdminDeployments() public view returns (L1ProxyAdminDeployments memory) {
        bytes memory data = vm.readFileBinary(_deploymentsFile());
        L1ProxyAdminDeployments memory depls = abi.decode(data, (L1ProxyAdminDeployments));

        require(address(depls.l1cmETH).code.length > 0, "contracts are not deployed yet");
        require(address(depls.l1MessagingStatus).code.length > 0, "contracts are not deployed yet");
        return depls;
    }

    function readL2ProxyAdminDeployments() public view returns (L2ProxyAdminDeployments memory) {
        bytes memory data = vm.readFileBinary(_deploymentsFile());
        L2ProxyAdminDeployments memory depls = abi.decode(data, (L2ProxyAdminDeployments));

        require(address(depls.l2cmETH).code.length > 0, "contracts are not deployed yet");
        require(address(depls.l2MessagingStatus).code.length > 0, "contracts are not deployed yet");
        return depls;
    }
}
