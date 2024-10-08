// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../leafs/MerkleTreeChecker.sol";
import {console2 as console} from "forge-std/console2.sol";

contract MerkleTreeCheckerTest is Test {
    MerkleTreeLeafChecker public checker;

    function setUp() public {
        checker = new MerkleTreeLeafChecker();
    }

    function testCheckLeaf() view public {
        bytes32 expectedLeafDigest = 0xc3892bdba3085c7fb31235e643842479e023bf9f2db430ef0fcd368811c54ab5;
        address DecoderAndSanitizerAddress = 0x31b6f06F2c12bd288ad6aaD7073f21CB57349F74;
        address TargetAddress = 0xd5F7838F5C461fefF7FE49ea5ebaF7728bB0ADfa;
        bool CanSendValue = false;
        string memory FunctionSignature = "transfer(address,uint256)";
        address[] memory AddressArguments = new address[](1);
        AddressArguments[0] = 0x12Be34bE067Ebd201f6eAf78a861D90b2a66B113;

        bool result = checker.checkLeaf(
            expectedLeafDigest,
            DecoderAndSanitizerAddress,
            TargetAddress,
            CanSendValue,
            FunctionSignature,
            AddressArguments
        );

        assertTrue(result, "Leaf check should return true for valid input");

        // Verify the leaf check is deterministic
        bool result2 = checker.checkLeaf(
            expectedLeafDigest,
            DecoderAndSanitizerAddress,
            TargetAddress,
            CanSendValue,
            FunctionSignature,
            AddressArguments
        );
        assertEq(result, result2, "Leaf check results should be equal for the same input");

        // Optional: Test with invalid input to ensure it returns false
        bool invalidResult = checker.checkLeaf(
            expectedLeafDigest,
            address(0), // Invalid address
            TargetAddress,
            CanSendValue,
            FunctionSignature,
            AddressArguments
        );
        assertFalse(invalidResult, "Leaf check should return false for invalid input");
    }

    function testCompareMerkleRoot() view public {
        // Create the sample leaf digests array as hex strings
        string[] memory leafDigestsHex = new string[](32);
        leafDigestsHex[0] = "0xc3892bdba3085c7fb31235e643842479e023bf9f2db430ef0fcd368811c54ab5";
        leafDigestsHex[1] = "0x0505e01e7b06888815b87ac3c955c43d973dd07b1e431b57718f86fa33ced5ea";
        leafDigestsHex[2] = "0x76885c302ea2207398648df223d978abe5834492b13a8a51d42462a97628e91d";
        leafDigestsHex[3] = "0x55a8e20dbe2968b6d74b5de3ff829efe5e7f6de2be0a36fabf2f2cde8ea08c45";
        leafDigestsHex[4] = "0xc5c46658f5b1bea69f149a74549658451986327a6a9c901692465c35f67f7cb9";
        leafDigestsHex[5] = "0x12fd9b58d8d03cf5daf0c98e4dc88ddbbbf51eb9221af68c7ee9af64ce9b00a3";
        leafDigestsHex[6] = "0x07c5002ba84eee390e3bbbbe54e56c224532d27c83cc320d68556e1f0bde6078";
        leafDigestsHex[7] = "0x79593ba6ef9b5dae3ebc1a037825faf1a17875a322046cd23babe9c61dd42522";
        leafDigestsHex[8] = "0x1c29e4b985d548464c0694e06b07757b9e141f3907aec24c647073a3855393ea";
        leafDigestsHex[9] = "0x9e7447768d98ac97569afe1796a027c9fa9fe30c8ff21fb311a8cc076725937f";
        leafDigestsHex[10] = "0xe2e0f074f41ae0c7f072053a8ed8930b60cd521903c42d5eb52ff052e3426ce5";
        leafDigestsHex[11] = "0xd2e9e7323853049ba6faab2e2ad1eefc8555f7f0d78b9455184483d4714c83f0";
        leafDigestsHex[12] = "0x3715321c1b979bb17b979f3b4a91d420881cc0009a80acb5c72950044120c420";
        leafDigestsHex[13] = "0x2d5de0142dff4e68a45bac7acb041664c57d732370ba4da313523826fe5f9213";
        leafDigestsHex[14] = "0xb2c231810b1896b1a20033d73d190002550130d1d73276abd30b65855b137844";
        leafDigestsHex[15] = "0x1c0cf279dfb71700cab03d76e92562c48ffb543e1713898c32c681f4b06833b1";
        leafDigestsHex[16] = "0x60d1f2d2490347c797ef066574c0de59fe5b1bb8192e510c531e2056e32df68e";
        leafDigestsHex[17] = "0xeb1d791e387d4f0301ec22021f7079c19554f6c06d86f822f8c5a2528db85847";
        leafDigestsHex[18] = "0x113b96dcc65b3719e0ed2c42556f2e720e08bf37797abec500677c85bb7ac08c";
        leafDigestsHex[19] = "0x1666ec39ea56c83c783b50daf488a1fbf4c37e8b01c0d77779b0e263ce182701";
        leafDigestsHex[20] = "0xa8dd4240c794cc54802caec492e5f59a321f19eb5c37213a8bb1b83e4cd740fc";
        leafDigestsHex[21] = "0xe11611011e8981d198b911012eff1fac9a620e019bffcb9b249896a73979d41b";
        leafDigestsHex[22] = "0xed9cee81b9a0535d4eb8d05777beda1022763f703d527f3aa24b47832dad2362";
        leafDigestsHex[23] = "0xd66e461c8393724f8353ee97afe6b25fac8dda8717339c0931488d2ecc643637";
        leafDigestsHex[24] = "0x5b011dee377043579490483c86c4f0f9f1617d68b9bcfd8e6e9590168b39de1f";
        leafDigestsHex[25] = "0x31571666f3e2b76f63345f3477b3426f669f0bdba6f3fd3889e7705abf006d19";
        leafDigestsHex[26] = "0x923190e6ee43aa9aa9c3f699be7f4c695dd162f07d1236467f78ce7044828f45";
        leafDigestsHex[27] = "0x5031880246ebbd4e7cafa1478ba7d7ff3c291e055f57fac688e7fd6d867b0c53";
        leafDigestsHex[28] = "0xa7a0fd846665d92e66be6155c6221b3acd7145ca7c4e4b67a594e4c516969400";
        leafDigestsHex[29] = "0xa7a0fd846665d92e66be6155c6221b3acd7145ca7c4e4b67a594e4c516969400";
        leafDigestsHex[30] = "0xa7a0fd846665d92e66be6155c6221b3acd7145ca7c4e4b67a594e4c516969400";
        leafDigestsHex[31] = "0xa7a0fd846665d92e66be6155c6221b3acd7145ca7c4e4b67a594e4c516969400";

        // Generate the expected Merkle root
        bytes32 expectedRoot = 0xceb11021b722169f1a4e5ec9aed95891466deb551b47629680750bc7564c4e64;

        // Test with the correct root
        bool result = checker.compareMerkleRoot(leafDigestsHex, expectedRoot, 28, 32);
        assertTrue(result, "Merkle root comparison should return true for correct root");

        // Test with an incorrect root
        bytes32 incorrectRoot = keccak256("incorrect");
        result = checker.compareMerkleRoot(leafDigestsHex, incorrectRoot, 28, 32);
        assertFalse(result, "Merkle root comparison should return false for incorrect root");
    }
}