// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface BeforeTransferHook {
    function beforeTransfer(address from, address to, address operator) external view;
}
