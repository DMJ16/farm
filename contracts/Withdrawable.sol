// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
    Ensures that any contract that inherits from this contract is able to
    withdraw funds that are accidentally received or stuck.
 */
contract Withdrawable is Ownable {
  using SafeERC20 for IERC20;
  address constant ETHER = address(0);

  event LogWithdraw(
    address indexed _from,
    address indexed _tokenAddress,
    uint256 amount
  );

  /**
   * @dev Withdraw single token.
   * @param _tokenAddress Address of token to be withdrawn.
   */
  function withdrawToken(address _tokenAddress) public onlyOwner {
    uint256 tokenBalance;
    address self = address(this);
    if (_tokenAddress == ETHER) {
      tokenBalance = self.balance;
      msg.sender.transfer(tokenBalance);
    } else {
      IERC20 token = IERC20(_tokenAddress);
      tokenBalance = token.balanceOf(self);
      token.safeTransfer(msg.sender, tokenBalance);
    }
    emit LogWithdraw(msg.sender, _tokenAddress, tokenBalance);
  }

  /**
   * @dev Withdraw single token to destination address given an amount to withdraw.
   * @param _tokenAddress Address of token to be withdrawn.
   * @param _amount Amount to withdraw of token.
   * @param _destinationAddress Address of destination account receiving withdrawn tokens
   */
  function withdrawAmountToAddress(
    address _tokenAddress,
    uint256 _amount,
    address payable _destinationAddress
  ) public onlyOwner {
    IERC20 token = IERC20(_tokenAddress);
    address self = address(this);
    require(
      token.balanceOf(self) >= _amount,
      "Balance is less than requested withdrawal _amount"
    );
    if (address(_tokenAddress) == ETHER) _destinationAddress.transfer(_amount);
    else token.safeTransfer(_destinationAddress, _amount);
    emit LogWithdraw(_destinationAddress, _tokenAddress, _amount);
  }

  /**
   * @dev Withdraw multiple token.
   * @param _tokenAddresses Tokens to be withdrawn.
   */
  function batchWithdrawToken(address[] memory _tokenAddresses)
    public
    onlyOwner
  {
    for (uint256 i = 0; i < _tokenAddresses.length; i++) {
      withdrawToken(_tokenAddresses[i]);
    }
  }
}
