// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;
pragma abicoder v2;

import "hardhat/console.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "./Withdrawable.sol";
import "./interfaces/IOneSplit.sol"; // 1Inch
// STAKING CONTRACTS
import "./interfaces/IAutoStake.sol"; // Harvest
import "./interfaces/IStakingRewards.sol"; // OLD Pickle
import "./interfaces/IVestedLPMining.sol"; // PIPT/YETI
// UNISWAP
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/lib/contracts/libraries/Babylonian.sol";
import "./libraries/UniswapV2Library.sol";

contract Farm is ReentrancyGuard, Pausable, Withdrawable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;
  using EnumerableSet for EnumerableSet.Bytes32Set;

  struct StakingPlatform {
    address tokenAddress;
    address stakingAddress;
  }

  mapping(string => StakingPlatform) public stakingDirectory;
  EnumerableSet.Bytes32Set private nameDirectory;
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

  modifier isValidTokenName(string memory _stakingTokenName) {
    require(
      nameDirectory.contains(keccak256(abi.encodePacked(_stakingTokenName))),
      "Invalid _stakingTokenName"
    );
    _;
  }

  constructor() payable {
    nameDirectory.add(keccak256(abi.encodePacked("harvest")));
    nameDirectory.add(keccak256(abi.encodePacked("pickle")));
    nameDirectory.add(keccak256(abi.encodePacked("pipt")));
    nameDirectory.add(keccak256(abi.encodePacked("yeti")));

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

    //  NEW ADDRESS FOR STAKING VAULT AFTER AUDIT IS COMPLETE
    //  stakingDirectory["pickle"] = StakingPlatform({
    //   tokenAddress: 0x429881672B9AE42b8EbA0E26cD9C73711b891Ca5,
    //   stakingAddress: ****
    // });

    deadline = block.timestamp + 300; // for swaps on Uniswap
  }

  /**
   * @dev Get the staked balance of input token name.
   * @param _stakingTokenName Staking token name.
   */
  function getStakedBalance(string memory _stakingTokenName)
    public
    view
    onlyOwner
    isValidTokenName(_stakingTokenName)
    returns (uint256 balance)
  {
    // StakingPlatform memory stakingPlatform = stakingDirectory[_stakingTokenName];
    address self = address(this);
    if (_stringEqCheck(_stakingTokenName, "harvest")) {
      balance = AutoStake.balanceOf(self);
    } else if (_stringEqCheck(_stakingTokenName, "pickle")) {
      uint256 pickleBalance = StakingRewards.balanceOf(self);
      balance = pickleBalance;
    } else {
      if (_stringEqCheck(_stakingTokenName, "pipt")) {
        (, , , , uint256 lptAmount) = VestedLPMining.users(6, self);
        balance = lptAmount;
      } else {
        (, , , , uint256 lptAmount) = VestedLPMining.users(9, self);
        balance = lptAmount;
      }
    }
    return balance;
  }

  /**
   * @dev Enter staking position given the staking token's name.
   * @param _stakingTokenName Staking token name.
   */
  function enterFarm(string memory _stakingTokenName)
    public
    payable
    onlyOwner
    nonReentrant
    whenNotPaused
    isValidTokenName(_stakingTokenName)
    returns (uint256 amountStaked)
  {
    StakingPlatform memory stakingPlatform =
      stakingDirectory[_stakingTokenName];
    IERC20 token = IERC20(stakingPlatform.tokenAddress);
    uint256 ownerBalance = token.balanceOf(msg.sender);
    address self = address(this);
    token.safeTransferFrom(msg.sender, self, ownerBalance);
    uint256 allowance = token.allowance(self, stakingPlatform.stakingAddress);
    if (allowance < ownerBalance) {
      token.safeDecreaseAllowance(stakingPlatform.stakingAddress, allowance);
      token.safeIncreaseAllowance(stakingPlatform.stakingAddress, ownerBalance);
    }
    return _stake(_stakingTokenName, ownerBalance);
  }

  /**
   * @dev Exit staking position and convert staking token to USDC.
   * @param _stakingTokenName Staking token name.
   */
  function exitFarm(string memory _stakingTokenName)
    public
    payable
    onlyOwner
    nonReentrant
    whenNotPaused
    isValidTokenName(_stakingTokenName)
    returns (bool)
  {
    StakingPlatform memory stakingPlatform =
      stakingDirectory[_stakingTokenName];
    IERC20 token = IERC20(stakingPlatform.tokenAddress);
    assert(_unstake(_stakingTokenName));
    address self = address(this);
    uint256 currentTokenBalance = token.balanceOf(self);
    uint256 allowance = token.allowance(self, uniswapRouterAddress);
    if (allowance < currentTokenBalance) {
      token.safeDecreaseAllowance(uniswapRouterAddress, allowance);
      token.safeIncreaseAllowance(uniswapRouterAddress, currentTokenBalance);
    }
    uint256 swapOutput = _performOneSplit(token, currentTokenBalance);
    uint256 usdcBalance = USDC.balanceOf(self);
    assert(usdcBalance == swapOutput);
    USDC.safeTransfer(msg.sender, usdcBalance);
    return true;
  }

  /**
   * @dev Harvest the rewards available from staking.
   * @param _stakingTokenName Staking token name.
   */
  function harvest(string memory _stakingTokenName)
    public
    onlyOwner
    nonReentrant
    whenNotPaused
    isValidTokenName(_stakingTokenName)
    returns (uint256[] memory outputAmounts)
  {
    StakingPlatform memory stakingPlatform =
      stakingDirectory[_stakingTokenName];
    uint256 withdrawAmount;
    address self = address(this);
    if (_stringEqCheck(_stakingTokenName, "harvest")) {
      _unstake(_stakingTokenName); // No harvesting rewards without unstakin
    } else if (_stringEqCheck(_stakingTokenName, "pickle")) {
      withdrawAmount = StakingRewards.rewards(self);
      StakingRewards.getReward();
    } else {
      if (_stringEqCheck(_stakingTokenName, "pipt"))
        withdrawAmount = VestedLPMining.pendingCvp(6, self);
      else withdrawAmount = VestedLPMining.pendingCvp(9, self);
    }
    IERC20 token = IERC20(stakingPlatform.tokenAddress);
    uint256 allowance = token.allowance(self, uniswapRouterAddress);
    if (allowance < withdrawAmount) {
      token.safeDecreaseAllowance(uniswapRouterAddress, allowance);
      token.safeIncreaseAllowance(uniswapRouterAddress, withdrawAmount);
    }
    uint256 swapOutput = _performOneSplit(token, withdrawAmount);
    outputAmounts = new uint256[](2);
    outputAmounts[0] = withdrawAmount;
    outputAmounts[1] = swapOutput;
    return outputAmounts;
  }

  /**
   * @dev Update staking token address for given staking token name.
   * @param _stakingTokenName Staking token name.
   * @param _newTokenAddress New token address.
   */
  function updateStakingToken(
    string memory _stakingTokenName,
    address _newTokenAddress
  ) public onlyOwner {
    StakingPlatform memory stakingPlatform =
      stakingDirectory[_stakingTokenName];
    stakingPlatform.tokenAddress = _newTokenAddress;
    assert(
      stakingDirectory[_stakingTokenName].tokenAddress == _newTokenAddress
    );
  }

  /**
   * @dev Update staking contract address for given staking token name.
   * @param _stakingTokenName Staking token name.
   * @param _newStakingAddress New staking contract address.
   */
  function updateStakingAddress(
    string memory _stakingTokenName,
    address _newStakingAddress
  ) public onlyOwner {
    StakingPlatform memory stakingPlatform =
      stakingDirectory[_stakingTokenName];
    stakingPlatform.stakingAddress = _newStakingAddress;
    assert(
      stakingDirectory[_stakingTokenName].stakingAddress == _newStakingAddress
    );
  }

  /**
   * @dev Update USDC token address.
   * @param _newAddress New token address.
   */
  function updateUSDCToken(address _newAddress)
    public
    onlyOwner
    returns (bool)
  {
    usdcAddress = _newAddress;
    USDC = IERC20(_newAddress);
    return true;
  }

  /**
   * @dev Update FARM token address.
   * @param _newAddress New token address.
   */
  function updateFARMToken(address _newAddress)
    public
    onlyOwner
    returns (bool)
  {
    farmTokenAddress = _newAddress;
    FARM = IERC20(_newAddress);
    return true;
  }

  /**
   * @dev Update PICKLE token address.
   * @param _newAddress New token address.
   */
  function updatePICKLEToken(address _newAddress)
    public
    onlyOwner
    returns (bool)
  {
    pickleAddress = _newAddress;
    PICKLE = IERC20(_newAddress);
    return true;
  }

  /**
   * @dev Update PIPT token address.
   * @param _newAddress New token address.
   */
  function updatePIPT(address _newAddress) public onlyOwner returns (bool) {
    piptAddress = _newAddress;
    PIPT = IERC20(_newAddress);
    return true;
  }

  /**
   * @dev Update YETI token address.
   * @param _newAddress New token address.
   */
  function updateYETI(address _newAddress) public onlyOwner returns (bool) {
    yetiAddress = _newAddress;
    YETI = IERC20(_newAddress);
    return true;
  }

  /**
   * @dev Update Uniswap router contract address.
   * @param _newAddress New router contract address.
   */
  function updateUniswapRouter(address _newAddress)
    public
    onlyOwner
    returns (bool)
  {
    uniswapRouterAddress = _newAddress;
    UniswapRouter = IUniswapV2Router02(_newAddress);
    return true;
  }

  /**
   * @dev Self-destructs contract and sends funds to msg.sender, which must be the Owner. Only Owner can call kill()
   */
  function kill() public onlyOwner {
    selfdestruct(msg.sender);
  }

  /**
   * @dev Pause contract in case of emergency. Only Owner can call pause().
   */
  function pause() public onlyOwner returns (bool) {
    _pause();
    return paused();
  }

  /**
   * @dev Unpause contract. Only Owner can call unpause().
   */
  function unpause() public onlyOwner returns (bool) {
    _unpause();
    return paused();
  }

  /**
   * @dev Stake the amount given of staking token's pool.
   * @param _stakingTokenName Staking token's name
   * @param _amount Amount to be staked of staking token
   */
  function _stake(string memory _stakingTokenName, uint256 _amount)
    internal
    returns (uint256 amountStaked)
  {
    // StakingPlatform memory stakingPlatform = stakingDirectory[_stakingTokenName];
    address self = address(this);
    if (_stringEqCheck(_stakingTokenName, "harvest")) {
      AutoStake.stake(_amount);
      amountStaked = AutoStake.balanceOf(self);
    } else if (_stringEqCheck(_stakingTokenName, "pickle")) {
      StakingRewards.stake(_amount);
      uint256 pickleBalance = StakingRewards.balanceOf(self);
      amountStaked = pickleBalance;
    } else {
      if (_stringEqCheck(_stakingTokenName, "pipt")) {
        VestedLPMining.deposit(6, _amount);
        (, , , , uint256 lptAmount) = VestedLPMining.users(6, self);
        amountStaked = lptAmount;
      } else {
        VestedLPMining.deposit(9, _amount);
        (, , , , uint256 lptAmount) = VestedLPMining.users(9, self);
        amountStaked = lptAmount;
      }
    }
    assert(_amount == amountStaked);
    return amountStaked;
  }

  /**
   * @dev Unstake total amount of staked tokens.
   * @param _stakingTokenName Staking token's name
   */
  function _unstake(string memory _stakingTokenName) internal returns (bool) {
    StakingPlatform memory stakingPlatform =
      stakingDirectory[_stakingTokenName];
    address self = address(this);
    if (_stringEqCheck(_stakingTokenName, "harvest")) {
      AutoStake.exit();
      assert(AutoStake.balanceOf(self) == 0);
    } else if (_stringEqCheck(_stakingTokenName, "pickle")) {
      uint256 pickleBalance = StakingRewards.balanceOf(self);
      StakingRewards.withdraw(pickleBalance);
      assert(StakingRewards.balanceOf(self) == 0);
    } else {
      if (_stringEqCheck(_stakingTokenName, "pipt")) {
        (, , , , uint256 lptAmount) = VestedLPMining.users(6, self);
        VestedLPMining.withdraw(6, lptAmount);
        (, , , , uint256 postWithdrawLptAmount) = VestedLPMining.users(6, self);
        assert(postWithdrawLptAmount == 0);
      } else {
        (, , , , uint256 lptAmount) = VestedLPMining.users(9, self);
        VestedLPMining.withdraw(9, lptAmount);
        (, , , , uint256 postWithdrawLptAmount) = VestedLPMining.users(9, self);
        assert(postWithdrawLptAmount == 0);
      }
    }
    return true;
  }

  /**
   * @dev Swap token into USDC using 1Inch.
   * @param _token ERC20 token to swap into USDC
   * @param _amount Amount of ERC20 token to convert into USDC
   */
  function _performOneSplit(IERC20 _token, uint256 _amount)
    internal
    returns (uint256 swapOutput)
  {
    (uint256 returnAmount, uint256[] memory distribution) =
      OneSplit.getExpectedReturn(_token, USDC, _amount, 100, 0);
    swapOutput = OneSplit.swap(
      _token,
      USDC,
      _amount,
      returnAmount,
      distribution,
      0
    );
    return swapOutput;
  }

  /**
   * @dev Helper to check if two strings are equal.
   * @param str1 First string to compare
   * @param str2 Second string to compare
   */
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
