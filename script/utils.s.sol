// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
/* solhint-disable no-console */

import {TimelockController} from "openzeppelin/governance/TimelockController.sol";
import {ITransparentUpgradeableProxy} from "src/lib/TransparentUpgradeableProxy.sol";
import { BytesLib } from "solidity-bytes-utils/contracts/BytesLib.sol";

import {IOAppCore} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/interfaces/IOAppCore.sol";
import { OptionsBuilder } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/libs/OptionsBuilder.sol";

import {IOFT, SendParam, MessagingFee, MessagingReceipt, OFTReceipt} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/interfaces/IOFT.sol";

import {L1Deployments, L2Deployments, upgradeToAndCall} from "./helpers/Proxy.sol";
import {L1cmETH} from "../src/L1cmETH.sol";
import {L1cmETHAdapter} from "../src/L1cmETHAdapter.sol";
import {IStatusWrite} from "../src/interfaces/IMessagingStatus.sol";
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

contract Utils is Base {
    using OptionsBuilder for bytes;

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

    function sendL1cmETH(uint32 eId, address recipient, uint256 amount) public {
        L1Deployments memory l1depls = readL1Deployments();
        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        bytes memory composeMsg = "";
        bytes memory oftCmd = "";

        SendParam memory sp = SendParam({
            dstEid: eId,
            to: bytes32(uint256(uint160(recipient))),
            amountLD: amount,
            minAmountLD: amount,
            extraOptions: options,
            composeMsg: composeMsg,
            oftCmd: oftCmd
        });
        MessagingFee memory fee = IOFT(l1depls.l1Adaptor).quoteSend(sp, false);

        vm.startBroadcast();
        (MessagingReceipt memory messagingRecept, OFTReceipt memory oftReceipt) = IOFT(l1depls.l1Adaptor).send{value: fee.nativeFee}(sp, fee, msg.sender);
        vm.stopBroadcast();

        console.log("=============================");
        console.log("MessagingRecept");
        console.log("=============================");
        console.log("guid");
        console.logBytes32(messagingRecept.guid);
        console.log("nonce");
        console.log(messagingRecept.nonce);
        console.log("fee.nativeFee");
        console.log(messagingRecept.fee.nativeFee);
        console.log("fee.lzTokenFee");
        console.log(messagingRecept.fee.lzTokenFee);
        console.log();

        console.log("=============================");
        console.log("OFTReceipt");
        console.log("=============================");
        console.log("amountSentLD");
        console.log(oftReceipt.amountSentLD);
        console.log("amountReceivedLD");
        console.log(oftReceipt.amountReceivedLD);
        console.log();
    }

    function sendL2cmETH(uint32 eId, address recipient, uint256 amount) public {
        L2Deployments memory l2depls = readL2Deployments();
        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        bytes memory composeMsg = "";
        bytes memory oftCmd = "";

        SendParam memory sp = SendParam({
            dstEid: eId,
            to: bytes32(uint256(uint160(recipient))),
            amountLD: amount,
            minAmountLD: amount,
            extraOptions: options,
            composeMsg: composeMsg,
            oftCmd: oftCmd
        });
        MessagingFee memory fee = IOFT(l2depls.l2cmETH).quoteSend(sp, false);

        vm.startBroadcast();
        (MessagingReceipt memory messagingRecept, OFTReceipt memory oftReceipt) = IOFT(l2depls.l2cmETH).send{value: fee.nativeFee}(sp, fee, msg.sender);
        vm.stopBroadcast();

        console.log("=============================");
        console.log("MessagingRecept");
        console.log("=============================");
        console.log("guid");
        console.logBytes32(messagingRecept.guid);
        console.log("nonce");
        console.log(messagingRecept.nonce);
        console.log("fee.nativeFee");
        console.log(messagingRecept.fee.nativeFee);
        console.log("fee.lzTokenFee");
        console.log(messagingRecept.fee.lzTokenFee);
        console.log();

        console.log("=============================");
        console.log("OFTReceipt");
        console.log("=============================");
        console.log("amountSentLD");
        console.log(oftReceipt.amountSentLD);
        console.log("amountReceivedLD");
        console.log(oftReceipt.amountReceivedLD);
        console.log();
    }

    function setPeers(address sourceOApp, uint32[] memory eIds,  address[] memory oApps) public {
        require(eIds.length == oApps.length, "revert: setL1Peers params length not equal");
        vm.startBroadcast();
        for (uint256 i; i < eIds.length; i++) {
            IOAppCore(sourceOApp).setPeer(eIds[i], bytes32(uint256(uint160(oApps[i]))));
        }
        vm.stopBroadcast();
        // check peers
        for (uint256 i; i < eIds.length; i++) {
            require(IOAppCore(sourceOApp).peers(eIds[i]) == bytes32(uint256(uint160(oApps[i]))), "eid and oApp check failed");
        }
    }

    function setIsTransferPausedFor(address targetOApp, uint32 eId, bool isPaused) public {
        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        (uint256 nativeFee, uint256 lzTokenFee) = IStatusWrite(targetOApp).quote(eId, abi.encode(block.timestamp, bytes4(keccak256("setIsTransferPaused(bool)")), isPaused), options);
        vm.startBroadcast();
        IStatusWrite(targetOApp).setIsTransferPausedFor{value: nativeFee}(eId, isPaused);
        vm.stopBroadcast();
    }

    function setExchangeRateFor(address targetOApp, uint32 eId, uint256 rate) public {
        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        (uint256 nativeFee, uint256 lzTokenFee) = IStatusWrite(targetOApp).quote(eId, abi.encode(block.timestamp, bytes4(keccak256("setExchangeRateFor(uint256)")), rate), options);
        vm.startBroadcast();
        IStatusWrite(targetOApp).setExchangeRateFor{value: nativeFee}(eId, rate);
        vm.stopBroadcast();
    }

    function setEnableFor(address targetOApp, uint32 eId, bool enable) public {
        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        (uint256 nativeFee, uint256 lzTokenFee) = IStatusWrite(targetOApp).quote(eId, abi.encode(block.timestamp, bytes4(keccak256("setEnableFor(bool)")), enable), options);
        vm.startBroadcast();
        IStatusWrite(targetOApp).setEnableFor{value: nativeFee}(eId, enable);
        vm.stopBroadcast();
    }

    function setCapFor(address targetOApp, uint32 eId, uint256 cap) public {
        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        (uint256 nativeFee, uint256 lzTokenFee) = IStatusWrite(targetOApp).quote(eId, abi.encode(block.timestamp, bytes4(keccak256("setCapFor(uint256)")), cap), options);
        vm.startBroadcast();
        IStatusWrite(targetOApp).setCapFor{value: nativeFee}(eId, cap);
        vm.stopBroadcast();
    }
}
