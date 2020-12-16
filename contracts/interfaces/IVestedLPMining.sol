// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

interface IVestedLPMining {
  function users(uint256, address)
    external
    view
    returns (
      uint32,
      uint32,
      uint96,
      uint96,
      uint256
    );

  function poolLength() external view returns (uint256);

  /// @notice Return the amount of pending CVPs entitled to the given user of the pool
  function pendingCvp(uint256 _pid, address _user)
    external
    view
    returns (uint256);

  /// @notice Return the amount of CVP tokens which may be vested to a user of a pool in the current block
  function vestableCvp(uint256 _pid, address user)
    external
    view
    returns (uint256);

  /// @notice Return `true` if the LP Token is added to created pools
  function isLpTokenAdded(IERC20 _lpToken) external view returns (bool);

  /// @notice Deposit the given amount of LP tokens to the given pool
  function deposit(uint256 _pid, uint256 _amount) external;

  /// @notice Withdraw the given amount of LP tokens from the given pool
  function withdraw(uint256 _pid, uint256 _amount) external;

  /// @notice Withdraw LP tokens without caring about pending CVP tokens. EMERGENCY ONLY.
  function emergencyWithdraw(uint256 _pid) external;

  /// @notice Get CVP amount and the share of CVPs in LP pools for the given account and the checkpoint
  function getCheckpoint(address account, uint32 checkpointId)
    external
    view
    returns (
      uint32 fromBlock,
      uint96 cvpAmount,
      uint96 pooledCvpShare
    );

  event AddLpToken(
    address indexed lpToken,
    uint256 indexed pid,
    uint256 allocPoint
  );
  event SetLpToken(
    address indexed lpToken,
    uint256 indexed pid,
    uint256 allocPoint
  );
  event SetMigrator(address indexed migrator);
  event SetCvpPerBlock(uint256 cvpPerBlock);
  event SetCvpVestingPeriodInBlocks(uint256 cvpVestingPeriodInBlocks);
  event SetCvpPoolByMetaPool(address indexed metaPool, address indexed cvpPool);
  event MigrateLpToken(
    address indexed oldLpToken,
    address indexed newLpToken,
    uint256 indexed pid
  );

  event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
  event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
  event EmergencyWithdraw(
    address indexed user,
    uint256 indexed pid,
    uint256 amount
  );

  event CheckpointTotalLpVotes(uint256 lpVotes);
  event CheckpointUserLpVotes(
    address indexed user,
    uint256 indexed pid,
    uint256 lpVotes
  );
  event CheckpointUserVotes(
    address indexed user,
    uint256 pendedVotes,
    uint256 lpVotesShare
  );
}
