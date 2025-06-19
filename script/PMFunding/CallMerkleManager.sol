// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@forge-std/Base.sol";
import "mantle-cdk/lib/safe-contracts/contracts/Safe.sol";
import {Config} from "mantle-cdk/script/libraries/Config.sol";
import {ManagerWithMerkleVerification} from "roles/ManagerWithMerkleVerification.sol";
import {PMConfig} from "./PMConfig.sol";
import {DeployBase} from "mantle-cdk/script/DeployBase.sol";
import {console} from "@forge-std/console.sol";

contract CallMerkleManager is PMConfig, DeployBase {
    struct ManageLeaf {
        address DecoderAndSanitizerAddress;
        bytes4 FunctionSelector;
        bytes32 LeafDigest;
        address TargetAddress;
        bytes PackedArgumentAddresses;
    }

    ManagerWithMerkleVerification public merkleManager;
    Safe public safe_;
    string public file = vm.readFile('./leafs/StrategistLeafs.json');
    // @notice the tree deep without root
    uint public levelLength = 6;

    function setUp() public virtual override {
        read(Config.deployConfigPath());
        merkleManager = ManagerWithMerkleVerification(merkleManagerAddress);
        safe_ = Safe(payable(deployerSafeAddress));
    }
    function encodeManageVaultWithMerkleVerification(address[] memory _targets, string[] memory functionSignature, address[][] memory argumentAddress, bytes[] memory data) internal {
        uint256 length = _targets.length;
        bytes32[][] memory proof = new bytes32[][](length);
        address[] memory decodersAndSanitizers = new address[](length);
        address[] memory targetAddresses = new address[](length);
        bytes[] memory targetData = new bytes[](length);
        uint256[] memory values = new uint[](length);

        for (uint256 i; i < length; ++i) {
            (proof[i], decodersAndSanitizers[i], targetAddresses[i], targetData[i], values[i]) = _getManagerParams(_targets[i], functionSignature[i], argumentAddress[i], data[i]);
        }

        bytes memory callData = abi.encodeWithSelector(
            ManagerWithMerkleVerification.manageVaultWithMerkleVerification.selector,
            proof,
            decodersAndSanitizers,
            targetAddresses,
            targetData,
            values
        );
        console.logString("tx calldata: ");
        console.logBytes(callData);
    }

    // @param data is the call data without selector
    function _getManagerParams(address target, string memory functionSignature, address[] memory argumentAddress, bytes memory data) internal returns (bytes32[] memory proof, address decodersAndSanitizers, address targetAddress, bytes memory targetData, uint values) {

        bytes4 selector = bytes4(keccak256(bytes(functionSignature)));
        bytes memory packedData;
        for (uint256 j; j < argumentAddress.length; ++j) {
            packedData = abi.encodePacked(packedData, argumentAddress[j]);
        }
        ManageLeaf memory selectedLeaf = _getLeaf(target, selector, packedData);

        proof = _getProof(selectedLeaf.LeafDigest);
        decodersAndSanitizers = selectedLeaf.DecoderAndSanitizerAddress;
        targetAddress = selectedLeaf.TargetAddress;
        targetData = abi.encodePacked(selector, data);
        values = 0;
    }

    // @param data is the call data without selector
    function _callMerkleManager(address target, string memory FunctionSignature, address[] memory argumentAddress, bytes memory data) internal {
        bytes32[][] memory proof = new bytes32[][](1);
        address[] memory decodersAndSanitizers = new address[](1);
        address[] memory targetAddresses = new address[](1);
        bytes[] memory targetData = new bytes[](1);
        uint256[] memory values = new uint[](1);

        bytes4 selector = bytes4(keccak256(bytes(FunctionSignature)));
        bytes memory packedData;
        for (uint256 j; j < argumentAddress.length; ++j) {
            packedData = abi.encodePacked(packedData, argumentAddress[j]);
        }
        ManageLeaf memory selectedLeaf = _getLeaf(target, selector, packedData);

        proof[0] = _getProof(selectedLeaf.LeafDigest);
        decodersAndSanitizers[0] = selectedLeaf.DecoderAndSanitizerAddress;
        targetAddresses[0] = selectedLeaf.TargetAddress;
        targetData[0] = abi.encodePacked(selector, data);
        values[0] = 0;

//        merkleManager.manageVaultWithMerkleVerification(proof, decodersAndSanitizers, targetAddresses, targetData, values);
        bytes memory meta = abi.encodeWithSelector(
            ManagerWithMerkleVerification.manageVaultWithMerkleVerification.selector,
            proof,
            decodersAndSanitizers,
            targetAddresses,
            targetData,
            values
        );
        console.logString("tx calldata: ");
        console.logBytes(meta);
        _addToBatch(safe_, merkleManagerAddress, 0, meta);
    }

    function _getLeaf(address target, bytes4 selector, bytes memory addressArguments) internal view returns(ManageLeaf memory) {
        bytes memory capacityInBytes = vm.parseJson(file, ".metadata.TreeCapacity");
        uint capacity = abi.decode(capacityInBytes, (uint));
        ManageLeaf[] memory leafs = new ManageLeaf[](capacity);
        for(uint i; i < capacity; i++) {
            bytes memory decoderInBytes = vm.parseJson(file, string.concat(".leafs[", vm.toString(i), "].DecoderAndSanitizerAddress"));
            leafs[i].DecoderAndSanitizerAddress = abi.decode(decoderInBytes, (address));
            bytes memory selectorInBytes = vm.parseJson(file, string.concat(".leafs[", vm.toString(i), "].FunctionSelector"));
            leafs[i].FunctionSelector = bytes4(abi.decode(selectorInBytes, (bytes)));
            bytes memory leafDigestInBytes = vm.parseJson(file, string.concat(".leafs[", vm.toString(i), "].LeafDigest"));
            leafs[i].LeafDigest = abi.decode(leafDigestInBytes, (bytes32));
            bytes memory targetInBytes = vm.parseJson(file, string.concat(".leafs[", vm.toString(i), "].TargetAddress"));
            leafs[i].TargetAddress = abi.decode(targetInBytes, (address));
            leafs[i].PackedArgumentAddresses = vm.parseJsonBytes(file, string.concat(".leafs[", vm.toString(i), "].PackedArgumentAddresses"));
        }

        for(uint i; i < leafs.length; i++) {
            ManageLeaf memory leaf = leafs[i];
            if(leaf.TargetAddress == target && leaf.FunctionSelector == selector && keccak256(leaf.PackedArgumentAddresses) == keccak256(addressArguments)) {
                return leaf;
            }
        }
        revert("leaf doesn't match");
    }

    function _getProof(bytes32 leafDigest) internal view returns (bytes32[] memory proof) {
        bytes32[][] memory tree = _getTree();
        proof = new bytes32[](tree.length);
        for(uint i; i < tree.length; i++) {
            bytes32[] memory level = tree[i];
            for(uint j; j < level.length; j++) {
                if(leafDigest == level[j]) {
                    proof[i] = j % 2 == 0 ? level[j + 1] : level[j - 1];
                    leafDigest = _hashPair(leafDigest, proof[i]);
                    break;
                }
            }
        }
    }

    function _getTree() internal view returns(bytes32[][] memory tree) {
        tree = new bytes32[][](levelLength);

        for(uint i; i < levelLength; i++) {
            uint treeIndex = levelLength - i;
            bytes memory levelInBytes = vm.parseJson(file, string.concat(".MerkleTree.", vm.toString(treeIndex)));
            bytes32[] memory level = abi.decode(levelInBytes, (bytes32[]));
            tree[i] = level;
        }
    }

    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }

    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        /// @solidity memory-safe-assembly
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }



}

//0a9059cbb
//0000000000000000000000000000000000000000000000000000000000000020
//0000000000000000000000000000000000000000000000000000000000000040
//0000000000000000000000000b5d15445b715bf117ba0482b7a9f772af46d93a
//0000000000000000000000000000000000000000000000000de0b6b3a7640000
