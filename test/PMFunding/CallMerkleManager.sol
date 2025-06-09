// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@forge-std/Base.sol";
import "@forge-std/console.sol";
import {ManagerWithMerkleVerification} from "roles/ManagerWithMerkleVerification.sol";
import "./MerkleVerify.sol";

contract CallMerkleManager is CommonBase {
    struct ManageLeaf {
        address DecoderAndSanitizerAddress;
        bytes4 FunctionSelector;
        bytes32 LeafDigest;
        address TargetAddress;
        bytes PackedArgumentAddresses;
    }

    ManagerWithMerkleVerification public merkleManager = ManagerWithMerkleVerification(0xAEC02407cBC7Deb67ab1bbe4B0d49De764878bCE);
    address public strategist = 0x3370bEAc97d1654e03674Aab1B89668237ba320E;
    string public file = vm.readFile('./leafs/StrategistLeafs.json');
    // @notice the tree deep without root
    uint public levelLength = 6;

    // @param data is the call data without selector
    function _callMerkleManager(address target, string memory FunctionSignature, address[] memory argumentAddress, bytes memory data) internal {
        bytes32[][] memory proof = new bytes32[][](1);
        address[] memory decodersAndSanitizers = new address[](1);
        address[] memory targets = new address[](1);
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
        targets[0] = selectedLeaf.TargetAddress;
        targetData[0] = abi.encodePacked(selector, data);
        values[0] = 0;

        vm.prank(strategist);
        merkleManager.manageVaultWithMerkleVerification(proof, decodersAndSanitizers, targets, targetData, values);
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
