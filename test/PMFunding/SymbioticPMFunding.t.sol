// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@forge-std/Test.sol";
import "./CallMerkleManager.sol";
import {IEigenLayerPM} from "./interfaces/IEigenLayerPM.sol";
import {IMETH} from "./interfaces/IMETH.sol";
import "./interfaces/IStrategy.sol";
import "./interfaces/IStrategyManager.sol";
import "./interfaces/ISymbioticPM.sol";
import "./interfaces/IVault.sol";
import {Math} from "openzeppelin/utils/math/Math.sol";

contract SymbioticPMFundingTest is Test, CallMerkleManager {
    bytes32 public standardRoot = 0x1c507dd81e210ab113f5aaa7a363080c5c459dd652ca51f94e23eb21fe9862ca;
    address public merkleManagerOwner = 0x849738999Ba1F3D995d28bDB35efA2E47B4c8203;
    ISymbioticPM public symbioticPM = ISymbioticPM(0x5bb8e5e8602b71b182e0Efe256896a931489A135);
    IMETH public mETH = IMETH(0xd5F7838F5C461fefF7FE49ea5ebaF7728bB0ADfa);
    IVault public vault = IVault(0xbA60b6969fAA9b927A0acc750Ea8EEAdcEd644B7);

    function setUp() public {
        _setStandardRoot();
    }

    function testRoot() internal {
        _setStandardRoot();
        console.logBytes32(merkleManager.manageRoot(strategist));
    }

    function testTransferMETHToSymbioticPM() public {
        vm.assertEq(mETH.balanceOf(address(symbioticPM)), 0, "balance incorrect");
        _transferMETHToSymbioticPM();
        vm.assertEq(mETH.balanceOf(address(symbioticPM)), 1e18, "balance incorrect");
    }

    function testDepositFromSymbioticPM() public {

        uint expectNewShares = _depositFromSymbioticPM();
        vm.assertEq(mETH.balanceOf(address(symbioticPM)), 0.2 ether, "balance incorrect");
        uint currentShares = vault.activeSharesOf(address(symbioticPM));
        assertEq(currentShares, expectNewShares, "new shares incorrect");
        assertEq(currentShares, 0.8 ether, "share amount incorrect");
    }

    function testWithdraw() public {
        _withdrawFromSymbioticPM();
        uint currentShares = vault.activeSharesOf(address(symbioticPM));
        assertEq(currentShares, 0.4 ether, "shares incorrect");
    }

    function testCompleteWithdraws() public {
        _withdrawFromSymbioticPM();
        uint fourteenDays = 60 * 60 * 24 * 14;
        vm.warp(block.timestamp + fourteenDays);
        _completeWithdraws();
        assertEq(mETH.balanceOf(address(symbioticPM)), 0.6 ether, "balance incorrect");
    }

    function _setStandardRoot() internal {
        vm.prank(merkleManagerOwner);
        merkleManager.setManageRoot(strategist, standardRoot);
    }

    function _transferMETHToSymbioticPM() internal {
        address target = address(mETH);
        string memory funcSignature = "transfer(address,uint256)";
        address[] memory argumentAddress = new address[](1);
        argumentAddress[0] = address(symbioticPM);
        bytes memory data = abi.encode(address(symbioticPM), 1e18);
        _callMerkleManager(target, funcSignature, argumentAddress, data);
    }

    function _depositFromSymbioticPM() internal returns (uint expectNewShares){
        _transferMETHToSymbioticPM();

        address target = address(symbioticPM);
        string memory funcSignature = "deposit(uint256,uint256)";
        address[] memory argumentAddress = new address[](0);
        uint expectDepositAmount = 0.8 ether;
        expectNewShares = _calNewShares(expectDepositAmount);
        bytes memory data = abi.encode(expectDepositAmount, expectNewShares);
        _callMerkleManager(target, funcSignature, argumentAddress, data);
    }

    function _withdrawFromSymbioticPM() internal {
        uint expectNewShares = _depositFromSymbioticPM();

        address target = address(symbioticPM);
        string memory funcSignature = "startWithdrawal(uint256)";
        address[] memory argumentAddress = new address[](0);
        uint withdrawAmount = 0.4 ether;
        bytes memory data = abi.encode(withdrawAmount);
        _callMerkleManager(target, funcSignature, argumentAddress, data);

    }

    function _completeWithdraws() internal {
        address target = address(symbioticPM);
        string memory funcSignature = "completeNextWithdrawals(uint256)";
        address[] memory argumentAddress = new address[](0);
        uint withdrawShares = 0.4 ether;
        bytes memory data = abi.encode(withdrawShares);
        _callMerkleManager(target, funcSignature, argumentAddress, data);
    }

    function _calNewShares(uint amount) internal returns(uint newShares){
        uint activeStake = vault.activeStake();
        uint activeShares = vault.activeShares();
        newShares = Math.mulDiv(amount, activeShares + 1, activeStake + 1, Math.Rounding.Floor);
    }
}