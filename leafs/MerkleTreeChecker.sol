// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

contract MerkleTreeLeafChecker {
    /**
     * @notice Allows caller to verify the pre-image of a BoringVault Merkle Leaf.
     * @param ExpectedLeafDigest the expected leaf digest to compare against
     * @param DecoderAndSanitizerAddress the address of the decoder and sanitizer
     * @param TargetAddress the address of the target
     * @param CanSendValue a bool indicating whether or not the call can be made with value
     * @param FunctionSignature the function signature as a string
     * @param AddressArguments an array of sensitive arguments passed into the calls call data
     * @return bool Returns true if the calculated leaf digest matches the expected digest, false otherwise
     */
    function checkLeaf(
        bytes32 ExpectedLeafDigest,
        address DecoderAndSanitizerAddress,
        address TargetAddress,
        bool CanSendValue,
        string calldata FunctionSignature,
        address[] calldata AddressArguments
    ) external pure returns (bool) {
        bytes4 FunctionSelector = bytes4(keccak256(bytes(FunctionSignature)));
        bytes memory rawDigest = abi.encodePacked(DecoderAndSanitizerAddress, TargetAddress, CanSendValue, FunctionSelector);
        uint256 AddressArgumentsLength = AddressArguments.length;
        for (uint256 i; i < AddressArgumentsLength; ++i) {
            rawDigest = abi.encodePacked(rawDigest, AddressArguments[i]);
        }
        bytes32 calculatedLeafDigest = keccak256(rawDigest);
        return calculatedLeafDigest == ExpectedLeafDigest;
    }

    /**
     * @notice Generates and compares the Merkle root from an array of leaf digests.
     * @param leafDigestsHex The array of leaf digests as hex strings to generate the Merkle root from.
     * @param expectedRoot The expected Merkle root to compare with.
     * @param LeafCount The number of leaf digests.
     * @param TreeCapacity The capacity of the Merkle tree.
     * @return bool Returns true if the generated Merkle root matches the expected root, false otherwise.
     */
    function compareMerkleRoot(
        string[] calldata leafDigestsHex,
        bytes32 expectedRoot,
        uint256 LeafCount,
        uint256 TreeCapacity
    ) external pure returns (bool) {
        require(leafDigestsHex.length == TreeCapacity, "Leaf count mismatch");
        require(TreeCapacity >= LeafCount, "Tree capacity must be greater than or equal to leaf count");

        bytes32[] memory leafDigests = new bytes32[](TreeCapacity);
        
        for (uint256 i = 0; i < TreeCapacity; i++) {
            if (i < LeafCount) {
                leafDigests[i] = hexStringToBytes32(leafDigestsHex[i]);
            } else {
                // Pad with the specified value if necessary
                leafDigests[i] = 0xa7a0fd846665d92e66be6155c6221b3acd7145ca7c4e4b67a594e4c516969400;
            }
        }

        bytes32 generatedRoot = generateMerkleRoot(leafDigests);
        return generatedRoot == expectedRoot;
    }

    /**
     * @notice Generates the Merkle root from an array of leaf digests.
     * @param leafDigests The array of leaf digests to generate the Merkle root from.
     * @return bytes32 The generated Merkle root.
     */
    function generateMerkleRoot(bytes32[] memory leafDigests) internal pure returns (bytes32) {
        if (leafDigests.length == 0) {
            return bytes32(0);
        }

        uint256 leafsLength = leafDigests.length;
        uint256 layers = leafsLength;
        bytes32[] memory layersArray = new bytes32[](layers);

        for (uint256 i = 0; i < leafsLength; i++) {
            layersArray[i] = leafDigests[i];
        }

        uint256 layerIndex = 0;
        while (layers > 1) {
            bytes32[] memory nextLayer = new bytes32[]((layers + 1) / 2);
            for (uint256 i = 0; i < layers; i += 2) {
                if (i + 1 < layers) {
                    bytes32 left = layersArray[i];
                    bytes32 right = layersArray[i + 1];
                    
                    // Compare left and right branches
                    if (left > right) {
                        // Swap if left is less than right
                        (left, right) = (right, left);
                    }
                    
                    nextLayer[i / 2] = keccak256(abi.encodePacked(left, right));
                } else {
                    nextLayer[i / 2] = layersArray[i];
                }
            }
            layersArray = nextLayer;
            layers = (layers + 1) / 2;
            layerIndex++;
        }

        return layersArray[0];
    }

    // Helper function to convert bytes32 to hex string
    function toHexString(bytes32 value) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(66);
        str[0] = '0';
        str[1] = 'x';
        for (uint256 i = 0; i < 32; i++) {
            str[2+i*2] = alphabet[uint8(value[i] >> 4)];
            str[3+i*2] = alphabet[uint8(value[i] & 0x0f)];
        }
        return string(str);
    }

    function hexStringToBytes32(string memory hexString) internal pure returns (bytes32) {
        require(bytes(hexString).length == 66, "Invalid hex string length"); // "0x" + 64 hex characters
        require(bytes(hexString)[0] == '0' && bytes(hexString)[1] == 'x', "Hex string must start with 0x");
        
        bytes32 result;
        for (uint i = 2; i < 66; i++) {
            result = result << 4;
            uint8 digit = uint8(bytes(hexString)[i]);
            if (digit >= 48 && digit <= 57) {
                result |= bytes32(uint256(digit - 48));
            } else if (digit >= 65 && digit <= 70) {
                result |= bytes32(uint256(digit - 55));
            } else if (digit >= 97 && digit <= 102) {
                result |= bytes32(uint256(digit - 87));
            } else {
                revert("Invalid hex character");
            }
        }
        return result;
    }
}
