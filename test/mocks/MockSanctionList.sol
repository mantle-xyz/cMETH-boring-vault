/**
 *Submitted for verification at Etherscan.io on 2022-03-10
*/
pragma solidity 0.8.20;

import "../../src/interfaces/ITransferSanctionList.sol";

contract SanctionsList is IISanctionsList {

    constructor() {}

    mapping(address => bool) private sanctionedAddresses;

    function name() external pure returns (string memory) {
        return "Chainalysis sanctions oracle";
    }

    function addToSanctionsList(address[] memory newSanctions) public {
        for (uint256 i = 0; i < newSanctions.length; i++) {
            sanctionedAddresses[newSanctions[i]] = true;
        }
        emit SanctionedAddressesAdded(newSanctions);
    }

    function removeFromSanctionsList(address[] memory removeSanctions) public {
        for (uint256 i = 0; i < removeSanctions.length; i++) {
            sanctionedAddresses[removeSanctions[i]] = false;
        }
        emit SanctionedAddressesRemoved(removeSanctions);
    }

    function isSanctioned(address addr) public view returns (bool) {
        return sanctionedAddresses[addr] == true ;
    }

    function isSanctionedVerbose(address addr) public returns (bool) {
        if (isSanctioned(addr)) {
            emit SanctionedAddress(addr);
            return true;
        } else {
            emit NonSanctionedAddress(addr);
            return false;
        }
    }

}