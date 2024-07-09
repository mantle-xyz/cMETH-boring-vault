// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
//
//import {console2 as console} from "forge-std/console2.sol";
//import {ERC20} from "openzeppelin/token/ERC20/ERC20.sol";
//import {Test} from "forge-std/Test.sol";
//
//import {deployAll, grantAndRenounceAllRoles, DeploymentParams, Deployments} from "../script/helpers/Proxy.sol";
//import {IRewardTranche} from "../src/interfaces/IRewardTranche.sol";
//import {ReentrancyForwarder} from "./utils/Reentrancy.sol";
//import {RewardTranche} from "../src/StandardTranche.sol";
//import {SignerUtils} from "./utils/SignerUtils.sol";
//import {Staking} from "../src/MNTStaking.sol";
import {BaseTest} from "./BaseTest.sol";
//import {RewardTranche} from "./StandardTranche.t.sol";
//
//
contract IntegrationTest is BaseTest {
//
//    DeploymentParams public dps;
//    Deployments public ds;
//
//    function setUp() public virtual {
//        dps = deploymentParams();
//        vm.startPrank(deployer);
//        ds = deployAll(dps, deployer);
//        vm.stopPrank();
//        logDeployments(ds);
//    }
//
//    function logDeployments(Deployments memory deps) public pure {
//        console.log("Deployments:");
//        console.log("ProxyAdmin: %s", address(deps.proxyAdmin));
//        console.log("Staking: %s", address(deps.mntStaking));
//        console.log("TrancheManager: %s", address(deps.trancheManager));
//        console.log("AllocateUnits: %s", address(deps.allocateUnits));
//        console.log("L1BlockInfo: %s", address(deps.l1BlockInfo));
//        console.log("Pauser: %s", address(deps.pauser));
//        console.log("VMNT: %s", address(deps.vMNT));
//    }
//}
//
//contract BasicTest is IntegrationTest {
////    IRewardTranche.TrancheConfig public config = IRewardTranche.TrancheConfig({
////        staking: address(ds.mntStaking),
////        allocateUnits: address(ds.allocateUints),
////        rewardToken: address(rewardTokenERC20),
////        pauser: address(ds.pauser),
////        l1Block: address(ds.l1BlockInfo),
////        cooldown: 10, // 1 day in seconds
////        totalRewards: 1e18,
////        minAllocateUnits: 100,
////        totalRewardUnits: 10000,
////        startTime: block.timestamp,
////        endTime: block.timestamp + 30 days
////    });
////
////    IRewardTranche.MetaData public metaData = IRewardTranche.MetaData({
////        trancheName: "Example Tranche",
////        trancheDescription: "Example tranche.",
////        projectName: "Project wMNT",
////        externalLinks: "https://",
////        imageIPFSlinks: "ipfs://"
////    });
//
//    function testIntegration() public {
////        address rewardTranche = makeAddr("rewardTranche");
////        // create tranche and set up
////
////        // stake
////
////        // allocate
////
////        // claim
////
////        // unallocate
////
////        // unstake
////
////        address alice = makeAddr("alice");
////        console.log("========alice=======");
////        console.log(alice);
////        uint256 stakeAmount = 1 ether;
////        uint256 minUnits = 100;
////        uint256 maxUnits = 10000 ether;
////        vm.deal(alice, stakeAmount);
////        // 1. Stake
////        vm.startPrank(alice);
////        ds.mntStaking.stake{value: stakeAmount}(stakeAmount, minUnits);
////
////        // 2. Allocate
////        uint256 amountToAllocate = 1000;
////        ds.allocateUints.approve(address(rewardTranche),amountToAllocate);
////        ds.mntStaking.allocate(trancheID, amountToAllocate);
////
////        skip(1 days);
////
////        // 3. Claim Rewards
////        ds.mntStaking.claim(trancheID);
////
////        // 4. Unallocate
////        ds.mntStaking.unallocate(trancheID, amountToAllocate);
////
////        // 5. Unstake
////        uint256 amountToUnstake = stakeAmount;
////        // console.log(ds.allocateUints.totalSupply());
////        ds.mntStaking.unstake(100, 100);
////        vm.stopPrank();
//
//        // assertEq(ds.staking.unallocatedETH(), 32 ether + 9 ether + 0.0009 ether);
//    }
//}
//
//contract PausingTest is IntegrationTest {
//
//}
//
//contract WithStateTest is IntegrationTest {
//
//}
//
//contract ReentrancyTest is WithStateTest {
//    // claim
//
//    // allocate unallocate
//
//    // stake unstake
//
//}
//
//contract BoundaryTest is WithStateTest {
//    //
//}
//
//contract TransferAllowListTest is WithStateTest {
//    //
//}
//
//contract RoleTransferTest is IntegrationTest {
//    uint256 public constant NUM_CONTRACTS = 8;
//
////    function setUp() public virtual override {
////        vm.roll(DEPLOY_BLOCK_NUMBER);
////        depositContract = deployDepositContract();
////    }
////
////    struct StorageValue {
////        address target;
////        bytes32 slot;
////        bytes32 value;
////    }
////
////    function _readWriteSlots(address c) internal returns (StorageValue[] memory) {
////        (bytes32[] memory readSlots, bytes32[] memory writeSlots) = vm.accesses(c);
////        StorageValue[] memory svals = new StorageValue[](readSlots.length + writeSlots.length);
////
////        for (uint256 i = 0; i < readSlots.length; i++) {
////            bytes32 slot = readSlots[i];
////            svals[i] = StorageValue({target: c, slot: slot, value: vm.load(c, slot)});
////        }
////
////        for (uint256 i = 0; i < writeSlots.length; i++) {
////            bytes32 slot = writeSlots[i];
////            svals[readSlots.length + i] = StorageValue({target: c, slot: slot, value: vm.load(c, slot)});
////        }
////
////        return svals;
////    }
////
////    function _readWriteSlots(address[NUM_CONTRACTS] memory cs)
////    internal
////    returns (StorageValue[][NUM_CONTRACTS] memory)
////    {
////        StorageValue[][NUM_CONTRACTS] memory svals;
////        for (uint256 i = 0; i < NUM_CONTRACTS; i++) {
////            svals[i] = _readWriteSlots(cs[i]);
////        }
////        return svals;
////    }
////
////    function assertStorage(StorageValue[] memory svals) internal {
////        for (uint256 i = 0; i < svals.length; i++) {
////            bytes32 v = vm.load(svals[i].target, svals[i].slot);
////            assertEq(
////                svals[i].value,
////                v,
////                string.concat(
////                    "Storage slot changed: target=", vm.toString(svals[i].target), " slot=", vm.toString(svals[i].slot)
////                )
////            );
////        }
////    }
////
////    function assertStorage(StorageValue[][NUM_CONTRACTS] memory svals) internal {
////        for (uint256 i = 0; i < svals.length; i++) {
////            assertStorage(svals[i]);
////        }
////    }
////
////    function _deployWithDistinctAddresses() internal returns (Deployments memory) {
////        vm.startPrank(deployer);
////        Deployments memory ds_ = deployAll(_deploymentParams(), deployer);
////        vm.stopPrank();
////        return ds_;
////    }
////
////    function _deployWithSameAddressThenChange() internal returns (Deployments memory) {
////        vm.startPrank(deployer);
////        Deployments memory ds_ = deployAll(
////            DeploymentParams({
////                admin: deployer,
////                upgrader: deployer,
////                manager: deployer,
////                pauser: deployer,
////                unpauser: deployer,
////                allocatorService: allocator,
////                initiatorService: initiator,
////                requestCanceller: deployer,
////                pendingResolver: deployer,
////                depositContract: address(depositContract),
////                reporterModifier: deployer,
////                reporters: _deploymentParams().reporters,
////                feesReceiver: feesReceiver
////            }),
////            deployer
////        );
////        grantAndRenounceAllRoles(_deploymentParams(), ds_, deployer);
////        vm.stopPrank();
////
////        return ds_;
////    }
////
////    function testStorageSlots() public {
////        uint256 snap = vm.snapshot();
////        vm.record();
////
////        ds = _deployWithDistinctAddresses();
////
////        // Omitting the TimelockController proxyAdmin here because storage slots relating to the executed transactions
////        // are expected to differ. We will check the TimelockController roles separately.
////        address[NUM_CONTRACTS] memory contracts = [
////                        address(ds.staking),
////                        address(ds.mETH),
////                        address(ds.oracle),
////                        address(ds.quorumManager),
////                        address(ds.unstakeRequestsManager),
////                        address(ds.consensusLayerReceiver),
////                        address(ds.executionLayerReceiver),
////                        address(ds.aggregator)
////            ];
////
////        // storing the storage values in memory before reverting because memory is not cleared on revert.
////        StorageValue[][NUM_CONTRACTS] memory svals = _readWriteSlots(contracts);
////
////        // Reverting resets the state of the VM, meaning the all previously deployed contracts and storage will be gone,
////        // and nonces reset. This means that running deployAll again, will deploy the contracts at the same addresses
////        // again.
////        vm.revertTo(snap);
////        snap = vm.snapshot();
////
////        _deployWithSameAddressThenChange();
////
////        // Checking that all storage values that were touched by _deployWithDistinctAddresses still have the same value.
////        assertStorage(svals);
////
////        // Restarting again to check the value of any storage slots that were additionally touched by
////        // _deployWithSameAddressThenChange.
////        svals = _readWriteSlots(contracts);
////        vm.revertTo(snap);
////
////        _deployWithDistinctAddresses();
////        assertStorage(svals);
////    }
////
////    function testTimelockControllerRolesWithDistinctAddresses() public {
////        ds = _deployWithDistinctAddresses();
////        _checkTimelockControllerRoles();
////    }
////
////    function testTimelockControllerRolesWithSameAddress() public {
////        ds = _deployWithSameAddressThenChange();
////        _checkTimelockControllerRoles();
////    }
////
////    function _checkTimelockControllerRoles() internal {
////        assertFalse(ds.proxyAdmin.hasRole(ds.proxyAdmin.TIMELOCK_ADMIN_ROLE(), deployer));
////        assertFalse(ds.proxyAdmin.hasRole(ds.proxyAdmin.PROPOSER_ROLE(), deployer));
////        assertFalse(ds.proxyAdmin.hasRole(ds.proxyAdmin.EXECUTOR_ROLE(), deployer));
////        assertFalse(ds.proxyAdmin.hasRole(ds.proxyAdmin.CANCELLER_ROLE(), deployer));
////
////        assertTrue(ds.proxyAdmin.hasRole(ds.proxyAdmin.TIMELOCK_ADMIN_ROLE(), admin));
////        assertTrue(ds.proxyAdmin.hasRole(ds.proxyAdmin.PROPOSER_ROLE(), upgrader));
////        assertTrue(ds.proxyAdmin.hasRole(ds.proxyAdmin.EXECUTOR_ROLE(), upgrader));
////        assertTrue(ds.proxyAdmin.hasRole(ds.proxyAdmin.CANCELLER_ROLE(), upgrader));
////    }
}
