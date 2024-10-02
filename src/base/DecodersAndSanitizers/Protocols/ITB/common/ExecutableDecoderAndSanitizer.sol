/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.8.0;

/// @title Decoder and sanitizer for Executable
/// @author IntoTheBlock Corp
abstract contract ExecutableDecoderAndSanitizer {
    function addExecutor(address _executor) external pure returns (bytes memory addressesFound) {
        addressesFound = abi.encodePacked(_executor);
    }

    function removeExecutor(address _executor) external pure returns (bytes memory addressesFound) {
        addressesFound = abi.encodePacked(_executor);
    }
}
