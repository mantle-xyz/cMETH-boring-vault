// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.20;

import {AccountantWithRateProviders} from "src/base/Roles/AccountantWithRateProviders.sol";
import {BoringVault, ERC20} from "src/base/BoringVault.sol";
import {ERC4626} from "lib/solmate/src/tokens/ERC4626.sol";
import {FixedPointMathLib} from "@solmate/utils/FixedPointMathLib.sol";

/**
 * @notice This contract is intended to be used to migrate a Cellar to a BoringVault, while maintaining the share price parity.
 *         In order to do this, ALL assets in the Cellar must be in the BoringVault, and the vast majority of BoringVault
 *         shares must be owned by the Cellar.
 */
contract CellarMigratorWithSharePriceParity {
    using FixedPointMathLib for uint256;

    /**
     * @notice The BoringVault the Cellar is migrating to.
     */
    BoringVault internal immutable boringVault;

    /**
     * @notice The accountant of the BoringVault.
     */
    AccountantWithRateProviders internal immutable accountant;

    /**
     * @notice The Cellar being migrated.
     */
    ERC4626 internal immutable target;

    /**
     * @notice The address capable of calling `completeMigration`.
     */
    address internal immutable migrator;

    /**
     * @notice Bool indicating if the migration has been completed.
     */
    bool public migrationDone;

    constructor(BoringVault bv, ERC4626 v1, AccountantWithRateProviders _accountant, address _migrator) {
        boringVault = bv;
        target = v1;
        accountant = _accountant;
        migrator = _migrator;
    }

    /**
     * @notice Helper function to complete the migration.
     * @dev Only callable by the `migrator` address.
     * @dev Only callable once.
     * @param checkIfCellarOwnsAllShares Bool indicating if the Cellar should own all shares of the target.
     * @param totalAssetsTolerance The tolerance for the change of total assets of the target.
     * @dev If `checkIfCellarOwnsAllShares` is true, the Cellar must own all BoringVault shares.
     * @dev `totalAssetsTolerance` with 4 decimals, must be less than 1e4. There is no explicit check for this,
     *       but the `minimumTotalAssets` calcualtion will revert from underflow if it is larger than 1e4.
     */
    function completeMigration(bool checkIfCellarOwnsAllShares, uint256 totalAssetsTolerance) external {
        require(msg.sender == migrator, "MIGRATOR");
        require(!migrationDone, "DONE");
        migrationDone = true;
        // Once all assets have been migrated from v1 to the bv, in order to make the share price identical,
        // v1 must hold the same amount of bv shares, as its total supply.
        uint256 targetTotalSupply = target.totalSupply();
        uint256 targetBvShares = boringVault.balanceOf(address(target));
        uint8 targetDecimals = target.decimals();
        uint256 targetTotalAssets = target.totalAssets();
        uint256 startingSharePrice = targetTotalAssets.mulDivDown(10 ** targetDecimals, targetTotalSupply);

        // Update accountants exchange rate.
        accountant.updateExchangeRate(uint96(startingSharePrice));

        if (checkIfCellarOwnsAllShares) {
            // Make sure that Cellar owns all shares of the target.
            require(targetBvShares == boringVault.totalSupply(), "SHARES");
        }

        // Update target's BoringVault share amount to keep share price constant.
        if (targetBvShares < targetTotalSupply) {
            // If target has less bv shares than its total supply, mint the difference.
            boringVault.enter(address(0), ERC20(address(0)), 0, address(target), targetTotalSupply - targetBvShares);
        } else if (targetBvShares > targetTotalSupply) {
            // If target has more bv shares than its total supply, burn the difference.
            boringVault.exit(address(0), ERC20(address(0)), 0, address(target), targetBvShares - targetTotalSupply);
        }

        // Make sure that the total supply of target matches the bv balance of target.
        require(targetTotalSupply == boringVault.balanceOf(address(target)), "BAL");

        // Make sure share price matches with a +- 1 wei difference.
        uint256 currentTotalAssets = target.totalAssets();
        // There is no explicit check that totalAssetsTolerance is less than 1e4, but
        // the line below will revert from underflow if it is larger than 1e4.
        uint256 minimumTotalAssets = targetTotalAssets.mulDivDown(1e4 - totalAssetsTolerance, 1e4);
        uint256 maximumTotalAssets = targetTotalAssets.mulDivDown(1e4 + totalAssetsTolerance, 1e4);

        require((currentTotalAssets > minimumTotalAssets) && (currentTotalAssets < maximumTotalAssets), "TA");

        uint256 currentSharePrice = currentTotalAssets.mulDivDown(10 ** targetDecimals, targetTotalSupply);
        require(
            (currentSharePrice + 1 == startingSharePrice) || (currentSharePrice - 1 == startingSharePrice)
                || (currentSharePrice == startingSharePrice),
            "SP"
        );
    }
}
