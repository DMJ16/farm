// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

interface IMasterChef {
  function deposit(uint256 _pid, uint256 _amount) external;

  function emergencyWithdraw(uint256 _pid) external;

  function getMultiplier(uint256 _from, uint256 _to)
    external
    view
    returns (uint256);

  function pendingPickle(uint256 _pid, address _user)
    external
    view
    returns (uint256);

  function pickle() external view returns (address);

  function userInfo(uint256, address)
    external
    view
    returns (uint256 amount, uint256 rewardDebt);

  function withdraw(uint256 _pid, uint256 _amount) external;
}
