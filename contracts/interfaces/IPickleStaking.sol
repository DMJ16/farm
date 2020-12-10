// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

interface IPickleStaking {
  function approve(address spender, uint256 amount) external returns (bool);

  function balanceOf(address account) external view returns (uint256);

  function deposit(uint256 _amount) external;

  function depositAll() external;

  function withdrawAll() external;
}
