// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.20;

import {DeployArcticArchitecture, ERC20, Deployer} from "script/ArchitectureDeployments/DeployArcticArchitecture.sol";
import {AddressToBytes32Lib} from "src/helper/AddressToBytes32Lib.sol";
import {MainnetAddresses} from "test/resources/MainnetAddresses.sol";

// Import Decoder and Sanitizer to deploy.
import {EtherFiLiquidEthDecoderAndSanitizer} from
    "src/base/DecodersAndSanitizers/EtherFiLiquidEthDecoderAndSanitizer.sol";

/**
 *  source .env && forge script script/ArchitectureDeployments/Mainnet/DeployMantleCmETHBoringVault.s.sol:DeployMantleCmETHBoringVaultScript --with-gas-price 10000000000 --slow --broadcast --etherscan-api-key $ETHERSCAN_KEY --verify
 * @dev Optionally can change `--with-gas-price` to something more reasonable
 */
contract DeployMantleCmETHBoringVaultScript is DeployArcticArchitecture, MainnetAddresses {
    using AddressToBytes32Lib for address;

    uint256 public privateKey;

    // Deployment parameters
    address public owner = dev1Address;
    address public cmETH = address(WETH);

    function setUp() external {
        privateKey = vm.envUint("BORING_DEPLOYER");
        vm.createSelectFork("mainnet");
    }

    function run() external {
        // Configure the deployment.
        configureDeployment.deployContracts = true;
        configureDeployment.setupRoles = false;
        configureDeployment.setupDepositAssets = false;
        configureDeployment.setupWithdrawAssets = false;
        configureDeployment.finishSetup = false;
        configureDeployment.setupTestUser = false;
        configureDeployment.saveDeploymentDetails = true;
        configureDeployment.makeBoringVaultUpgradeable = true;
        configureDeployment.deployerAddress = deployerAddress;
        configureDeployment.balancerVault = balancerVault;
        configureDeployment.WETH = address(WETH);

        // Save deployer.
        deployer = Deployer(configureDeployment.deployerAddress);

        // Define names to determine where contracts are deployed.
        names.rolesAuthority = MantleCmETHRolesAuthorityName;
        names.lens = ArcticArchitectureLensName;
        names.boringVault = MantleCmETHName;
        names.manager = MantleCmETHManagerName;
        names.accountant = MantleCmETHAccountantName;
        names.teller = MantleCmETHTellerName;
        names.rawDataDecoderAndSanitizer = MantleCmETHDecoderAndSanitizerName;
        names.delayedWithdrawer = MantleCmETHDelayedWithdrawer;
        names.boringVaultImplementation = MantleCmETHImplementationName;
        names.pauser = MantleCmETHPauser;

        // Define Accountant Parameters.
        accountantParameters.payoutAddress = liquidPayoutAddress;
        accountantParameters.base = WETH;
        // Decimals are in terms of `base`.
        accountantParameters.startingExchangeRate = 1e18;
        //  4 decimals
        accountantParameters.managementFee = 0;
        accountantParameters.performanceFee = 0;
        accountantParameters.allowedExchangeRateChangeLower = 0.995e4;
        accountantParameters.allowedExchangeRateChangeUpper = 1.005e4;
        // Minimum time(in seconds) to pass between updated without triggering a pause.
        accountantParameters.minimumUpateDelayInSeconds = 1 days / 4;

        // Define Decoder and Sanitizer deployment details.
        // TODO update this to the correct decoder and sanitizer
        bytes memory creationCode = type(EtherFiLiquidEthDecoderAndSanitizer).creationCode;
        bytes memory constructorArgs =
            abi.encode(deployer.getAddress(names.boringVault), uniswapV3NonFungiblePositionManager);

        // Setup extra deposit assets.
        // none

        // Setup withdraw assets.
        withdrawAssets.push(
            WithdrawAsset({
                asset: METH,
                withdrawDelay: 3 days,
                completionWindow: 7 days,
                withdrawFee: 0,
                maxLoss: 0.01e4
            })
        );

        bool allowPublicDeposits = false;
        bool allowPublicWithdraws = false;
        uint64 shareLockPeriod = 1 days;
        address delayedWithdrawFeeAddress = liquidPayoutAddress;

        vm.startBroadcast(privateKey);

        _deploy(
            "MantleCmETHDeployment.json",
            owner,
            cmETH,
            creationCode,
            constructorArgs,
            delayedWithdrawFeeAddress,
            allowPublicDeposits,
            allowPublicWithdraws,
            shareLockPeriod,
            dev1Address
        );

        vm.stopBroadcast();
    }
}
