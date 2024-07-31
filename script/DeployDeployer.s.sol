// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.20;

import {Deployer} from "src/helper/Deployer.sol";
import {RolesAuthority, Authority} from "@solmate/auth/authorities/RolesAuthority.sol";
import {ContractNames} from "resources/ContractNames.sol";
import {MainnetAddresses} from "test/resources/MainnetAddresses.sol";

import "forge-std/Script.sol";
import "forge-std/StdJson.sol";

/**
 *  source .env && forge script script/DeployDeployer.s.sol:DeployDeployerScript --with-gas-price 30000000000 --slow --broadcast --etherscan-api-key $ETHERSCAN_KEY --verify
 * @dev Optionally can change `--with-gas-price` to something more reasonable
 */
contract DeployDeployerScript is Script, ContractNames, MainnetAddresses {
    address public owner;

    // Contracts to deploy
    RolesAuthority public rolesAuthority;
    Deployer public deployer;

    uint8 public DEPLOYER_ROLE = 1;

    function setUp() external {
        owner = vm.envAddress("OWNER_ADDRESS");
    }

    function run() external {
        bytes memory creationCode;
        bytes memory constructorArgs;
        vm.startBroadcast();
        deployer = new Deployer(owner, Authority(address(0)));
        creationCode = type(RolesAuthority).creationCode;
        constructorArgs = abi.encode(owner, Authority(address(0)));
        rolesAuthority =
            RolesAuthority(deployer.deployContract(SevenSeasRolesAuthorityName, creationCode, constructorArgs, 0));

        deployer.setAuthority(rolesAuthority);

        rolesAuthority.setRoleCapability(DEPLOYER_ROLE, address(deployer), Deployer.deployContract.selector, true);
        rolesAuthority.setUserRole(owner, DEPLOYER_ROLE, true);
        vm.stopBroadcast();
    }
}
