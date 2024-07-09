// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

//import { ILayerZeroEndpointV2, MessagingFee, MessagingReceipt, Origin } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
//import { ILayerZeroComposer } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroComposer.sol";
//
//import { OAppUpgradeable } from "../OAppUpgradeable.sol";
//import { OptionsBuilder } from "../libs/OptionsBuilder.sol";
//import { OAppPreCrimeSimulatorUpgradeable } from "../../precrime/OAppPreCrimeSimulatorUpgradeable.sol";

library MsgCodec {
//    uint8 internal constant VANILLA_TYPE = 1;
//    uint8 internal constant COMPOSED_TYPE = 2;
//    uint8 internal constant ABA_TYPE = 3;
//    uint8 internal constant COMPOSED_ABA_TYPE = 4;
//
//    uint8 internal constant MSG_TYPE_OFFSET = 0;
//    uint8 internal constant SRC_EID_OFFSET = 1;
//    uint8 internal constant VALUE_OFFSET = 5;
//
//    function encode(uint8 _type, uint32 _srcEid) internal pure returns (bytes memory) {
//        return abi.encodePacked(_type, _srcEid);
//    }
//
//    function encode(uint8 _type, uint32 _srcEid, uint256 _value) internal pure returns (bytes memory) {
//        return abi.encodePacked(_type, _srcEid, _value);
//    }
//
//    function msgType(bytes calldata _message) internal pure returns (uint8) {
//        return uint8(bytes1(_message[MSG_TYPE_OFFSET:SRC_EID_OFFSET]));
//    }
//
//    function srcEid(bytes calldata _message) internal pure returns (uint32) {
//        return uint32(bytes4(_message[SRC_EID_OFFSET:VALUE_OFFSET]));
//    }
//
//    function value(bytes calldata _message) internal pure returns (uint256) {
//        return uint256(bytes32(_message[VALUE_OFFSET:]));
//    }
}
