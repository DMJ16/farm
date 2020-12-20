// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

interface IOneSplit {
  function getExpectedReturn(
    IERC20 fromToken,
    IERC20 destToken,
    uint256 amount,
    uint256 parts,
    uint256 flags // See constants in IOneSplit.sol
  ) external view returns (uint256 returnAmount, uint256[] memory distribution);

  function getExpectedReturnWithGas(
    IERC20 fromToken,
    IERC20 destToken,
    uint256 amount,
    uint256 parts,
    uint256 flags, // See constants in IOneSplit.sol
    uint256 destTokenEthPriceTimesGasPrice
  )
    external
    view
    returns (
      uint256 returnAmount,
      uint256 estimateGasAmount,
      uint256[] memory distribution
    );

  function swap(
    IERC20 fromToken,
    IERC20 destToken,
    uint256 amount,
    uint256 minReturn,
    uint256[] memory distribution,
    uint256 flags
  ) external payable returns (uint256 returnAmount);
}
