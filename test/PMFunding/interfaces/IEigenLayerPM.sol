// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

interface IEigenLayerPM {
    struct PositionConfig {
        address liquid_staking;
        address underlying;
        address delegate_to;
    }

    struct Withdrawal {
        address staker;
        address delegatedTo;
        address withdrawer;
        uint256 nonce;
        uint32 startBlock;
        address[] strategies;
        uint256[] scaledShares;
    }

    struct QueuedWithdrawal {
        uint withdrawal_block;
        address[] tokens;
        Withdrawal withdrawal;
    }

    function positionConfig() external view returns(PositionConfig memory);
    function owner() external view virtual returns (address);
    function updatePositionConfig(address _liquid_staking, address _underlying, address _delegate_to) external;
    function getUnderlyings() external view returns (address[] memory assets, uint[] memory amounts);
    function strategyManager() external view returns(address);
    function delegationManager() external view returns(address);
    function rewardsCoordinator() external view returns(address);
    function delegateWithSignature(bytes memory _signature, uint _expiry, bytes32 _salt) external;
    function undelegate() external;
    function deposit(uint _amount, uint _min_lpt_out) external;
    function startWithdrawal(uint _shares_amount) external;
    function withdrawalQueue(uint index) external view returns(QueuedWithdrawal memory);
    function cumulativeWithdrawalsQueued() external view returns(uint);
    function completeNextWithdrawal(uint _min_out) external returns (uint lpt_burnt, uint coin_out);
}
