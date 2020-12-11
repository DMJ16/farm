// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IAutoStake.sol";
import "./interfaces/IMasterChef.sol";
import "./interfaces/IWETH.sol";
import "./interfaces/IZapper.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

// DOUBLE CHECK ZAP ADDRESSES
// zapIn address: 0xE83554B397BdA8ECAE7FEE5aeE532e83Ee9eB29D
// zapOut: 0x79B6C6F8634ea477ED725eC23b7b6Fcb41F00E58
// zapPipe address: 0xBdcd4Dcc79bA2C4088323ca94F443a05A23cA372

contract Farm is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;
  using Counters for Counters.Counter;

  address ETH_ADDRESS = address(0x0);
  address public usdcAddress = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
  address public uniAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
  address public wethAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
  address uniV2PickleEthAddress = 0xdc98556Ce24f007A5eF6dC1CE96322d65832A819;
  address pickleAddress = 0x429881672B9AE42b8EbA0E26cD9C73711b891Ca5;

  Counters.Counter private _tokenIds;
  mapping(uint256 => address) public tokenDirectory;
  Counters.Counter private _farmIds;
  mapping(uint256 => mapping(address => address)) public farmDirectory;

  uint256 public pickleSellQty = 10;

  IUniswapV2ZapIn public ZAPIN =
    IUniswapV2ZapIn(0xE83554B397BdA8ECAE7FEE5aeE532e83Ee9eB29D);
  IUniswapV2ZapOut public ZAPOUT =
    IUniswapV2ZapOut(0x79B6C6F8634ea477ED725eC23b7b6Fcb41F00E58);
  IUniswapV2Pipe public rebalance =
    IUniswapV2Pipe(0xBdcd4Dcc79bA2C4088323ca94F443a05A23cA372); // ZAPPER PIPE
  IWETH public weth = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
  IERC20 public usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
  IERC20 public pickle = IERC20(0x429881672B9AE42b8EbA0E26cD9C73711b891Ca5);

  // IERC20 farmToken = IERC20(0xa0246c9032bC3A600820415aE600c6388619A14D);
  // IERC20 pickleEthLPToken = IERC20(0xdc98556Ce24f007A5eF6dC1CE96322d65832A819);
  // IMasterChef masterChef = IMasterChef(0xbD17B1ce622d73bD438b9E658acA5996dc394b0d);
  // IAutoStake autoStake = IAutoStake(0x25550Cccbd68533Fa04bFD3e3AC4D09f9e00Fc50);

  IUniswapV2Router02 uniswap =
    IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

  constructor() payable {
    tokenDirectory[
      _tokenIds.current()
    ] = 0xa0246c9032bC3A600820415aE600c6388619A14D; // add FARM to tokenDirectory
    farmDirectory[_farmIds.current()][
      0xa0246c9032bC3A600820415aE600c6388619A14D
    ] = 0x25550Cccbd68533Fa04bFD3e3AC4D09f9e00Fc50; // set (FARM => AutoStaker)

    _tokenIds.increment(); // inc tokenIds
    tokenDirectory[
      _tokenIds.current()
    ] = 0xdc98556Ce24f007A5eF6dC1CE96322d65832A819; // add PICKLE to tokenDirectory

    _farmIds.increment(); // inc stakingIds
    farmDirectory[_farmIds.current()][
      0xdc98556Ce24f007A5eF6dC1CE96322d65832A819
    ] = 0xbD17B1ce622d73bD438b9E658acA5996dc394b0d; // set (PICKLE => MasterChef)
  }

  //   fallback() external payable {}

  function getStakedBalance(
    uint256 _farmId,
    address _owner,
    address _lpTokenAddress
  ) public view returns (uint256) {
    if (_farmId == 0) {
      IAutoStake autoStake =
        IAutoStake(farmDirectory[_farmId][_lpTokenAddress]);
      return autoStake.balanceOf(_owner);
    } else if (_farmId == 1) {
      IMasterChef masterChef =
        IMasterChef(farmDirectory[_farmId][_lpTokenAddress]);
      (uint256 amount, ) = masterChef.userInfo(0, address(this));
      return amount;
    }
  }

  function addFarm(address _lpTokenAddress, address _farmAddress)
    public
    onlyOwner
    returns (uint256)
  {
    _farmIds.increment();
    uint256 farmId = _farmIds.current();
    farmDirectory[farmId][_lpTokenAddress] = _farmAddress;
    assert(farmDirectory[farmId][_lpTokenAddress] == _farmAddress);
    return farmId;
  }

  function enterFarm(uint256 _farmId, address _lpTokenAddress)
    public
    payable
    onlyOwner
    returns (bool)
  {
    IERC20 lpToken = IERC20(_lpTokenAddress);
    uint256 ownerBalance = lpToken.balanceOf(msg.sender);

    require(
      lpToken.transferFrom(msg.sender, address(this), ownerBalance),
      // token.safeTransferFrom(msg.sender, address(this), ownerBalance),
      "Not enough tokens to transferFrom or no approval"
    );

    uint256 approvedAmount =
      lpToken.allowance(address(this), farmDirectory[_farmId][_lpTokenAddress]);

    if (approvedAmount < ownerBalance) {
      lpToken.approve(
        farmDirectory[_farmId][_lpTokenAddress],
        ownerBalance.mul(10000)
      );
    }

    _stake(_farmId, ownerBalance, _lpTokenAddress);
    return true;
  }

  function exitFarm(uint256 _farmId, address _lpTokenAddress)
    public
    payable
    onlyOwner
    returns (bool)
  {
    IERC20 lpToken = IERC20(_lpTokenAddress);
    _unstake(_farmId, _lpTokenAddress);
    uint256 currentTokenBalance = lpToken.balanceOf(address(this));

    if (_farmId == 0) {
      // swap from unstaked tokens to usdc and transfer back to owner
      lpToken.approve(uniAddress, 1000000000000000000000000000000000000);
      _performUniswap(_lpTokenAddress, usdcAddress, currentTokenBalance);
      require(
        usdc.transfer(msg.sender, usdc.balanceOf(address(this))),
        "You dont have enough tokens inside this contract to withdraw from deposits"
      );
      return true;
    } else if (_farmId == 1) {
      IMasterChef masterChef =
        IMasterChef(farmDirectory[_farmId][_lpTokenAddress]);
      (uint256 amount, ) = masterChef.userInfo(0, address(this));
      uint256 minReceive = amount.sub(1);
      uint256 returnAmount =
        zapOutEthPair(ETH_ADDRESS, _lpTokenAddress, amount, minReceive);
      require(
        lpToken.transfer(msg.sender, currentTokenBalance),
        "You dont have enough tokens inside this contract to withdraw from deposits"
      );
      if (pickle.balanceOf(address(this)) >= pickleSellQty) {
        _sellPicklesForEth();
      }
      return true;
    }

    return false;
  }

  // function rebalance() public onlyOwner {}

  function zapIn(
    address _toWhomToIssue,
    address _FromTokenContractAddress,
    address _ToUnipoolToken0,
    address _ToUnipoolToken1,
    uint256 _amount,
    uint256 _minPoolTokens
  ) public payable onlyOwner returns (uint256) {
    uint256 returnAmount =
      ZAPIN.ZapIn(
        _toWhomToIssue,
        _FromTokenContractAddress,
        _ToUnipoolToken0,
        _ToUnipoolToken1,
        _amount,
        _minPoolTokens
      );
    return returnAmount;
  }

  function zapOutEthPair(
    address _ToTokenContractAddress,
    address _FromUniPoolAddress,
    uint256 _IncomingLP,
    uint256 _minTokensRecs
  ) public payable onlyOwner returns (uint256) {
    uint256 returnAmount =
      ZAPOUT.ZapOut(
        _ToTokenContractAddress,
        _FromUniPoolAddress,
        _IncomingLP,
        _minTokensRecs
      );
    require(returnAmount > 0, "Zap out failed");
    return returnAmount;
  }

  function zapOutTokenPair(address _FromUniPoolAddress, uint256 _IncomingLP)
    public
    payable
    onlyOwner
    returns (uint256 amountA, uint256 amountB)
  {
    (uint256 amountA, uint256 amountB) =
      ZAPOUT.ZapOut2PairToken(_FromUniPoolAddress, _IncomingLP);
    require(amountA > 0 && amountB > 0, "Zap out failed");
    return (amountA, amountB);
  }

  function harvestPicklesConvertToEth() public onlyOwner returns (uint256) {
    IMasterChef masterChef =
      IMasterChef(0xbD17B1ce622d73bD438b9E658acA5996dc394b0d);
    uint256 pickleToHarvest = masterChef.pendingPickle(0, address(this));
    require(pickleToHarvest >= pickleSellQty, "Too few Pickles to harvest.");
    masterChef.withdraw(0, 0); // TEST THIS WORKS
    _sellPicklesForEth();
    // return
  }

  function withdrawTokens(
    address _token,
    uint256 _amount,
    address payable _destination
  ) public onlyOwner returns (bool) {
    if (address(_token) == ETH_ADDRESS) {
      _destination.transfer(_amount);
    } else {
      IERC20 token = IERC20(_token);
      // require(token.safeTransfer(_destination, _amount));
      require(token.transfer(_destination, _amount));
    }
    return true;
  }

  function kill() public virtual onlyOwner {
    selfdestruct(msg.sender);
  }

  function updatefarmContract(
    uint256 _farmId,
    address _lpTokenAddress,
    address _newFarmAddress
  ) public onlyOwner returns (bool) {
    farmDirectory[_farmId][_lpTokenAddress] = _newFarmAddress;
    return true;
  }

  function updateUSDCToken(address _newAddress)
    public
    onlyOwner
    returns (bool)
  {
    usdc = IERC20(_newAddress);
    usdcAddress = _newAddress;
    return true;
  }

  function updatePickleSellQty(uint256 _newQty)
    public
    onlyOwner
    returns (bool)
  {
    pickleSellQty = _newQty;
    return true;
  }

  function updatePickleAddress(address _newPickleAddress)
    public
    onlyOwner
    returns (bool)
  {
    pickleAddress = _newPickleAddress;
    pickle = IERC20(pickleAddress);
    return true;
  }

  function updateUniswap(address _newAddress) public onlyOwner returns (bool) {
    uniswap = IUniswapV2Router02(_newAddress);
    uniAddress = _newAddress;
    return true;
  }

  function _stake(
    uint256 _farmId,
    uint256 _amount,
    address _lpTokenAddress
  ) internal returns (bool) {
    uint256 amountStaked;
    if (_farmId == 0) {
      IAutoStake autoStake =
        IAutoStake(farmDirectory[_farmId][_lpTokenAddress]);
      autoStake.stake(_amount);
      amountStaked = autoStake.balanceOf(address(this));
    } else if (_farmId == 1) {
      IMasterChef masterChef =
        IMasterChef(farmDirectory[_farmId][_lpTokenAddress]);
      masterChef.deposit(0, _amount);
      (uint256 amount, ) = masterChef.userInfo(0, address(this));
      amountStaked = amount;
    }
    assert(_amount == amountStaked); // DOES THIS WORK
    return true;
  }

  function _unstake(uint256 _farmId, address _lpTokenAddress)
    internal
    returns (bool)
  {
    if (_farmId == 0) {
      IAutoStake autoStake =
        IAutoStake(farmDirectory[_farmId][_lpTokenAddress]);
      autoStake.exit();
    } else if (_farmId == 1) {
      IMasterChef masterChef =
        IMasterChef(farmDirectory[_farmId][_lpTokenAddress]);
      (uint256 amount, ) = masterChef.userInfo(0, address(this));
      masterChef.withdraw(0, amount);
    }

    return true;
  }

  function _sellPicklesForEth() internal returns (uint256) {
    uint256 pickleBalance = pickle.balanceOf(address(this));
    pickle.approve(uniAddress, 1000000000000000000000000000000000000);
    uint256 wethAmount =
      _performUniswap(pickleAddress, wethAddress, pickleBalance);
    weth.withdraw(wethAmount);
    return wethAmount;
  }

  function _performUniswap(
    address _sellToken,
    address _buyToken,
    uint256 _amount
  ) internal returns (uint256 buyTokens) {
    address[] memory path = new address[](2);
    path[0] = _sellToken;
    path[1] = _buyToken;
    uint256[] memory amounts =
      uniswap.swapExactTokensForTokens(
        _amount,
        1,
        path,
        address(this),
        1000000000000000
      );
    // uint256[] memory amounts = _performUniswapT4T(path, _amount);
    uint256 outputAmount = amounts[1];
    return outputAmount;
  }

  function _performUniswapT4T(address[] memory _path, uint256 _amount)
    internal
    returns (uint256[] memory buyTokens)
  {
    uint256 deadline = 1000000000000000;
    uint256[] memory outputAmounts =
      uniswap.swapExactTokensForTokens(
        _amount,
        1,
        _path,
        address(this),
        deadline
      );
    return outputAmounts;
  }
}
