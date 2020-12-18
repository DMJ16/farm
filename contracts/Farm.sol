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
    nameDirectory.add(keccak256(abi.encodePacked("farm")));
    nameDirectory.add(keccak256(abi.encodePacked("pickle")));
    nameDirectory.add(keccak256(abi.encodePacked("pipt")));
    nameDirectory.add(keccak256(abi.encodePacked("yeti")));

    stakingDirectory["farm"] = StakingPlatform({
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
   * @dev Get the staked balance of a single token.
   * @param _stakingTokenName Get staked balance of this token.
   * @return balance
   */
  function getStakedBalance(string memory _stakingTokenName)
    public
    view
    onlyOwner
    isValidTokenName(_stakingTokenName)
    returns (uint256 balance)
  {
    address self = address(this);
    if (_stringEqCheck(_stakingTokenName, "farm")) {
      balance = AutoStake.balanceOf(self);
    } else if (_stringEqCheck(_stakingTokenName, "pickle")) {
      balance = StakingRewards.balanceOf(self);
    } else {
      if (_stringEqCheck(_stakingTokenName, "pipt")) {
        (, , , , uint256 lptAmount) = VestedLPMining.users(6, self); // pid 6
        balance = lptAmount;
      } else {
        (, , , , uint256 lptAmount) = VestedLPMining.users(9, self); // pid 9
        balance = lptAmount;
      }
    }
    return balance;
  }

  /**
   * @dev Enter a staking position by inputting the staking token's name as a string.
   * @param _stakingTokenName Name of token to stake.
   * @return amountStaked
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
    _handleAllowance(token, stakingPlatform.stakingAddress, ownerBalance);
    return _stake(_stakingTokenName, ownerBalance);
  }

  /**
   * @dev Exit staking position and convert reward tokens to USDC.
   * @param _stakingTokenName Name of token to unstake.
   * @param _returnTokenAddress Address of token to swap into from reward token.
   * @return swapOutput
   */
  function exitFarm(
    string memory _stakingTokenName,
    address _returnTokenAddress
  )
    public
    payable
    onlyOwner
    nonReentrant
    whenNotPaused
    isValidTokenName(_stakingTokenName)
    returns (uint256 swapOutput)
  {
    assert(_unstake(_stakingTokenName));
    StakingPlatform memory stakingPlatform =
      stakingDirectory[_stakingTokenName];
    IERC20 token = IERC20(stakingPlatform.tokenAddress);
    address self = address(this);
    uint256 tokenBalance = token.balanceOf(self);
    _handleAllowance(token, uniswapRouterAddress, tokenBalance);
    swapOutput = _swapAndTransferToOwner(
      token,
      IERC20(_returnTokenAddress),
      tokenBalance
    );
    return swapOutput;
  }

  /**
   * @dev Harvest the rewards available from staking.
   * @param _stakingTokenName Name of token for harvesting rewards.
   * @param _returnTokenAddress Address of token to swap into from reward token.
   * @return swapOutput
   */
  function harvest(string memory _stakingTokenName, address _returnTokenAddress)
    public
    onlyOwner
    nonReentrant
    whenNotPaused
    isValidTokenName(_stakingTokenName)
    returns (uint256 swapOutput)
  {
    StakingPlatform memory stakingPlatform =
      stakingDirectory[_stakingTokenName];
    uint256 withdrawAmount;
    address self = address(this);
    if (_stringEqCheck(_stakingTokenName, "farm")) {
      _unstake(_stakingTokenName); // No harvesting rewards without unstakin
    } else if (_stringEqCheck(_stakingTokenName, "pickle")) {
      withdrawAmount = StakingRewards.rewards(self);
      StakingRewards.getReward();
    } else {
      if (_stringEqCheck(_stakingTokenName, "pipt"))
        withdrawAmount = VestedLPMining.pendingCvp(6, self); // pid 6
      else withdrawAmount = VestedLPMining.pendingCvp(9, self); // pid 9
    }
    IERC20 token = IERC20(stakingPlatform.tokenAddress);
    _handleAllowance(token, uniswapRouterAddress, withdrawAmount);
    swapOutput = _swapAndTransferToOwner(
      token,
      IERC20(_returnTokenAddress),
      withdrawAmount
    );
    return swapOutput;
  }

  /**
   * @dev Update staking token address.
   * @param _stakingTokenName Name of token for token address update.
   * @param _newTokenAddress New staking token address.
   */
  function updateStakingToken(
    string memory _stakingTokenName,
    address _newTokenAddress
  ) public onlyOwner {
    StakingPlatform memory stakingPlatform =
      stakingDirectory[_stakingTokenName];
    stakingDirectory[_stakingTokenName] = StakingPlatform({
      tokenAddress: _newTokenAddress,
      stakingAddress: stakingPlatform.stakingAddress
    });
    assert(stakingPlatform.tokenAddress == _newTokenAddress);
  }

  /**
   * @dev Update staking contract address.
   * @param _stakingTokenName Name of token for staking contract address update.
   * @param _newStakingAddress New staking contract address.
   */
  function updateStakingAddress(
    string memory _stakingTokenName,
    address _newStakingAddress
  ) public onlyOwner {
    StakingPlatform memory stakingPlatform =
      stakingDirectory[_stakingTokenName];
    stakingDirectory[_stakingTokenName] = StakingPlatform({
      tokenAddress: stakingPlatform.tokenAddress,
      stakingAddress: _newStakingAddress
    });
    assert(stakingPlatform.stakingAddress == _newStakingAddress);
  }

  /**
   * @dev Update USDC token address.
   * @param _newAddress New USDC address.
   */
  function updateUSDCToken(address _newAddress) public onlyOwner {
    usdcAddress = _newAddress;
    USDC = IERC20(_newAddress);
  }

  /**
   * @dev Update FARM token address.
   * @param _newAddress New FARM address.
   */
  function updateFARMToken(address _newAddress) public onlyOwner {
    farmTokenAddress = _newAddress;
    FARM = IERC20(_newAddress);
  }

  /**
   * @dev Update PICKLE token address.
   * @param _newAddress New PICKLE address.
   */
  function updatePICKLEToken(address _newAddress) public onlyOwner {
    pickleAddress = _newAddress;
    PICKLE = IERC20(_newAddress);
  }

  /**
   * @dev Update PIPT token address.
   * @param _newAddress New PIPT address.
   */
  function updatePIPT(address _newAddress) public onlyOwner {
    piptAddress = _newAddress;
    PIPT = IERC20(_newAddress);
  }

  /**
   * @dev Update YETI token address.
   * @param _newAddress New YETI address.
   */
  function updateYETI(address _newAddress) public onlyOwner {
    yetiAddress = _newAddress;
    YETI = IERC20(_newAddress);
  }

  /**
   * @dev Update Uniswap router contract address.
   * @param _newAddress New Uniswap router contract address.
   */
  function updateUniswapRouter(address _newAddress) public onlyOwner {
    uniswapRouterAddress = _newAddress;
    UniswapRouter = IUniswapV2Router02(_newAddress);
  }

  /**
   * @dev Pause contract in case of emergency. Only Owner can call pause().
   * @return bool
   */
  function pause() public onlyOwner returns (bool) {
    _pause();
    return paused();
  }

  /**
   * @dev Unpause contract. Only Owner can call unpause().
   * @return bool
   */
  function unpause() public onlyOwner returns (bool) {
    _unpause();
    return paused();
  }

  /**
   * @dev Self-destructs contract and sends funds to msg.sender. Only Owner can call kill().
   */
  function kill() public onlyOwner {
    address[] memory tokenAddresses = new address[](nameDirectory.length());
    for (uint256 i = 0; i < nameDirectory.length(); i++) {
      StakingPlatform memory stakingPlatform =
        stakingDirectory[_bytes32ToStr(nameDirectory.at(i))];
      tokenAddresses[i] = stakingPlatform.tokenAddress;
    }
    batchWithdrawToken(tokenAddresses);
    selfdestruct(msg.sender);
  }

  /**
   * @dev Stakes the given amount of token.
   * @param _stakingTokenName Name of token to stake.
   * @param _amount Amount to stake.
   * @return TotalAmountStaked
   */
  function _stake(string memory _stakingTokenName, uint256 _amount)
    internal
    returns (uint256 TotalAmountStaked)
  {
    address self = address(this);
    uint256 prevBalance;
    if (_stringEqCheck(_stakingTokenName, "farm")) {
      prevBalance = AutoStake.balanceOf(self);
      AutoStake.stake(_amount);
      TotalAmountStaked = AutoStake.balanceOf(self);
    } else if (_stringEqCheck(_stakingTokenName, "pickle")) {
      prevBalance = StakingRewards.balanceOf(self);
      StakingRewards.stake(_amount);
      TotalAmountStaked = StakingRewards.balanceOf(self);
    } else {
      if (_stringEqCheck(_stakingTokenName, "pipt")) {
        (, , , , uint256 prevLptAmount) = VestedLPMining.users(6, self); // pid 6
        prevBalance = prevLptAmount;
        VestedLPMining.deposit(6, _amount);
        (, , , , uint256 lptAmount) = VestedLPMining.users(6, self);
        TotalAmountStaked = lptAmount;
      } else {
        (, , , , uint256 prevLptAmount) = VestedLPMining.users(9, self); // pid 9
        prevBalance = prevLptAmount;
        VestedLPMining.deposit(9, _amount);
        (, , , , uint256 lptAmount) = VestedLPMining.users(9, self);
        TotalAmountStaked = lptAmount;
      }
    }
    assert(TotalAmountStaked == prevBalance.add(_amount));
    return TotalAmountStaked;
  }

  /**
   * @dev Unstake total amount of input token.
   * @param _stakingTokenName Name of token to unstake.
   * @return bool
   */
  function _unstake(string memory _stakingTokenName) internal returns (bool) {
    address self = address(this);
    if (_stringEqCheck(_stakingTokenName, "farm")) {
      AutoStake.exit();
      assert(AutoStake.balanceOf(self) == 0);
    } else if (_stringEqCheck(_stakingTokenName, "pickle")) {
      uint256 pickleBalance = StakingRewards.balanceOf(self);
      StakingRewards.withdraw(pickleBalance);
      assert(StakingRewards.balanceOf(self) == 0);
    } else {
      if (_stringEqCheck(_stakingTokenName, "pipt")) {
        (, , , , uint256 prevLptAmount) = VestedLPMining.users(6, self); // pid 6
        VestedLPMining.withdraw(6, prevLptAmount);
        (, , , , uint256 postWithdrawLptAmount) = VestedLPMining.users(6, self);
        assert(postWithdrawLptAmount == 0);
      } else {
        (, , , , uint256 prevLptAmount) = VestedLPMining.users(9, self); // pid 9
        VestedLPMining.withdraw(9, prevLptAmount);
        (, , , , uint256 postWithdrawLptAmount) = VestedLPMining.users(9, self);
        assert(postWithdrawLptAmount == 0);
      }
    }
    return true;
  }

  /**
   * @dev Handler swaps tokens and then sends output amount to Owner/msg.sender.
   * @param _srcToken Source token to swap into destination token.
   * @param _destToken Destination/output token.
   * @param _amount Token amount to swap.
   * @return swapOutput
   */
  function _swapAndTransferToOwner(
    IERC20 _srcToken,
    IERC20 _destToken,
    uint256 _amount
  ) internal returns (uint256 swapOutput) {
    swapOutput = _performOneSplit(_srcToken, _destToken, _amount);
    address self = address(this);
    uint256 _destTokenBalance = _destToken.balanceOf(self);
    assert(_destTokenBalance >= swapOutput);
    _destToken.safeTransfer(msg.sender, _destTokenBalance);
    return swapOutput;
  }

  /**
   * @dev Swap token into another token using 1Inch.
   * @param _srcToken Source token to swap into destination token.
   * @param _destToken Destination/output token.
   * @param _amount Token amount to swap.
   * @return swapOutput
   */
  function _performOneSplit(
    IERC20 _srcToken,
    IERC20 _destToken,
    uint256 _amount
  ) internal returns (uint256 swapOutput) {
    (uint256 returnAmount, uint256[] memory distribution) =
      OneSplit.getExpectedReturn(_srcToken, _destToken, _amount, 10, 0);
    swapOutput = OneSplit.swap(
      _srcToken,
      _destToken,
      _amount,
      returnAmount,
      distribution,
      0
    );
    return swapOutput;
  }

  /**
   * @dev Handler safely corrects allowance if allowance is insufficient.
   * @param _token Evaluates allowance of this token.
   * @param _spender Address gaining allowance.
   * @param _amount Required allowance amount.
   */
  function _handleAllowance(
    IERC20 _token,
    address _spender,
    uint256 _amount
  ) internal {
    address self = address(this);
    uint256 allowance = _token.allowance(self, _spender);
    if (allowance < _amount) {
      _token.safeDecreaseAllowance(_spender, allowance);
      _token.safeIncreaseAllowance(_spender, _amount);
    }
    assert(_token.allowance(self, _spender) >= _amount);
  }

  /**
   * @dev Helper to check if two strings are equal.
   * @param str1 First string to compare
   * @param str2 Second string to compare
   * @return bool
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

  /**
   * @dev Helper to convert bytes32 to string.
   * @param _bytesToConvert bytes32 to convert to string.
   * @return string
   */
  function _bytes32ToStr(bytes32 _bytesToConvert)
    internal
    pure
    returns (string memory)
  {
    bytes memory bytesArray = new bytes(32);
    for (uint256 i = 0; i < 32; i++) bytesArray[i] = _bytesToConvert[i];
    return string(bytesArray);
  }
}
