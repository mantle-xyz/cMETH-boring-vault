// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {CallMerkleManager} from "./CallMerkleManager.sol";
import "./interfaces/IStrategy.sol";
import {IMETH} from "./interfaces/IMETH.sol";
import "./interfaces/IVault.sol";
import "./interfaces/IStrategyManager.sol";
import "./interfaces/IPM.sol";
import {IPositionManagerNoVault} from "./interfaces/IPositionManagerNoVault.sol";
import {Math} from "openzeppelin/utils/math/Math.sol";
import {console} from "@forge-std/console.sol";

struct Operation {
    address target;
    string functionSignature;
    address[] argumentAddresses;
    bytes data;
}

contract ManageVault is CallMerkleManager {
    IStrategy public mETHStrategy;
    IVault public vault;
    IMETH public mETH;
    IStrategyManager public strategyManager;
    IPositionManagerNoVault public symbioticPositionManagerNoVault;

    Operation[] public operations;

    function setUp() public override {
        super.setUp();
        mETHStrategy = IStrategy(mETHStrategyAddress);
        mETH = IMETH(mETHAddress);
        vault = IVault(symbioticVaultAddress);
        strategyManager = IStrategyManager(strategyManagerAddress);
        symbioticPositionManagerNoVault = IPositionManagerNoVault(symbioticNoVaultAddress);
    }

    function eigenPM_p2pFunding() public {
        uint amount = 0.8 ether;
        _transferMETHToPM(eigenPM_p2pAddress, amount);
        _deposit(eigenPM_p2pAddress, amount);
        _startWithdrawal(eigenPM_p2pAddress, 0.4 ether);
        _executeOperations();
    }

    function eigenPM_a41Funding() public {
        uint amount = 0.8 ether;
        _transferMETHToPM(eigenPM_a41Address, amount);
        _deposit(eigenPM_a41Address, amount);
        _startWithdrawal(eigenPM_a41Address, 0.4 ether);
        _executeOperations();
    }

    function symbioticPMFunding() public {
        uint amount = 0.8 ether;
        _transferMETHToPM(symbioticPMAddress, amount);
        _deposit(symbioticPMAddress, amount);
        _startWithdrawal(symbioticPMAddress, 0.4 ether);
        _executeOperations();
    }
    function RebalanceToEigenLayer() public {
        uint depositAmountInEigenlayerA41 = 2400 ether;
        uint depositAmountInEigenlayerP2P = 2400 ether;

        // deposit in eigenlayer p2p
        _transferMETHToPM(eigenPM_p2pAddress, depositAmountInEigenlayerA41);
        _deposit(eigenPM_p2pAddress, depositAmountInEigenlayerA41);

        // deposit in eigenlayer a41
        _transferMETHToPM(eigenPM_a41Address, depositAmountInEigenlayerP2P);
        _deposit(eigenPM_a41Address, depositAmountInEigenlayerP2P);

        _startWithdrawal(karakPMAddress, 0.1 ether);

        _executeOperations();
    }

    function RebalanceSymbioticAndEigenlayer() public {
        uint amount = symbioticPositionManagerNoVault.getTotalCollateral();
        uint depositAmountInEigenlayerA41PM = 45229.4 ether;
        uint depositAmountInEigenlayerA41Vault = 45229.6 ether;
        uint depositAmountInEigenlayerP2PPM = 45229.4 ether;
        uint depositAmountInEigenlayerP2PVault = 45229.6 ether;
        uint depositAmountInSymbioticPM = 90458.4 ether;
        uint depositAmountInSymbioticVault = 90458.6 ether;
        
        // withdraw collateral from symbiotic vault
        _withdrawCollateral(symbioticNoVaultAddress, amount);
        _withdrawToBoringVault(symbioticNoVaultAddress, amount);

        // deposit in eigenlayer a41 pm
        _transferMETHToPM(eigenPM_a41Address, depositAmountInEigenlayerA41PM);
        _deposit(eigenPM_a41Address, depositAmountInEigenlayerA41Vault);

        // deposit in eigenlayer p2p pm
        _transferMETHToPM(eigenPM_p2pAddress, depositAmountInEigenlayerP2PPM);
        _deposit(eigenPM_p2pAddress, depositAmountInEigenlayerP2PVault);

        // deposit in symbiotic pm
        _transferMETHToPM(symbioticPMAddress, depositAmountInSymbioticPM);
        _deposit(symbioticPMAddress, depositAmountInSymbioticVault);

        // execute operations
        _executeOperations();
    }

    function WithdrawOperations() public {
        _completeWithdraw(eigenPM_p2pAddress, 0.4 ether);
        _withdrawToBoringVault(eigenPM_p2pAddress, 0.4 ether);
        _completeWithdraw(eigenPM_a41Address, 0.4 ether);
        _withdrawToBoringVault(eigenPM_a41Address, 0.4 ether);
        // _completeWithdraw(symbioticPMAddress, 0.4 ether);
        // _withdrawToBoringVault(symbioticPMAddress, 0.4 ether);
        _executeOperations();
    }

    function _withdrawCollateral(address pm, uint amount) public {
        address target = pm;
        string memory funcSignature = "withdrawCollateral(uint256,uint256)";
        address[] memory argumentAddress = new address[](0);
        bytes memory data = abi.encode(amount, amount);
        _addOperation(target, funcSignature, argumentAddress, data);
    }
    function _withdrawToBoringVault(address pm, uint256 amount) internal {
        address target = pm;
        string memory funcSignature = "withdraw(address,uint256)";
        address[] memory argumentAddress = new address[](1);
        argumentAddress[0] = address(mETHAddress);
        bytes memory data = abi.encode(address(mETHAddress), amount);
        _addOperation(target, funcSignature, argumentAddress, data);
    }

    function _transferMETHToPM(address pm, uint amount) internal {
        address target = mETHAddress;
        string memory funcSignature = "transfer(address,uint256)";
        address[] memory argumentAddress = new address[](1);
        argumentAddress[0] = address(pm);
        bytes memory data = abi.encode(address(pm), amount);
        _addOperation(target, funcSignature, argumentAddress, data);
    }

    function _deposit(address pm, uint expectDepositAmount) internal {
        address target = pm;
        string memory funcSignature = "deposit(uint256,uint256)";
        address[] memory argumentAddress = new address[](0);
        // uint expectDepositAmount = 0.8 ether;
        uint expectNewShares = _calNewShares(pm, expectDepositAmount);
        bytes memory data = abi.encode(expectDepositAmount, expectNewShares);
        _addOperation(target, funcSignature, argumentAddress, data);
    }

    function _startWithdrawal(address pm, uint withdrawAmount) internal {
        address target = pm;
        string memory funcSignature = "startWithdrawal(uint256)";
        address[] memory argumentAddress = new address[](0);
        bytes memory data = abi.encode(withdrawAmount);
        _addOperation(target, funcSignature, argumentAddress, data);
    }

    function _completeWithdraw(address pm, uint withdrawShares) internal {
        address target = pm;
        string memory funcSignature = "completeNextWithdrawals(uint256)";
        address[] memory argumentAddress = new address[](0);
        bytes memory data = abi.encode(withdrawShares);
        _addOperation(target, funcSignature, argumentAddress, data);
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
    function _addOperation(
        address target,
        string memory functionSignature,
        address[] memory argumentAddresses,
        bytes memory data
    ) internal {
        operations.push(Operation({
            target: target,
            functionSignature: functionSignature,
            argumentAddresses: argumentAddresses,
            data: data
        }));
    }
    function _clearOperations() internal {
        delete operations;
    }
    function _executeOperations() internal {
        uint256 length = operations.length;
        address[] memory targets = new address[](length);
        string[] memory functionSignatures = new string[](length);
        address[][] memory argumentAddresses = new address[][](length);
        bytes[] memory data = new bytes[](length);
        
        for (uint256 i; i < length; ++i) {
            targets[i] = operations[i].target;
            functionSignatures[i] = operations[i].functionSignature;
            argumentAddresses[i] = operations[i].argumentAddresses;
            data[i] = operations[i].data;
        }
        
        encodeManageVaultWithMerkleVerification(targets, functionSignatures, argumentAddresses, data);
    }
    function getOperationsCount() public view returns (uint256) {
        return operations.length;
    }
    function getOperation(uint256 index) public view returns (
        address target,
        string memory functionSignature,
        address[] memory argumentAddresses,
        bytes memory data
    ) {
        require(index < operations.length, "Index out of bounds");
        Operation memory op = operations[index];
        return (op.target, op.functionSignature, op.argumentAddresses, op.data);
    }
}