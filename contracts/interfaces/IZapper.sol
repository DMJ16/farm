// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

interface IUniswapZapIn {
  // zapIn address: 0xE83554B397BdA8ECAE7FEE5aeE532e83Ee9eB29D

  function ZapIn(
    address _toWhomToIssue,
    address _FromTokenContractAddress,
    address _ToUnipoolToken0,
    address _ToUnipoolToken1,
    uint256 _amount,
    uint256 _minPoolTokens
  ) external payable returns (uint256);

  function calculateSwapInAmount(uint256 reserveIn, uint256 userIn)
    external
    pure
    returns (uint256);
}

interface IUniswapZapOut {
  // zapOut: 0x79B6C6F8634ea477ED725eC23b7b6Fcb41F00E58
  function ZapOut2PairToken(address _FromUniPoolAddress, uint256 _IncomingLP)
    external
    returns (uint256 amountA, uint256 amountB);

  function ZapOut(
    address _ToTokenContractAddress,
    address _FromUniPoolAddress,
    uint256 _IncomingLP,
    uint256 _minTokensRec
  ) external payable returns (uint256);
}

interface IBalancerZapOut {
  function EasyZapOut(
    address _ToTokenContractAddress,
    address _FromBalancerPoolAddress,
    uint256 _IncomingBPT,
    uint256 _minTokensRec
  ) external payable returns (uint256);
}

interface IUniswapPipe {
  // zapPipe address: 0xBdcd4Dcc79bA2C4088323ca94F443a05A23cA372

  function PipeUniV2(
    address payable _toWhomToIssue,
    address _incomingUniV2Exchange,
    uint256 _IncomingLPT,
    address _toUniV2Exchange,
    uint256 _minPoolTokens
  ) external returns (uint256 lptReceived);

  function PipeUniV2WithPermit(
    address payable _toWhomToIssue,
    address _incomingUniV2Exchange,
    uint256 _IncomingLPT,
    address _toUniV2Exchange,
    uint256 _minPoolTokens,
    uint256 _approvalAmount,
    uint256 _deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256);
}
