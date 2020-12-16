// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;
pragma abicoder v2;

import "hardhat/console.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IAutoStake.sol";
import "./interfaces/IStakingRewards.sol";
import "./interfaces/IOneSplit.sol";
import "./interfaces/IVestedLPMining.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/lib/contracts/libraries/Babylonian.sol";
import "./libraries/UniswapV2Library.sol";

contract Farm is ReentrancyGuard, Ownable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  struct StakingPlatform {
    address tokenAddress;
    address stakingAddress;
  }

  mapping(string => StakingPlatform) public stakingDirectory;
  string[] public nameDirectory = ["harvest", "pickle", "pipt", "yeti"];
  bool public stopped = false;
  uint256 deadline;

  address public usdcAddress = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
  address public wethAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
  address public uniswapRouterAddress =
    0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
  address public pickleAddress = 0x429881672B9AE42b8EbA0E26cD9C73711b891Ca5;
  address public farmTokenAddress = 0xa0246c9032bC3A600820415aE600c6388619A14D;
  address public piptAddress = 0x26607aC599266b21d13c7aCF7942c7701a8b699c;
  address public yetiAddress = 0xb4bebD34f6DaaFd808f73De0d10235a92Fbb6c3D;
  address public uniFactoryAddress = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
  address public autoStakeAddress = 0x25550Cccbd68533Fa04bFD3e3AC4D09f9e00Fc50;
  address public stakingRewardsAddress =
    0xa17a8883dA1aBd57c690DF9Ebf58fC194eDAb66F;
  address public onesplitAddress = 0xC586BeF4a0992C495Cf22e1aeEE4E446CECDee0E;

  IERC20 public USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
  IERC20 public PICKLE = IERC20(0x429881672B9AE42b8EbA0E26cD9C73711b891Ca5);
  IERC20 public FARM = IERC20(0xa0246c9032bC3A600820415aE600c6388619A14D);
  IERC20 public PIPT = IERC20(0x26607aC599266b21d13c7aCF7942c7701a8b699c);
  IERC20 public YETI = IERC20(0xb4bebD34f6DaaFd808f73De0d10235a92Fbb6c3D);
  IUniswapV2Router02 public UniswapRouter =
    IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
  IUniswapV2Factory public UniFactory =
    IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
  IOneSplit public OneSplit =
    IOneSplit(0xC586BeF4a0992C495Cf22e1aeEE4E446CECDee0E); // 1Inch
  IVestedLPMining public VestedLPMining =
    IVestedLPMining(0xF09232320eBEAC33fae61b24bB8D7CA192E58507); // Power Pool
  IStakingRewards public StakingRewards =
    IStakingRewards(0xa17a8883dA1aBd57c690DF9Ebf58fC194eDAb66F); // OLD Pickle contract
  IAutoStake public AutoStake =
    IAutoStake(0x25550Cccbd68533Fa04bFD3e3AC4D09f9e00Fc50); // Harvest

  // circuit breaker modifiers
  modifier stopInEmergency {
    if (stopped) {
      revert("Temporarily Paused");
    } else {
      _;
    }
  }

  constructor() payable {
    stakingDirectory["harvest"] = StakingPlatform({
      tokenAddress: 0xa0246c9032bC3A600820415aE600c6388619A14D,
      stakingAddress: 0x25550Cccbd68533Fa04bFD3e3AC4D09f9e00Fc50
    });

    stakingDirectory["pipt"] = StakingPlatform({
      tokenAddress: 0x26607aC599266b21d13c7aCF7942c7701a8b699c,
      stakingAddress: 0xF09232320eBEAC33fae61b24bB8D7CA192E58507 // pid = 6
    });

    stakingDirectory["yeti"] = StakingPlatform({
      tokenAddress: 0xb4bebD34f6DaaFd808f73De0d10235a92Fbb6c3D,
      stakingAddress: 0xF09232320eBEAC33fae61b24bB8D7CA192E58507 // pid = 9
    });

    //  NEW ADDRESS STAKING VAULT AFTER YEARN AUDIT IS COMPLETE
    //  stakingDirectory["pickle"] = StakingPlatform({
    //   tokenAddress: 0x429881672B9AE42b8EbA0E26cD9C73711b891Ca5,
    //   stakingAddress: NEW ADDRESS AFTER YEARN AUDIT
    // });

    deadline = block.timestamp + 300;
  }

  function getStakedBalance(string memory _platform)
    public
    returns (uint256 balance)
  {
    StakingPlatform memory stakingPlatform = stakingDirectory[_platform];
    if (_stringEqCheck(_platform, "harvest")) {
      balance = AutoStake.balanceOf(address(this));
    } else if (_stringEqCheck(_platform, "pickle")) {
      uint256 pickleBalance = StakingRewards.balanceOf(address(this));
      balance = pickleBalance;
    } else {
      if (_stringEqCheck(_platform, "pipt")) {
        (, , , , uint256 lptAmount) = VestedLPMining.users(6, address(this));
        balance = lptAmount;
      } else {
        (, , , , uint256 lptAmount) = VestedLPMining.users(9, address(this));
        balance = lptAmount;
      }
    }
    return balance;
  }

  function enterFarm(string memory _platform)
    public
    payable
    onlyOwner
    returns (uint256 amountStaked)
  {
    StakingPlatform memory stakingPlatform = stakingDirectory[_platform];
    IERC20 token = IERC20(stakingPlatform.tokenAddress);
    uint256 ownerBalance = token.balanceOf(msg.sender);
    token.safeTransferFrom(msg.sender, address(this), ownerBalance);
    uint256 allowance =
      token.allowance(address(this), stakingPlatform.stakingAddress);
    if (allowance < ownerBalance) {
      token.safeDecreaseAllowance(stakingPlatform.stakingAddress, allowance);
      token.safeIncreaseAllowance(stakingPlatform.stakingAddress, ownerBalance);
    }
    return _stake(_platform, ownerBalance);
  }

  function exitFarm(string memory _platform)
    public
    payable
    onlyOwner
    returns (bool)
  {
    StakingPlatform memory stakingPlatform = stakingDirectory[_platform];
    IERC20 token =
      IERC20(
        _stringEqCheck(_platform, "pickle")
          ? address(wethAddress)
          : stakingPlatform.tokenAddress
      );
    assert(_unstake(_platform));
    uint256 currentTokenBalance = token.balanceOf(address(this));
    uint256 allowance = token.allowance(address(this), uniswapRouterAddress);
    if (allowance < currentTokenBalance) {
      token.safeDecreaseAllowance(uniswapRouterAddress, allowance);
      token.safeIncreaseAllowance(uniswapRouterAddress, currentTokenBalance);
    }
    uint256 swapOutput = _performOneSplit(address(token), currentTokenBalance);
    uint256 usdcBalance = USDC.balanceOf(address(this));
    assert(usdcBalance == swapOutput);
    USDC.safeTransfer(msg.sender, usdcBalance);
    return true;
  }

  function harvest(string memory _platform)
    public
    onlyOwner
    returns (uint256[] memory outputAmounts)
  {
    StakingPlatform memory stakingPlatform = stakingDirectory[_platform];
    address tokenAddress;
    uint256 withdrawAmount;
    if (_stringEqCheck(_platform, "harvest")) {
      _unstake(_platform);
      tokenAddress = farmTokenAddress;
    } else if (_stringEqCheck(_platform, "pickle")) {
      withdrawAmount = StakingRewards.rewards(address(this));
      StakingRewards.getReward(); // TEST THIS WORKS
      tokenAddress = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    } else {
      if (_stringEqCheck(_platform, "pipt")) {
        withdrawAmount = VestedLPMining.pendingCvp(6, address(this));
        tokenAddress = piptAddress;
      } else {
        withdrawAmount = VestedLPMining.pendingCvp(9, address(this));
        tokenAddress = yetiAddress;
      }
    }
    IERC20 token = IERC20(tokenAddress);
    uint256 allowance = token.allowance(address(this), uniswapRouterAddress);
    if (allowance < withdrawAmount) {
      token.safeDecreaseAllowance(uniswapRouterAddress, allowance);
      token.safeIncreaseAllowance(uniswapRouterAddress, withdrawAmount);
    }
    uint256 swapOutput = _performOneSplit(address(token), withdrawAmount);
    outputAmounts = new uint256[](2);
    outputAmounts[0] = withdrawAmount;
    outputAmounts[1] = swapOutput;
    return outputAmounts;
  }

  function withdrawTokens(
    address _tokenAddress,
    uint256 _amount,
    address payable _destinationAddress
  ) public onlyOwner returns (bool) {
    if (address(_tokenAddress) == address(0)) {
      _destinationAddress.transfer(_amount);
    } else {
      IERC20 token = IERC20(_tokenAddress);
      token.safeTransfer(_destinationAddress, _amount);
    }
    return true;
  }

  function addFarm(
    string memory _platform,
    StakingPlatform calldata _newPlatform
  ) public onlyOwner returns (bool) {
    stakingDirectory[_platform] = _newPlatform;
    StakingPlatform memory newPlatform = stakingDirectory[_platform];
    assert(newPlatform.tokenAddress == _newPlatform.tokenAddress);
    assert(newPlatform.stakingAddress == _newPlatform.stakingAddress);
    return true;
  }

  function updateStakingToken(string memory _platform, address _newTokenAddress)
    public
    onlyOwner
  {
    StakingPlatform memory stakingPlatform = stakingDirectory[_platform];
    stakingPlatform.tokenAddress = _newTokenAddress;
    assert(stakingDirectory[_platform].tokenAddress == _newTokenAddress);
  }

  function updateStakingAddress(
    string memory _platform,
    address _newStakingAddress
  ) public onlyOwner {
    StakingPlatform memory stakingPlatform = stakingDirectory[_platform];
    stakingPlatform.stakingAddress = _newStakingAddress;
    assert(stakingDirectory[_platform].stakingAddress == _newStakingAddress);
  }

  function updateUSDCToken(address _newAddress)
    public
    onlyOwner
    returns (bool)
  {
    usdcAddress = _newAddress;
    USDC = IERC20(_newAddress);
    return true;
  }

  function updateFARMToken(address _newAddress)
    public
    onlyOwner
    returns (bool)
  {
    farmTokenAddress = _newAddress;
    FARM = IERC20(_newAddress);
    return true;
  }

  function updatePICKLEToken(address _newAddress)
    public
    onlyOwner
    returns (bool)
  {
    pickleAddress = _newAddress;
    PICKLE = IERC20(_newAddress);
    return true;
  }

  function updatePIPT(address _newAddress) public onlyOwner returns (bool) {
    piptAddress = _newAddress;
    PIPT = IERC20(_newAddress);
    return true;
  }

  function updateYETI(address _newAddress) public onlyOwner returns (bool) {
    yetiAddress = _newAddress;
    YETI = IERC20(_newAddress);
    return true;
  }

  function updateUniswapRouter(address _newAddress)
    public
    onlyOwner
    returns (bool)
  {
    uniswapRouterAddress = _newAddress;
    UniswapRouter = IUniswapV2Router02(_newAddress);
    return true;
  }

  function kill() public virtual onlyOwner {
    selfdestruct(msg.sender);
  }

  function pause() public onlyOwner {
    // maybe replace with _pause() from OpenZeppelin
    stopped = !stopped;
  }

  function _stake(string memory _platform, uint256 _amount)
    internal
    returns (uint256 amountStaked)
  {
    StakingPlatform memory stakingPlatform = stakingDirectory[_platform];
    if (_stringEqCheck(_platform, "harvest")) {
      AutoStake.stake(_amount);
      amountStaked = AutoStake.balanceOf(address(this));
    } else if (_stringEqCheck(_platform, "pickle")) {
      StakingRewards.stake(_amount);
      uint256 pickleBalance = StakingRewards.balanceOf(address(this));
      amountStaked = pickleBalance;
    } else {
      if (_stringEqCheck(_platform, "pipt")) {
        VestedLPMining.deposit(6, _amount);
        (, , , , uint256 lptAmount) = VestedLPMining.users(6, address(this));
        amountStaked = lptAmount;
      } else {
        VestedLPMining.deposit(9, _amount);
        (, , , , uint256 lptAmount) = VestedLPMining.users(9, address(this));
        amountStaked = lptAmount;
      }
    }
    assert(_amount == amountStaked);
    return amountStaked;
  }

  function _unstake(string memory _platform) internal returns (bool) {
    StakingPlatform memory stakingPlatform = stakingDirectory[_platform];
    if (_stringEqCheck(_platform, "harvest")) {
      AutoStake.exit();
      assert(AutoStake.balanceOf(address(this)) == 0);
    } else if (_stringEqCheck(_platform, "pickle")) {
      uint256 pickleBalance = StakingRewards.balanceOf(address(this));
      StakingRewards.withdraw(pickleBalance);
      assert(StakingRewards.balanceOf(address(this)) == 0);
    } else {
      if (_stringEqCheck(_platform, "pipt")) {
        (, , , , uint256 lptAmount) = VestedLPMining.users(6, address(this));
        VestedLPMining.deposit(6, lptAmount);
        (, , , , uint256 postDepositLptAmount) =
          VestedLPMining.users(6, address(this));
        assert(postDepositLptAmount == 0);
      } else {
        (, , , , uint256 lptAmount) = VestedLPMining.users(9, address(this));
        VestedLPMining.deposit(9, lptAmount);
        (, , , , uint256 postDepositLptAmount) =
          VestedLPMining.users(9, address(this));
        assert(postDepositLptAmount == 0);
      }
    }
    return true;
  }

  function _performOneSplit(address _tokenAddress, uint256 _withdrawAmount)
    internal
    returns (uint256 swapOutput)
  {
    (uint256 returnAmount, uint256[] memory distribution) =
      OneSplit.getExpectedReturn(
        _tokenAddress == wethAddress
          ? IERC20(address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE))
          : IERC20(_tokenAddress),
        USDC,
        _withdrawAmount,
        100,
        0
      );
    swapOutput = OneSplit.swap(
      _tokenAddress == wethAddress
        ? IERC20(address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE))
        : IERC20(_tokenAddress),
      USDC,
      _withdrawAmount,
      returnAmount,
      distribution,
      0
    );
    return swapOutput;
  }

  function _stringEqCheck(string memory str1, string memory str2)
    internal
    pure
    returns (bool)
  {
    return
      (keccak256(abi.encodePacked(str1))) ==
      (keccak256(abi.encodePacked(str2)));
  }
}
