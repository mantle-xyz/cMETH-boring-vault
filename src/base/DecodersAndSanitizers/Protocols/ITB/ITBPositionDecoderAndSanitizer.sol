/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.8.0;

import "./common/BoringDecoderAndSanitizer.sol";
import "./eigen_layer/EigenLayerDecoderAndSanitizer.sol";
import "./karak/KarakDecoderAndSanitizer.sol";
import "./symbiotic/SymbioticNoVaultDecoderAndSanitizer.sol";

contract ITBPositionDecoderAndSanitizer is
    BoringDecoderAndSanitizer,
    EigenLayerDecoderAndSanitizer,
    KarakDecoderAndSanitizer,
    SymbioticNoVaultDecoderAndSanitizer
{
    constructor(address _boringVault) BoringDecoderAndSanitizer(_boringVault) {}

    function transfer(address _to, uint256) external pure returns (bytes memory addressesFound) {
        addressesFound = abi.encodePacked(_to);
    }

    function withdrawNonBoringToken(address token, uint256 /*amount*/ )
        external
        pure
        returns (bytes memory addressesFound)
    {
        addressesFound = abi.encodePacked(token);
    }

    function deposit(uint256, uint256)
        external
        pure
        override(EigenLayerDecoderAndSanitizer, KarakDecoderAndSanitizer)
        returns (bytes memory addressesFound)
    {
        // Nothing to sanitize or return
        return addressesFound;
    }

    // Override function collisions.
    function startWithdrawal(uint256)
        external
        pure
        override(EigenLayerDecoderAndSanitizer, KarakDecoderAndSanitizer)
        returns (bytes memory addressesFound)
    {
        // Nothing to sanitize or return
        return addressesFound;
    }

    function completeWithdrawal(uint256, uint256)
        external
        pure
        override(EigenLayerDecoderAndSanitizer, KarakDecoderAndSanitizer)
        returns (bytes memory addressesFound)
    {
        // Nothing to sanitize or return
        return addressesFound;
    }

    function completeNextWithdrawal(uint256)
        external
        pure
        override(EigenLayerDecoderAndSanitizer, KarakDecoderAndSanitizer)
        returns (bytes memory addressesFound)
    {
        // Nothing to sanitize or return
        return addressesFound;
    }

    function completeNextWithdrawals(uint256)
        external
        pure
        override(EigenLayerDecoderAndSanitizer, KarakDecoderAndSanitizer)
        returns (bytes memory addressesFound)
    {
        // Nothing to sanitize or return
        return addressesFound;
    }

    function overrideWithdrawalIndexes(uint256, uint256)
        external
        pure
        override(EigenLayerDecoderAndSanitizer, KarakDecoderAndSanitizer)
        returns (bytes memory addressesFound)
    {
        // Nothing to sanitize or return
        return addressesFound;
    }

    function assemble(uint256)
        external
        pure
        override(EigenLayerDecoderAndSanitizer, KarakDecoderAndSanitizer, SymbioticNoVaultDecoderAndSanitizer)
        returns (bytes memory addressesFound)
    {
        // Nothing to sanitize or return
        return addressesFound;
    }

    function disassemble(uint256, uint256)
        external
        pure
        override(EigenLayerDecoderAndSanitizer, KarakDecoderAndSanitizer, SymbioticNoVaultDecoderAndSanitizer)
        returns (bytes memory addressesFound)
    {
        // Nothing to sanitize or return
        return addressesFound;
    }

    function fullDisassemble(uint256)
        external
        pure
        override(EigenLayerDecoderAndSanitizer, KarakDecoderAndSanitizer, SymbioticNoVaultDecoderAndSanitizer)
        returns (bytes memory addressesFound)
    {
        // Nothing to sanitize or return
        return addressesFound;
    }

    function updatePositionConfig(address a, address b, address c)
        external
        pure
        override(SymbioticNoVaultDecoderAndSanitizer, EigenLayerDecoderAndSanitizer)
        returns (bytes memory addressesFound)
    {
        addressesFound = abi.encodePacked(a, b, c);
    }
}
