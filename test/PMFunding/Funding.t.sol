// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "@forge-std/Test.sol";
import "./CallMerkleManager.sol";
import {IEigenLayerPM} from "./interfaces/IEigenLayerPM.sol";
import {IMETH} from "./interfaces/IMETH.sol";
import "./interfaces/IStrategy.sol";
import "./interfaces/IStrategyManager.sol";

contract FundingTest is Test, CallMerkleManager {
    bytes32 public standardRoot = 0x1c507dd81e210ab113f5aaa7a363080c5c459dd652ca51f94e23eb21fe9862ca;
    address public merkleManagerOwner = 0x849738999Ba1F3D995d28bDB35efA2E47B4c8203;
    IStrategy public mETHStrategy = IStrategy(0x298aFB19A105D59E74658C4C334Ff360BadE6dd2);
    IStrategyManager public strategyManager = IStrategyManager(0x858646372CC42E1A627fcE94aa7A7033e7CF075A);
    IEigenLayerPM public eigenPM_p2p = IEigenLayerPM(0x0b5d15445B715bF117ba0482B7A9f772AF46d93A);

    IMETH public mETH = IMETH(0xd5F7838F5C461fefF7FE49ea5ebaF7728bB0ADfa);

    function setUp() public {
        _setStandardRoot();
    }

    function testRoot() internal {
        _setStandardRoot();
        console.logBytes32(merkleManager.manageRoot(strategist));
    }

    function testTransferMETHToEigenPM_p2p() public {
        vm.assertEq(mETH.balanceOf(address(eigenPM_p2p)), 0, "balance incorrect");
        _transferMETHToEigenPM_p2p();
       vm.assertEq(mETH.balanceOf(address(eigenPM_p2p)), 1e18, "balance incorrect");
    }

    function testDepositFromEigenPM_p2p() public {

        uint expectNewShares = _depositFromEigenPM_p2p();
        vm.assertEq(mETH.balanceOf(address(eigenPM_p2p)), 0.2 ether, "balance incorrect");
        uint currentShares = strategyManager.stakerDepositShares(address(eigenPM_p2p), address(mETHStrategy));
        assertEq(currentShares, expectNewShares, "new shares incorrect");
        assertEq(currentShares, 0.8 ether, "share amount incorrect");
    }

    function testWithdraw() public {
        _withdrawFromEigenPM_p2p();
        uint currentShares = strategyManager.stakerDepositShares(address(eigenPM_p2p), address(mETHStrategy));
        assertEq(currentShares, 0.4 ether, "shares incorrect");
    }

    function testCompleteWithdraws() public {
        _withdrawFromEigenPM_p2p();
        uint fifteenDayBlocks = 60 * 60 * 24 * 15 / 12;
        vm.roll(block.number + fifteenDayBlocks);
        _completeWithdraws();
        assertEq(mETH.balanceOf(address(eigenPM_p2p)), 0.6 ether, "balance incorrect");
    }

    function _completeWithdraws() internal {
        address target = address(eigenPM_p2p);
        string memory funcSignature = "completeNextWithdrawals(uint256)";
        address[] memory argumentAddress = new address[](0);
        uint withdrawShares = 0.4 ether;
        bytes memory data = abi.encode(withdrawShares);
        _callMerkleManager(target, funcSignature, argumentAddress, data);
    }

    function _withdrawFromEigenPM_p2p() internal {
        uint expectNewShares = _depositFromEigenPM_p2p();

        address target = address(eigenPM_p2p);
        string memory funcSignature = "startWithdrawal(uint256)";
        address[] memory argumentAddress = new address[](0);
        uint withdrawAmount = 0.4 ether;
        bytes memory data = abi.encode(withdrawAmount);
        _callMerkleManager(target, funcSignature, argumentAddress, data);

    }

    function _depositFromEigenPM_p2p() internal returns (uint expectNewShares){
        _transferMETHToEigenPM_p2p();

        address target = address(eigenPM_p2p);
        string memory funcSignature = "deposit(uint256,uint256)";
        address[] memory argumentAddress = new address[](0);
        uint expectDepositAmount = 0.8 ether;
        expectNewShares = _calEigenNewShares(address(eigenPM_p2p), expectDepositAmount);
        bytes memory data = abi.encode(expectDepositAmount, expectNewShares);
        _callMerkleManager(target, funcSignature, argumentAddress, data);
    }

    function _transferMETHToEigenPM_p2p() internal {
        address target = address(mETH);
        string memory funcSignature = "transfer(address,uint256)";
        address[] memory argumentAddress = new address[](1);
        argumentAddress[0] = address(eigenPM_p2p);
        bytes memory data = abi.encode(address(eigenPM_p2p), 1e18);
        _callMerkleManager(target, funcSignature, argumentAddress, data);
        mETH.balanceOf(address(eigenPM_p2p));
    }

    function _setStandardRoot() internal {
        vm.prank(merkleManagerOwner);
        merkleManager.setManageRoot(strategist, standardRoot);
    }

    function _calEigenNewShares(address PM, uint amount) internal view returns(uint newShares){
        uint totalShares = mETHStrategy.totalShares();
        totalShares += 1e3;
        uint strategyBalance = mETH.balanceOf(address(mETHStrategy));
        strategyBalance += 1e3;
        newShares = (amount * totalShares) / strategyBalance;
    }
}