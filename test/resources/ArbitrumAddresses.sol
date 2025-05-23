// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.20;

import {ERC20} from "@solmate/tokens/ERC20.sol";

contract ArbitrumAddresses {
    // Liquid Ecosystem
    address public deployerAddress = 0x5F2F11ad8656439d5C14d9B351f8b09cDaC2A02d;
    address public dev0Address = 0x0463E60C7cE10e57911AB7bD1667eaa21de3e79b;
    address public dev1Address = 0x2322ba43eFF1542b6A7bAeD35e66099Ea0d12Bd1;
    address public liquidPayoutAddress = 0xA9962a5BfBea6918E958DeE0647E99fD7863b95A;

    // DeFi Ecosystem
    address public ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public uniV3Router = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address public uniV2Router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public uniswapV3NonFungiblePositionManager = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;
    address public ccipRouter = 0x141fa059441E0ca23ce184B6A78bafD2A517DdE8;

    ERC20 public USDC = ERC20(0xaf88d065e77c8cC2239327C5EDb3A432268e5831);
    ERC20 public USDCe = ERC20(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8);
    ERC20 public WETH = ERC20(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);
    ERC20 public WBTC = ERC20(0x2f2a2543B76A4166549F7aaB2e75Bef0aefC5B0f);
    ERC20 public USDT = ERC20(0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9);
    ERC20 public DAI = ERC20(0xDA10009cBd5D07dd0CeCc66161FC93D7c9000da1);
    ERC20 public WSTETH = ERC20(0x5979D7b546E38E414F7E9822514be443A4800529);
    ERC20 public FRAX = ERC20(0x17FC002b466eEc40DaE837Fc4bE5c67993ddBd6F);
    ERC20 public BAL = ERC20(0x040d1EdC9569d4Bab2D15287Dc5A4F10F56a56B8);
    ERC20 public COMP = ERC20(0x354A6dA3fcde098F8389cad84b0182725c6C91dE);
    ERC20 public LINK = ERC20(0xf97f4df75117a78c1A5a0DBb814Af92458539FB4);
    ERC20 public rETH = ERC20(0xEC70Dcb4A1EFa46b8F2D97C310C9c4790ba5ffA8);
    ERC20 public cbETH = ERC20(0x1DEBd73E752bEaF79865Fd6446b0c970EaE7732f);
    ERC20 public LUSD = ERC20(0x93b346b6BC2548dA6A1E7d98E9a421B42541425b);
    ERC20 public UNI = ERC20(0xFa7F8980b0f1E64A2062791cc3b0871572f1F7f0);
    ERC20 public CRV = ERC20(0x11cDb42B0EB46D95f990BeDD4695A6e3fA034978);
    ERC20 public FRXETH = ERC20(0x178412e79c25968a32e89b11f63B33F733770c2A);
    ERC20 public ARB = ERC20(0x912CE59144191C1204E64559FE8253a0e49E6548);
    ERC20 public WEETH = ERC20(0x35751007a407ca6FEFfE80b3cB397736D2cf4dbe);

    // Aave V3 Tokens
    ERC20 public aV3USDC = ERC20(0x724dc807b04555b71ed48a6896b6F41593b8C637);
    ERC20 public dV3USDC = ERC20(0xf611aEb5013fD2c0511c9CD55c7dc5C1140741A6);
    ERC20 public aV3USDCe = ERC20(0x625E7708f30cA75bfd92586e17077590C60eb4cD);
    ERC20 public dV3USDCe = ERC20(0xFCCf3cAbbe80101232d343252614b6A3eE81C989);
    ERC20 public aV3WETH = ERC20(0xe50fA9b3c56FfB159cB0FCA61F5c9D750e8128c8);
    ERC20 public dV3WETH = ERC20(0x0c84331e39d6658Cd6e6b9ba04736cC4c4734351);
    ERC20 public aV3WBTC = ERC20(0x078f358208685046a11C85e8ad32895DED33A249);
    ERC20 public dV3WBTC = ERC20(0x92b42c66840C7AD907b4BF74879FF3eF7c529473);
    ERC20 public aV3USDT = ERC20(0x6ab707Aca953eDAeFBc4fD23bA73294241490620);
    ERC20 public dV3USDT = ERC20(0xfb00AC187a8Eb5AFAE4eACE434F493Eb62672df7);
    ERC20 public aV3DAI = ERC20(0x82E64f49Ed5EC1bC6e43DAD4FC8Af9bb3A2312EE);
    ERC20 public dV3DAI = ERC20(0x8619d80FB0141ba7F184CbF22fd724116D9f7ffC);
    ERC20 public aV3WSTETH = ERC20(0x513c7E3a9c69cA3e22550eF58AC1C0088e918FFf);
    ERC20 public dV3WSTETH = ERC20(0x77CA01483f379E58174739308945f044e1a764dc);
    ERC20 public aV3FRAX = ERC20(0x38d693cE1dF5AaDF7bC62595A37D667aD57922e5);
    ERC20 public dV3FRAX = ERC20(0x5D557B07776D12967914379C71a1310e917C7555);
    ERC20 public aV3LINK = ERC20(0x191c10Aa4AF7C30e871E70C95dB0E4eb77237530);
    ERC20 public dV3LINK = ERC20(0x953A573793604aF8d41F306FEb8274190dB4aE0e);
    ERC20 public aV3rETH = ERC20(0x8Eb270e296023E9D92081fdF967dDd7878724424);
    ERC20 public dV3rETH = ERC20(0xCE186F6Cccb0c955445bb9d10C59caE488Fea559);
    ERC20 public aV3LUSD = ERC20(0x8ffDf2DE812095b1D19CB146E4c004587C0A0692);
    ERC20 public dV3LUSD = ERC20(0xA8669021776Bc142DfcA87c21b4A52595bCbB40a);
    ERC20 public aV3ARB = ERC20(0x6533afac2E7BCCB20dca161449A13A32D391fb00);
    ERC20 public dV3ARB = ERC20(0x44705f578135cC5d703b4c9c122528C73Eb87145);

    address public balancerVault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
}
