/* SPDX-License-Identifier: UNLICENSED */
pragma solidity ^0.8.0;

import "../common/ITBContractDecoderAndSanitizer.sol";

abstract contract SymbioticNoVaultDecoderAndSanitizer is ITBContractDecoderAndSanitizer {
    function updatePositionConfig(address _collateral, address _underlying, address _vault)
        external
        pure
        virtual
        returns (bytes memory addressesFound)
    {
        addressesFound = abi.encodePacked(_collateral, _underlying, _vault);
    }

    function depositCollateral(uint256, uint256) external pure virtual returns (bytes memory addressesFound) {
        // Nothing to sanitize or return
        return addressesFound;
    }

    function withdrawCollateral(uint256, uint256) external pure virtual returns (bytes memory addressesFound) {
        // Nothing to sanitize or return
        return addressesFound;
    }

    function assemble(uint256) external pure virtual returns (bytes memory addressesFound) {
        // Nothing to sanitize or return
        return addressesFound;
    }

    function disassemble(uint256, uint256) external pure virtual returns (bytes memory addressesFound) {
        // Nothing to sanitize or return
        return addressesFound;
    }

    function fullDisassemble(uint256) external pure virtual returns (bytes memory addressesFound) {
        // Nothing to sanitize or return
        return addressesFound;
    }
}
