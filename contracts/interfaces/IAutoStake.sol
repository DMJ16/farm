// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

interface IAutoStake {
  function balanceOf(address who) external view returns (uint256);

  function exit() external;

  function stake(uint256 amount) external;
}
