// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @title RewardsVault — pull-based staking rewards for Mantle
/// @notice Stakers deposit MNT; the owner funds reward epochs; stakers pull
///         their accrued rewards. Effects always precede interactions.
contract RewardsVault {
    address public immutable owner;
    uint256 public accRewardPerShare;
    uint256 public totalStaked;

    mapping(address => uint256) public staked;
    mapping(address => uint256) public rewardDebt;

    error NotOwner();
    error ZeroAmount();
    error NothingToClaim();
    error TransferFailed();

    event Staked(address indexed user, uint256 amount);
    event Funded(uint256 amount);
    event Claimed(address indexed user, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    function stake() external payable {
        if (msg.value == 0) revert ZeroAmount();
        staked[msg.sender] += msg.value;
        totalStaked += msg.value;
        rewardDebt[msg.sender] = (staked[msg.sender] * accRewardPerShare) / 1e18;
        emit Staked(msg.sender, msg.value);
    }

    /// @notice Fund the next reward epoch, distributed pro-rata per share.
    function fundEpoch() external payable {
        if (msg.sender != owner) revert NotOwner();
        if (msg.value == 0 || totalStaked == 0) revert ZeroAmount();
        accRewardPerShare += (msg.value * 1e18) / totalStaked;
        emit Funded(msg.value);
    }

    function pendingRewards(address user) public view returns (uint256) {
        return (staked[user] * accRewardPerShare) / 1e18 - rewardDebt[user];
    }

    function claim() external {
        uint256 amount = pendingRewards(msg.sender);
        if (amount == 0) revert NothingToClaim();
        rewardDebt[msg.sender] = (staked[msg.sender] * accRewardPerShare) / 1e18;
        (bool ok, ) = msg.sender.call{value: amount}("");
        if (!ok) revert TransferFailed();
        emit Claimed(msg.sender, amount);
    }
}
