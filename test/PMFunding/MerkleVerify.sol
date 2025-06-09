// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import {MerkleProofLib} from "@solmate/utils/MerkleProofLib.sol";

contract MerkleVerify {
    constructor(){

    }

    function verify(bytes32[] calldata proof, bytes32 root, bytes32 leaf) external view returns(bool) {
        return MerkleProofLib.verify(proof, root, leaf);
    }
}
