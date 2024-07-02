// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.20;

import {MainnetAddresses} from "test/resources/MainnetAddresses.sol";
import {BoringVault} from "src/base/BoringVault.sol";
import {AccountantWithRateProviders} from "src/base/Roles/AccountantWithRateProviders.sol";
import {SafeTransferLib} from "@solmate/utils/SafeTransferLib.sol";
import {FixedPointMathLib} from "@solmate/utils/FixedPointMathLib.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";
import {IRateProvider} from "src/interfaces/IRateProvider.sol";
import {RolesAuthority, Authority} from "@solmate/auth/authorities/RolesAuthority.sol";
import {GenericRateProvider} from "src/helper/GenericRateProvider.sol";
import {
    TransparentUpgradeableProxy,
    ITransparentUpgradeableProxy
} from "lib/openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {L1cmETH} from "src/mantle/src/L1cmETH.sol";

contract cmETHHelper {
    L1cmETH public cmETH;

    // Needed in order for cmETH mint to work.
    bool public isOriginalMintBurnPaused;
    bool public isTransferPaused;
    mapping(address => bool) public isBlocked;
    mapping(address => bool) public isSanctioned;

    function _deploycmETH() internal returns (address _cmETH) {
        // Deploy cmETH logic contract.
        L1cmETH cmETHLogic = new L1cmETH();

        // Deploy TransparentUpgradeableProxy for cmETH.
        L1cmETH.Init memory init = L1cmETH.Init(
            address(this),
            address(this),
            address(this),
            address(this),
            address(this),
            "Implementation cmETH",
            "Implementation cmETH",
            type(uint256).max,
            address(this),
            address(this)
        );
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(cmETHLogic), address(this), abi.encodeWithSelector(L1cmETH.initialize.selector, init)
        );

        _cmETH = address(proxy);
    }
}
