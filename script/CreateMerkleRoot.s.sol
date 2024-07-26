// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.20;

import {BaseMerkleRootGenerator} from "resources/BaseMerkleRootGenerator.sol";
import {FixedPointMathLib} from "@solmate/utils/FixedPointMathLib.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";
import {Strings} from "lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import {ERC4626} from "@solmate/tokens/ERC4626.sol";

/**
 *  source .env && forge script script/CreateMerkleRoot.s.sol:CreateMerkleRootScript --rpc-url $MAINNET_RPC_URL
 */
contract CreateMerkleRootScript is BaseMerkleRootGenerator {
    using FixedPointMathLib for uint256;

    address public boringVault = address(1);
    address public itbDecoderAndSanitizer = address(1);
    address public managerAddress = address(1);
    address public accountantAddress = address(1);

    address public itbKmETHPositionManager = address(1);
    address public itbMETHDefualtCollateralPositionManager = address(1);
    address public itbMETHEigenLayerPositionManager = address(1);

    function setUp() external {}

    /**
     * @notice Uncomment which script you want to run.
     */
    function run() external {
        generateStrategistMerkleRoot();
    }

    function generateStrategistMerkleRoot() public {
        updateAddresses(boringVault, itbDecoderAndSanitizer, managerAddress, accountantAddress);

        ManageLeaf[] memory leafs = new ManageLeaf[](64);

        // ========================== ITB Symbiotic ==========================
        _addLeafsForITBSymbioticPositionManager(
            leafs, itbDecoderAndSanitizer, itbMETHDefualtCollateralPositionManager, mETHDefaultCollateral
        );

        // ========================== ITB Eigen Layer ==========================
        _addLeafsForITBEigenLayerPositionManager(leafs, itbMETHEigenLayerPositionManager, METH, strategyManager);

        // ========================== ITB Karak ==========================
        _addLeafsForITBKarakPositionManager(
            leafs, itbDecoderAndSanitizer, itbKmETHPositionManager, kmETH, vaultSupervisor
        );

        bytes32[][] memory manageTree = _generateMerkleTree(leafs);

        string memory filePath = "./leafs/StrategistLeafs.json";

        _generateLeafs(filePath, leafs, manageTree[manageTree.length - 1][0], manageTree);
    }

    /// @notice Leafs for ITB position managers do not include leafs related to updating the configuration of each position manager.
    /// this is because all Position Managers will be properly configured before ownership transfer to the Boring Vault
    /// and in the event we did need to update a position managers configuration, we would add the new leafs required to do so
    /// in a merkle root update.

    // ========================================= ITB Symbiotic =========================================

    function _addLeafsForITBSymbioticPositionManager(
        ManageLeaf[] memory leafs,
        address _itbDecoderAndSanitizer,
        address positionManager,
        address defaultCollateral
    ) internal {
        ERC4626 dc = ERC4626(defaultCollateral);
        ERC20 underlying = dc.asset();
        // acceptOwnership
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager,
            false,
            "acceptOwnership()",
            new address[](0),
            string.concat("Accept ownership of the ITB Contract: ", vm.toString(positionManager)),
            _itbDecoderAndSanitizer
        );
        // Transfer all tokens to the ITB contract.
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            address(underlying),
            false,
            "transfer(address,uint256)",
            new address[](1),
            string.concat("Transfer ", underlying.symbol(), " to ITB Contract: ", vm.toString(positionManager)),
            _itbDecoderAndSanitizer
        );
        leafs[leafIndex].argumentAddresses[0] = positionManager;
        // Approval Default Collateral to spend underlying.
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager,
            false,
            "approveToken(address,address,uint256)",
            new address[](2),
            string.concat("Approve ", dc.name(), " to spend ", underlying.symbol()),
            _itbDecoderAndSanitizer
        );
        leafs[leafIndex].argumentAddresses[0] = address(underlying);
        leafs[leafIndex].argumentAddresses[1] = defaultCollateral;
        // Withdraw all tokens
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager,
            false,
            "withdraw(address,uint256)",
            new address[](1),
            string.concat("Withdraw ", underlying.symbol(), " from ITB Contract: ", vm.toString(positionManager)),
            _itbDecoderAndSanitizer
        );
        leafs[leafIndex].argumentAddresses[0] = address(underlying);

        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager,
            false,
            "withdrawAll(address)",
            new address[](1),
            string.concat(
                "Withdraw all ", underlying.symbol(), " from the ITB Contract: ", vm.toString(positionManager)
            ),
            _itbDecoderAndSanitizer
        );
        leafs[leafIndex].argumentAddresses[0] = address(underlying);

        // Deposit Collateral.
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager,
            false,
            "depositCollateral(uint256,uint256)",
            new address[](0),
            "Deposit Collateral",
            _itbDecoderAndSanitizer
        );

        // Withdraw Collateral.
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager,
            false,
            "withdrawCollateral(uint256,uint256)",
            new address[](0),
            "Withdraw Collateral",
            _itbDecoderAndSanitizer
        );

        // Assemble
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager, false, "assemble(uint256)", new address[](0), "Assemble", _itbDecoderAndSanitizer
        );

        // Disassemble
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager,
            false,
            "disassemble(uint256,uint256)",
            new address[](0),
            "Disassemble",
            _itbDecoderAndSanitizer
        );

        // Full Disassemble
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager,
            false,
            "fullDisassemble(uint256)",
            new address[](0),
            "Full Disassemble",
            _itbDecoderAndSanitizer
        );
    }
    // ========================================= ITB EigenLayer =========================================

    function _addLeafsForITBEigenLayerPositionManager(
        ManageLeaf[] memory leafs,
        address positionManager,
        ERC20 underlying,
        address strategyManager
    ) internal {
        // acceptOwnership
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager,
            false,
            "acceptOwnership()",
            new address[](0),
            string.concat("Accept ownership of the ITB Contract: ", vm.toString(positionManager)),
            itbDecoderAndSanitizer
        );
        // Transfer all tokens to the ITB contract.
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            address(underlying),
            false,
            "transfer(address,uint256)",
            new address[](1),
            string.concat("Transfer ", underlying.symbol(), " to ITB Contract: ", vm.toString(positionManager)),
            itbDecoderAndSanitizer
        );
        leafs[leafIndex].argumentAddresses[0] = positionManager;
        // Approval Strategy Manager to spend all tokens.
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager,
            false,
            "approveToken(address,address,uint256)",
            new address[](2),
            string.concat("Approve Strategy Manager to spend ", underlying.symbol()),
            itbDecoderAndSanitizer
        );
        leafs[leafIndex].argumentAddresses[0] = address(underlying);
        leafs[leafIndex].argumentAddresses[1] = strategyManager;
        // Withdraw all tokens
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager,
            false,
            "withdraw(address,uint256)",
            new address[](1),
            string.concat("Withdraw ", underlying.symbol(), " from ITB Contract: ", vm.toString(positionManager)),
            itbDecoderAndSanitizer
        );
        leafs[leafIndex].argumentAddresses[0] = address(underlying);

        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager,
            false,
            "withdrawAll(address)",
            new address[](1),
            string.concat(
                "Withdraw all ", underlying.symbol(), " from the ITB Contract: ", vm.toString(positionManager)
            ),
            itbDecoderAndSanitizer
        );
        leafs[leafIndex].argumentAddresses[0] = address(underlying);

        // Delegate
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] =
            ManageLeaf(positionManager, false, "delegate()", new address[](0), "Delegate", itbDecoderAndSanitizer);

        // Undelegate
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] =
            ManageLeaf(positionManager, false, "undelegate()", new address[](0), "Undelegate", itbDecoderAndSanitizer);

        // Deposit
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager, false, "deposit(uint256,uint256)", new address[](0), "Deposit", itbDecoderAndSanitizer
        );

        // Start Withdrawal
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager,
            false,
            "startWithdrawal(uint256)",
            new address[](0),
            "Start Withdrawal",
            itbDecoderAndSanitizer
        );

        // Complete Withdrawal
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager,
            false,
            "completeWithdrawal(uint256,uint256)",
            new address[](0),
            "Complete Withdrawal",
            itbDecoderAndSanitizer
        );

        // Complete Next Withdrawal
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager,
            false,
            "completeNextWithdrawal(uint256)",
            new address[](0),
            "Complete Next Withdrawal",
            itbDecoderAndSanitizer
        );

        // Complete Next Withdrawals
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager,
            false,
            "completeNextWithdrawals(uint256)",
            new address[](0),
            "Complete Next Withdrawals",
            itbDecoderAndSanitizer
        );

        // Override Withdrawal Indexes
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager,
            false,
            "overrideWithdrawalIndexes(uint256,uint256)",
            new address[](0),
            "Override Withdrawal Indexes",
            itbDecoderAndSanitizer
        );

        // Assemble
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager, false, "assemble(uint256)", new address[](0), "Assemble", itbDecoderAndSanitizer
        );

        // Disassemble
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager,
            false,
            "disassemble(uint256,uint256)",
            new address[](0),
            "Disassemble",
            itbDecoderAndSanitizer
        );

        // Full Disassemble
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager,
            false,
            "fullDisassemble(uint256)",
            new address[](0),
            "Full Disassemble",
            itbDecoderAndSanitizer
        );
    }

    // ========================================= ITB Karak =========================================

    function _addLeafsForITBKarakPositionManager(
        ManageLeaf[] memory leafs,
        address _itbDecoderAndSanitizer,
        address positionManager,
        address _karakVault,
        address _vaultSupervisor
    ) internal {
        ERC20 underlying = ERC4626(_karakVault).asset();
        // acceptOwnership
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager,
            false,
            "acceptOwnership()",
            new address[](0),
            string.concat("Accept ownership of the ITB Contract: ", vm.toString(positionManager)),
            _itbDecoderAndSanitizer
        );
        // Transfer all tokens to the ITB contract.
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            address(underlying),
            false,
            "transfer(address,uint256)",
            new address[](1),
            string.concat("Transfer ", underlying.symbol(), " to ITB Contract: ", vm.toString(positionManager)),
            _itbDecoderAndSanitizer
        );
        leafs[leafIndex].argumentAddresses[0] = positionManager;
        // Approval Karak Vault to spend all tokens.
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager,
            false,
            "approveToken(address,address,uint256)",
            new address[](2),
            string.concat("Approve ", ERC20(_karakVault).name(), " to spend ", underlying.symbol()),
            _itbDecoderAndSanitizer
        );
        leafs[leafIndex].argumentAddresses[0] = address(underlying);
        leafs[leafIndex].argumentAddresses[1] = _karakVault;
        // Withdraw all tokens
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager,
            false,
            "withdraw(address,uint256)",
            new address[](1),
            string.concat("Withdraw ", underlying.symbol(), " from ITB Contract: ", vm.toString(positionManager)),
            _itbDecoderAndSanitizer
        );
        leafs[leafIndex].argumentAddresses[0] = address(underlying);

        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager,
            false,
            "withdrawAll(address)",
            new address[](1),
            string.concat(
                "Withdraw all ", underlying.symbol(), " from the ITB Contract: ", vm.toString(positionManager)
            ),
            _itbDecoderAndSanitizer
        );
        leafs[leafIndex].argumentAddresses[0] = address(underlying);
        // Update Vault Supervisor.
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager,
            false,
            "updateVaultSupervisor(address)",
            new address[](1),
            "Update the vault supervisor",
            _itbDecoderAndSanitizer
        );
        leafs[leafIndex].argumentAddresses[0] = _vaultSupervisor;
        // Update position config.
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager,
            false,
            "updatePositionConfig(address,address)",
            new address[](2),
            "Update the position config",
            _itbDecoderAndSanitizer
        );
        leafs[leafIndex].argumentAddresses[0] = address(underlying);
        leafs[leafIndex].argumentAddresses[1] = _karakVault;
        // Deposit
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager, false, "deposit(uint256,uint256)", new address[](0), "Deposit", _itbDecoderAndSanitizer
        );
        // Start Withdrawal
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager,
            false,
            "startWithdrawal(uint256)",
            new address[](0),
            "Start Withdrawal",
            _itbDecoderAndSanitizer
        );
        // Complete Withdrawal
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager,
            false,
            "completeWithdrawal(uint256,uint256)",
            new address[](0),
            "Complete Withdrawal",
            _itbDecoderAndSanitizer
        );
        // Complete Next Withdrawal
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager,
            false,
            "completeNextWithdrawal(uint256)",
            new address[](0),
            "Complete Next Withdrawal",
            _itbDecoderAndSanitizer
        );
        // Complete Next Withdrawals
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager,
            false,
            "completeNextWithdrawals(uint256)",
            new address[](0),
            "Complete Next Withdrawals",
            _itbDecoderAndSanitizer
        );
        // Override Withdrawal Indexes
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager,
            false,
            "overrideWithdrawalIndexes(uint256,uint256)",
            new address[](0),
            "Override Withdrawal Indexes",
            _itbDecoderAndSanitizer
        );
        // Assemble
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager, false, "assemble(uint256)", new address[](0), "Assemble", _itbDecoderAndSanitizer
        );
        // Disassemble
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager,
            false,
            "disassemble(uint256,uint256)",
            new address[](0),
            "Disassemble",
            _itbDecoderAndSanitizer
        );
        // Full Disassemble
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager,
            false,
            "fullDisassemble(uint256)",
            new address[](0),
            "Full Disassemble",
            _itbDecoderAndSanitizer
        );
    }

    // function _addLeafsForITBPositionManager(
    //     ManageLeaf[] memory leafs,
    //     address itbPositionManager,
    //     ERC20[] memory tokensUsed,
    //     string memory itbContractName
    // ) internal {
    //     // acceptOwnership
    //     leafIndex++;
    //     leafs[leafIndex] = ManageLeaf(
    //         itbPositionManager,
    //         false,
    //         "acceptOwnership()",
    //         new address[](0),
    //         string.concat("Accept ownership of the ", itbContractName, " contract"),
    //         itbDecoderAndSanitizer
    //     );
    //     for (uint256 i; i < tokensUsed.length; ++i) {
    //         // Transfer
    //         leafIndex++;
    //         leafs[leafIndex] = ManageLeaf(
    //             address(tokensUsed[i]),
    //             false,
    //             "transfer(address,uint256)",
    //             new address[](1),
    //             string.concat("Transfer ", tokensUsed[i].symbol(), " to the ", itbContractName, " contract"),
    //             itbDecoderAndSanitizer
    //         );
    //         leafs[leafIndex].argumentAddresses[0] = itbPositionManager;
    //         // Withdraw
    //         leafIndex++;
    //         leafs[leafIndex] = ManageLeaf(
    //             itbPositionManager,
    //             false,
    //             "withdraw(address,uint256)",
    //             new address[](1),
    //             string.concat("Withdraw ", tokensUsed[i].symbol(), " from the ", itbContractName, " contract"),
    //             itbDecoderAndSanitizer
    //         );
    //         leafs[leafIndex].argumentAddresses[0] = address(tokensUsed[i]);
    //         // WithdrawAll
    //         leafIndex++;
    //         leafs[leafIndex] = ManageLeaf(
    //             itbPositionManager,
    //             false,
    //             "withdrawAll(address)",
    //             new address[](1),
    //             string.concat("Withdraw all ", tokensUsed[i].symbol(), " from the ", itbContractName, " contract"),
    //             itbDecoderAndSanitizer
    //         );
    //         leafs[leafIndex].argumentAddresses[0] = address(tokensUsed[i]);
    //     }
    // }

    // function _addLeafsForItbReserve(
    //     ManageLeaf[] memory leafs,
    //     address itbPositionManager,
    //     ERC20[] memory tokensUsed,
    //     string memory itbContractName
    // ) internal {
    //     _addLeafsForITBPositionManager(leafs, itbPositionManager, tokensUsed, itbContractName);

    //     // mint
    //     leafIndex++;
    //     leafs[leafIndex] = ManageLeaf(
    //         itbPositionManager,
    //         false,
    //         "mint(uint256)",
    //         new address[](0),
    //         string.concat("Mint ", itbContractName),
    //         itbDecoderAndSanitizer
    //     );

    //     // redeem
    //     leafIndex++;
    //     leafs[leafIndex] = ManageLeaf(
    //         itbPositionManager,
    //         false,
    //         "redeem(uint256,uint256[])",
    //         new address[](0),
    //         string.concat("Redeem ", itbContractName),
    //         itbDecoderAndSanitizer
    //     );

    //     // redeemCustom
    //     leafIndex++;
    //     leafs[leafIndex] = ManageLeaf(
    //         itbPositionManager,
    //         false,
    //         "redeemCustom(uint256,uint48[],uint192[],address[],uint256[])",
    //         new address[](tokensUsed.length),
    //         string.concat("Redeem custom ", itbContractName),
    //         itbDecoderAndSanitizer
    //     );
    //     for (uint256 i; i < tokensUsed.length; ++i) {
    //         leafs[leafIndex].argumentAddresses[i] = address(tokensUsed[i]);
    //     }

    //     // assemble
    //     leafIndex++;
    //     leafs[leafIndex] = ManageLeaf(
    //         itbPositionManager,
    //         false,
    //         "assemble(uint256,uint256)",
    //         new address[](0),
    //         string.concat("Assemble ", itbContractName),
    //         itbDecoderAndSanitizer
    //     );

    //     // disassemble
    //     leafIndex++;
    //     leafs[leafIndex] = ManageLeaf(
    //         itbPositionManager,
    //         false,
    //         "disassemble(uint256,uint256[])",
    //         new address[](0),
    //         string.concat("Disassemble ", itbContractName),
    //         itbDecoderAndSanitizer
    //     );

    //     // fullDisassemble
    //     leafIndex++;
    //     leafs[leafIndex] = ManageLeaf(
    //         itbPositionManager,
    //         false,
    //         "fullDisassemble(uint256[])",
    //         new address[](0),
    //         string.concat("Full disassemble ", itbContractName),
    //         itbDecoderAndSanitizer
    //     );
    // }
}
