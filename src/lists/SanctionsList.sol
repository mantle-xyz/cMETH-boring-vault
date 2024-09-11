/**
 *Submitted for verification at Etherscan.io on 2022-03-10
*/
pragma solidity 0.8.20;

import {Ownable} from "openzeppelin/access/Ownable.sol";
import {IISanctionsList} from "../../src/interfaces/ITransferSanctionList.sol";

// @notice we will use Chainalysis's SanctionsList(eth:0x40C57923924B5c5c5455c48D93317139ADDaC8fb)
// @dev contract above is only for testing
contract SanctionsList is IISanctionsList, Ownable {

    constructor() {}

    function name() external pure returns (string memory) {
        return "Chainalysis sanctions oracle";
    }

    function addToSanctionsList(address[] memory newSanctions) public {}

    function removeFromSanctionsList(address[] memory removeSanctions) public {}

    function isSanctioned(address addr) public view returns (bool) {
        return false;
    }

    function isSanctionedVerbose(address addr) public returns (bool) {
        return false;
    }
}
