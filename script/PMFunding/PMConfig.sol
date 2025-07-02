// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console2 as console} from "forge-std/console2.sol";
import {stdJson} from "forge-std/StdJson.sol";

contract PMConfig is Script{
    string internal _json;
    address public deployerSafeAddress;
    address public merkleManagerAddress;
    address public boringVaultAddress;
    address public mETHAddress;
    address public eigenPM_p2pAddress;
    address public eigenPM_a41Address;
    address public symbioticPMAddress;
    address public mETHStrategyAddress;
    address public strategyManagerAddress;
    address public symbioticVaultAddress;
    address public symbioticNoVaultAddress;
    address public karakPMAddress;

    function read(string memory _path) public {
        console.log("reading config: ", _path);
        try vm.readFile(_path) returns (string memory data) {
            _json = data;
        } catch {
            revert("failed to read config");
        }

        deployerSafeAddress = stdJson.readAddress(_json, "$.config.deployerSafeAddress");
        mETHAddress = stdJson.readAddress(_json, "$.config.mETHAddress");
        eigenPM_p2pAddress = stdJson.readAddress(_json, "$.config.eigenPM_p2pAddress");
        eigenPM_a41Address = stdJson.readAddress(_json, "$.config.eigenPM_a41Address");
        symbioticPMAddress = stdJson.readAddress(_json, "$.config.symbioticPMAddress");
        merkleManagerAddress = stdJson.readAddress(_json, "$.config.merkleManagerAddress");
        mETHStrategyAddress = stdJson.readAddress(_json, "$.config.mETHStrategyAddress");
        symbioticVaultAddress = stdJson.readAddress(_json, "$.config.symbioticVaultAddress");
        symbioticNoVaultAddress = stdJson.readAddress(_json, "$.config.symbioticNoVaultAddress");
        boringVaultAddress = stdJson.readAddress(_json, "$.config.boringVaultAddress");
        karakPMAddress = stdJson.readAddress(_json, "$.config.karakPMAddress");
    }
}