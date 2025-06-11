// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {CallMerkleManager} from "./CallMerkleManager.sol";
import "./interfaces/IStrategy.sol";
import {IMETH} from "./interfaces/IMETH.sol";
import "./interfaces/IVault.sol";
import "./interfaces/IStrategyManager.sol";
import "./interfaces/IPM.sol";
import {Math} from "openzeppelin/utils/math/Math.sol";
import {console} from "@forge-std/console.sol";

contract PMFundingScript is CallMerkleManager {
    IStrategy public mETHStrategy;
    IVault public vault;
    IMETH public mETH;
    IStrategyManager public strategyManager;

    function setUp() public override {
        super.setUp();
        mETHStrategy = IStrategy(mETHStrategyAddress);
        mETH = IMETH(mETHAddress);
        vault = IVault(symbioticVaultAddress);
        strategyManager = IStrategyManager(strategyManagerAddress);

    }

    function run() public {
        address defaultAccount = vm.envAddress("F_SENDER");
        vm.startBroadcast(defaultAccount);
        payable(deployerSafeAddress).transfer(1 ether);
    }

    function eigenPM_p2pFunding() public {
        uint preBoringVaultBalance = mETH.balanceOf(boringVaultAddress);
        _transferMETHToPM(eigenPM_p2pAddress);
        _deposit(eigenPM_p2pAddress);
        _withdraw(eigenPM_p2pAddress);

//        vm.startBroadcast();
//        _execBatchTransaction(safe_);
//        vm.stopBroadcast();
//        _clearBatchTxns();
//        _balanceCheck(eigenPM_p2pAddress, preBoringVaultBalance);
//        bytes memory data = _createBatchCalldata();
//        console.logString("p2pFunding call data:");
//        for(uint i; i < batchTxns.length; i++) {
//            console.logString(string.concat("tx index: ", vm.toString(i)));
//            console.logBytes(batchTxns[i]);
//        }
    }

    function eigenPM_a41Funding() public {
        _transferMETHToPM(eigenPM_a41Address);
        _deposit(eigenPM_a41Address);
        _withdraw(eigenPM_a41Address);

        bytes memory data = _createBatchCalldata();
        console.logString("a41Funding call data:");
        console.logBytes(data);
    }

    function symbioticPMFunding() public {
        _transferMETHToPM(symbioticPMAddress);
        _deposit(symbioticPMAddress);
        _withdraw(symbioticPMAddress);

        bytes memory data = _createBatchCalldata();
        console.logString("symbioticFunding call data:");
        console.logBytes(data);
    }

    function _transferMETHToPM(address pm) internal {
        address target = mETHAddress;
        string memory funcSignature = "transfer(address,uint256)";
        address[] memory argumentAddress = new address[](1);
        argumentAddress[0] = address(pm);
        bytes memory data = abi.encode(address(pm), 1 ether);
        _callMerkleManager(target, funcSignature, argumentAddress, data);
    }

    function _deposit(address pm) internal {
        address target = pm;
        string memory funcSignature = "deposit(uint256,uint256)";
        address[] memory argumentAddress = new address[](0);
        uint expectDepositAmount = 0.8 ether;
        uint expectNewShares = _calNewShares(pm, expectDepositAmount);
        bytes memory data = abi.encode(expectDepositAmount, expectNewShares);
        _callMerkleManager(target, funcSignature, argumentAddress, data);
    }

    function _withdraw(address pm) internal {
        address target = pm;
        string memory funcSignature = "startWithdrawal(uint256)";
        address[] memory argumentAddress = new address[](0);
        uint withdrawAmount = 0.4 ether;
        bytes memory data = abi.encode(withdrawAmount);
        _callMerkleManager(target, funcSignature, argumentAddress, data);
    }

    function _completeWithdraw(address pm) internal {
        address target = pm;
        string memory funcSignature = "completeNextWithdrawals(uint256)";
        address[] memory argumentAddress = new address[](0);
        uint withdrawShares = 0.4 ether;
        bytes memory data = abi.encode(withdrawShares);
        _callMerkleManager(target, funcSignature, argumentAddress, data);
    }

    function _calNewShares(address PM, uint amount) internal view returns(uint newShares){
        if(PM == symbioticPMAddress) {
            uint activeStake = vault.activeStake();
            uint activeShares = vault.activeShares();
            newShares = Math.mulDiv(amount, activeShares + 1, activeStake + 1, Math.Rounding.Floor);
        } else {
            uint totalShares = mETHStrategy.totalShares();
            totalShares += 1e3;
            uint strategyBalance = mETH.balanceOf(address(mETHStrategy));
            strategyBalance += 1e3;
            newShares = (amount * totalShares) / strategyBalance;
        }
    }

    function _balanceCheck(address pm, uint preBoringVaultBalance) internal {
        uint pmBalance = mETH.balanceOf(pm);
        uint boringVaultBalance = mETH.balanceOf(boringVaultAddress);
        uint shares;
        if (pm == symbioticPMAddress) {
            shares = vault.activeSharesOf(pm);
        } else {
            shares = strategyManager.stakerDepositShares(pm, mETHStrategyAddress);
        }
        uint lpt = IPM(pm).getTotalLPT();
        require(pmBalance == 0.2 ether, "pm balance incorrect");
        require(boringVaultBalance == preBoringVaultBalance - 1 ether, "boring vault balance incorrect");
        require(shares == 0.4 ether, "pm shares incorrect");
        require(lpt == 0.8 ether, "pm lpt incorrect");
    }

    function _clearBatchTxns() internal {
        delete batchTxns;
    }
}