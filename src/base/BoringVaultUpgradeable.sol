// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {BoringVault, IL1cmETH, Authority} from "src/base/BoringVault.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract BoringVaultUpgradeable is BoringVault, Initializable {
    //============================== CONSTRUCTOR ===============================

    constructor() BoringVault(address(0), address(0)) {
        _disableInitializers();
    }

    //============================== INITIALIZE ===============================

    /*
     * @notice Initializes the contract with the owner, authority, and cmETH.
     */
    function initialize(address _owner, address _auth, address _cmETH) external initializer {
        owner = _owner;
        authority = Authority(_auth);
        cmETH = IL1cmETH(_cmETH);
    }
}
