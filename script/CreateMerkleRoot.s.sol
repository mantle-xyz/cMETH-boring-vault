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

    address public boringVault = 0x33272D40b247c4cd9C646582C9bbAD44e85D4fE4;
    address public itbDecoderAndSanitizer = 0x31b6f06F2c12bd288ad6aaD7073f21CB57349F74;
    address public itbDecoderAndSanitizerWithRemoveExecutor = 0x310fc2403b0D12Fc6dE088B96DA9ac7399D872Ee;
    address public managerAddress = 0xAEC02407cBC7Deb67ab1bbe4B0d49De764878bCE;
    address public accountantAddress = 0x6049Bd892F14669a4466e46981ecEd75D610a2eC;
    address public delayedWithdrawer = 0x12Be34bE067Ebd201f6eAf78a861D90b2a66B113;

    address public itbKmETHPositionManager = 0x52EA8E95378d01B0aaD3B034Ca0656b0F0cc21A2;
    address public itbMETHDefualtCollateralPositionManager = 0x919531146f9a25dFC161D5AB23B117FeAE2c1d36;

    address public itbMETHEigenLayerPositionManager = 0x6DfbE3A1a0e835C125EEBb7712Fffc36c4D93b25;
    address public itbMETHEigenLayerPositionManager2 = 0x021180A06Aa65A7B5fF891b5C146FbDaFC06e2DA;

    // 0x70D7fDF5daAB1224a5cf8959A098C363C15a4Ff6    mantle cmeth karak
    // 0x2716F30a61e129dBA9EEad063C7F0644288d0500    mantle cmeth symbiotic
    // 0x51Ae6ff253D59B096cA46aAfe5EE29B22613b03f    mantle cmeth eigenlayer

    function setUp() external {}

    /**
     * @notice Uncomment which script you want to run.
     */
    function run() external {
        // generateStrategistMerkleRoot();
        // generateSetupMerkleRoot();
        generateExecutorMerkleRoot();
    }

    function generateExecutorMerkleRoot() public {
        updateAddresses(boringVault, itbDecoderAndSanitizerWithRemoveExecutor, managerAddress, accountantAddress);

        ManageLeaf[] memory leafs = new ManageLeaf[](4);

        leafIndex = type(uint256).max;

        _addRemoveExecutorLeaf(leafs, itbKmETHPositionManager, 0x70D7fDF5daAB1224a5cf8959A098C363C15a4Ff6);
        _addRemoveExecutorLeaf(
            leafs, itbMETHDefualtCollateralPositionManager, 0x2716F30a61e129dBA9EEad063C7F0644288d0500
        );
        _addRemoveExecutorLeaf(leafs, itbMETHEigenLayerPositionManager, 0x51Ae6ff253D59B096cA46aAfe5EE29B22613b03f);
        _addRemoveExecutorLeaf(leafs, itbMETHEigenLayerPositionManager2, 0x51Ae6ff253D59B096cA46aAfe5EE29B22613b03f);

        bytes32[][] memory manageTree = _generateMerkleTree(leafs);

        string memory filePath = "./leafs/ExecutorLeafs.json";

        _generateLeafs(filePath, leafs, manageTree[manageTree.length - 1][0], manageTree);
    }

    function generateSetupMerkleRoot() public {
        updateAddresses(boringVault, itbDecoderAndSanitizer, managerAddress, accountantAddress);

        ManageLeaf[] memory leafs = new ManageLeaf[](8);

        leafIndex = type(uint256).max;

        // ========================== ITB Symbiotic ==========================
        _addLeafsForITBSymbioticPositionManager(
            leafs, itbDecoderAndSanitizer, itbMETHDefualtCollateralPositionManager, mETHDefaultCollateral, true
        );

        // ========================== ITB Eigen Layer ==========================
        _addLeafsForITBEigenLayerPositionManager(leafs, itbMETHEigenLayerPositionManager, METH, strategyManager, true);
        _addLeafsForITBEigenLayerPositionManager(leafs, itbMETHEigenLayerPositionManager2, METH, strategyManager, true);

        // ========================== ITB Karak ==========================
        _addLeafsForITBKarakPositionManager(leafs, itbDecoderAndSanitizer, itbKmETHPositionManager, kmETH, true);

        bytes32[][] memory manageTree = _generateMerkleTree(leafs);

        string memory filePath = "./leafs/SetupLeafs.json";

        _generateLeafs(filePath, leafs, manageTree[manageTree.length - 1][0], manageTree);
    }

    function generateStrategistMerkleRoot() public {
        updateAddresses(boringVault, itbDecoderAndSanitizer, managerAddress, accountantAddress);

        ManageLeaf[] memory leafs = new ManageLeaf[](32);

        // ========================== Withdraw Logic ==========================

        // Transfer mETH to the delayed withdrawer contract.
        leafs[leafIndex] = ManageLeaf(
            address(METH),
            false,
            "transfer(address,uint256)",
            new address[](1),
            "Transfer mETH to the delayed withdrawer contract",
            itbDecoderAndSanitizer
        );
        leafs[leafIndex].argumentAddresses[0] = delayedWithdrawer;

        // Call withdrawNonBoringToken on the delayed withdrawer.
        leafIndex++;
        leafs[leafIndex] = ManageLeaf(
            delayedWithdrawer,
            false,
            "withdrawNonBoringToken(address,uint256)",
            new address[](1),
            "Call withdrawNonBoringToken on the delayed withdrawer",
            itbDecoderAndSanitizer
        );
        leafs[leafIndex].argumentAddresses[0] = address(METH);

        // ========================== ITB Symbiotic ==========================
        _addLeafsForITBSymbioticPositionManager(
            leafs, itbDecoderAndSanitizer, itbMETHDefualtCollateralPositionManager, mETHDefaultCollateral, false
        );

        // ========================== ITB Eigen Layer ==========================
        _addLeafsForITBEigenLayerPositionManager(leafs, itbMETHEigenLayerPositionManager, METH, strategyManager, false);
        _addLeafsForITBEigenLayerPositionManager(leafs, itbMETHEigenLayerPositionManager2, METH, strategyManager, false);

        // ========================== ITB Karak ==========================
        _addLeafsForITBKarakPositionManager(leafs, itbDecoderAndSanitizer, itbKmETHPositionManager, kmETH, false);

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
        address defaultCollateral,
        bool isSetup
    ) internal {
        ERC4626 dc = ERC4626(defaultCollateral);
        ERC20 underlying = dc.asset();
        if (isSetup) {
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
        } else {
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
        }
    }

    // ========================================= ITB EigenLayer =========================================

    function _addLeafsForITBEigenLayerPositionManager(
        ManageLeaf[] memory leafs,
        address positionManager,
        ERC20 underlying,
        address strategyManager,
        bool isSetup
    ) internal {
        if (isSetup) {
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

            // Delegate
            unchecked {
                leafIndex++;
            }
            leafs[leafIndex] = ManageLeaf(
                positionManager,
                false,
                "delegateWithSignature(bytes,uint256,bytes32)",
                new address[](0),
                "Delegate with signature",
                itbDecoderAndSanitizer
            );

            // Undelegate
            unchecked {
                leafIndex++;
            }
            leafs[leafIndex] = ManageLeaf(
                positionManager, false, "undelegate()", new address[](0), "Undelegate", itbDecoderAndSanitizer
            );
        } else {
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
        }
    }

    // ========================================= ITB Karak =========================================

    function _addLeafsForITBKarakPositionManager(
        ManageLeaf[] memory leafs,
        address _itbDecoderAndSanitizer,
        address positionManager,
        address _karakVault,
        bool isSetup
    ) internal {
        ERC20 underlying = ERC4626(_karakVault).asset();
        if (isSetup) {
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
        } else {
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
        }
    }

    function _addRemoveExecutorLeaf(ManageLeaf[] memory leafs, address positionManager, address executorToRemove)
        internal
    {
        unchecked {
            leafIndex++;
        }
        leafs[leafIndex] = ManageLeaf(
            positionManager,
            false,
            "removeExecutor(address)",
            new address[](1),
            string.concat(
                "Remove executor: ", vm.toString(executorToRemove), " from ITB Contract: ", vm.toString(positionManager)
            ),
            itbDecoderAndSanitizer
        );
        leafs[leafIndex].argumentAddresses[0] = executorToRemove;
    }
}
