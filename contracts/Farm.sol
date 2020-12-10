// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IHarvestStaking.sol";
import "./interfaces/IPickleStaking.sol";
import "./interfaces/IWETH.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol";

// interface UniswapV2 {
//   function swapExactTokensForTokens(
//     uint256 amountIn,
//     uint256 amountOutMin,
//     address[] calldata path,
//     address to,
//     uint256 deadline
//   ) external returns (uint256[] memory amounts);
// }

contract Farm is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  address ETH_TOKEN_ADDRESS = address(0x0);
  mapping(uint256 => mapping(address => address)) public stakingDirectory;
  IERC20 usdcToken = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
  address public usdcAddress = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
  UniswapV2 uniswap = UniswapV2(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
  address public uniAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

  constructor() public payable {
    //farm token, farm staking
    stakingDirectory[1][
      0xa0246c9032bC3A600820415aE600c6388619A14D
    ] = 0x25550Cccbd68533Fa04bFD3e3AC4D09f9e00Fc50;
    //pickle's USDT/Pickle staking jar
    stakingDirectory[2][
      0x0d4a11d5EEaaC28EC3F61d100daF4d40471f1852
    ] = 0x09FC573c502037B149ba87782ACC81cF093EC6ef;
  }

  //   fallback() external payable {}

  function updateStakingContracts(
    uint256 whichFarm,
    address stakingAddress,
    address stakingToken
  ) public onlyOwner returns (bool) {
    stakingDirectory[whichFarm][stakingToken] = stakingAddress;
    return true;
  }

  function updateUSDCToken(address newAddress) public onlyOwner returns (bool) {
    usdcToken = IERC20(newAddress);
    usdcAddress = newAddress;
    return true;
  }

  function updateUniswap(address newAddress) public onlyOwner returns (bool) {
    uniswap = UniswapV2(newAddress);
    uniAddress = newAddress;
    return true;
  }

  function enterFarm(uint256 whichFarm, address tokenAddress)
    public
    payable
    onlyOwner
    returns (bool)
  {
    IERC20 thisToken = IERC20(tokenAddress);
    uint256 ownerBalance = thisToken.balanceOf(msg.sender);

    require(
      thisToken.safeTransferFrom(msg.sender, address(this), ownerBalance),
      "Not enough tokens to transferFrom or no approval"
    );

    uint256 approvedAmount =
      thisToken.allowance(
        address(this),
        stakingDirectory[whichFarm][tokenAddress]
      );
    if (approvedAmount < ownerBalance) {
      thisToken.approve(
        stakingDirectory[whichFarm][tokenAddress],
        ownerBalance.mul(10000)
      );
    }

    stake(whichFarm, ownerBalance, tokenAddress);
    return true;
  }

  function exitFarm(uint256 whichFarm, address tokenAddress)
    public
    payable
    onlyOwner
    returns (bool)
  {
    IERC20 thisToken = IERC20(tokenAddress);
    unstake(whichFarm, tokenAddress);
    uint256 currentTokenBalance = thisToken.balanceOf(address(this));
    if (whichFarm == 1) {
      //swap from unstaked tokens to usdc and transfer back to owner
      thisToken.approve(uniAddress, 1000000000000000000000000000000000000);

      performUniswap(tokenAddress, usdcAddress, currentTokenBalance);
      require(
        usdcToken.transfer(msg.sender, usdcToken.balanceOf(address(this))),
        "You dont have enough tokens inside this contract to withdraw from deposits"
      );
      return true;
    } else {
      //JUST example code, this one doesnt unwrap, trade and send as its an LP token, and just sends to the user as an example in the tutorial
      require(
        thisToken.safeTransfer(msg.sender, currentTokenBalance),
        "You dont have enough tokens inside this contract to withdraw from deposits"
      );
    }
  }

  function stake(
    uint256 whichFarm,
    uint256 amount,
    address tokenAddress
  ) internal returns (bool) {
    if (whichFarm == 1) {
      IHarvestStaking staker =
        IHarvestStaking(stakingDirectory[whichFarm][tokenAddress]);
      staker.stake(amount);
      return true;
    } else {
      IPickleStaking staker1 =
        IPickleStaking(stakingDirectory[whichFarm][tokenAddress]);
      staker1.deposit(amount);
    }
  }

  function unstake(uint256 whichFarm, address tokenAddress)
    internal
    returns (bool)
  {
    if (whichFarm == 1) {
      IHarvestStaking staker =
        IHarvestStaking(stakingDirectory[whichFarm][tokenAddress]);
      staker.exit();
    } else {
      IPickleStaking staker1 =
        IPickleStaking(stakingDirectory[whichFarm][tokenAddress]);
      staker1.approve(
        stakingDirectory[whichFarm][tokenAddress],
        10000000000000000000000000000000
      );
      staker1.withdrawAll();
    }

    return true;
  }

  function performUniswap(
    address sellToken,
    address buyToken,
    uint256 amount
  ) internal returns (uint256 amounts1) {
    address[] memory addresses = new address[](2);
    addresses[0] = sellToken;
    addresses[1] = buyToken;
    uint256[] memory amounts = performUniswapT4T(addresses, amount);
    uint256 resultingTokens = amounts[1];
    return resultingTokens;
  }

  function performUniswapT4T(address[] memory theAddresses, uint256 amount)
    internal
    returns (uint256[] memory amounts1)
  {
    uint256 deadline = 1000000000000000;
    uint256[] memory amounts =
      uniswap.swapExactTokensForTokens(
        amount,
        1,
        theAddresses,
        address(this),
        deadline
      );
    return amounts;
  }

  function getMyStakedBalance(
    uint256 _whichFarm,
    address _owner,
    address _tokenAddress
  ) public view returns (uint256) {
    if (_whichFarm == 1) {
      IHarvestStaking staker =
        IHarvestStaking(stakingDirectory[_whichFarm][_tokenAddress]);
      return staker.balanceOf(_owner);
    } else {
      IPickleStaking staker1 =
        IPickleStaking(stakingDirectory[_whichFarm][_tokenAddress]);
      return staker1.balanceOf(_owner);
    }
  }

  function withdrawTokens(
    address _token,
    uint256 _amount,
    address _destination
  ) public onlyOwner returns (bool) {
    if (address(_token) == ETH_TOKEN_ADDRESS) {
      _destination.transfer(_amount);
    } else {
      IERC20 tokenToken = IERC20(token);
      require(tokenToken.safeTransfer(_destination, _amount));
    }
    return true;
  }

  function kill() public virtual onlyOwner {
    selfdestruct(owner);
  }
}
