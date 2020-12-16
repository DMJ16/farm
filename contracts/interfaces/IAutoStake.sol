// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

// 0x25550Cccbd68533Fa04bFD3e3AC4D09f9e00Fc50
interface IAutoStake {
    function balanceOf(address who) external view returns (uint256);

    function exit() external;

    function stake(uint256 amount) external;
}
