# 🚜 🌾 Farm

Farm contract provides functions for entering, exiting, and harvesting rewards from the below protocols.

Node.js script is forthcoming to monitor staked token prices and call the Farm contract to exit positions and convert tokens into USDC when prices are falling. The script is a simple stop-loss strategy.

Once prices flatten out, the bot calls the Farm contract to enter the previously exited staking position.

All investment positions are single governance token or ERC20 token staking opposed to staking liquidity provider tokens.

The decision to exclude LP token staking was made so that the strategy can more easily determine when to exit and enter positions. LP token staking would require monitoring impermanent loss--potentially an upgrade for the future.

Big thank you to OrFeed/Proof's YouTube channel where I got the stop-loss idea. They generously provide barebone examples for the discussed projects in their main repo. [Proof YouTube](https://www.youtube.com/channel/UCKDNphVF9TItP7PP9wJPM6g).

## Assets

- [Harvest Finance 🚜](https://harvest.finance/)
  - Stake $FARM token in the profit sharing pool.
  - Profit sharing pool receives 30% of the cashflows from the total revenues of the platform.
- [Power Index 🎱](https://powerindex.io/#/mainnet/)
  - Power Index has two index pools.
  - PIPT consists of 8 "blue chip" DeFi tokens with equal 12.5% weights.
  - YETI consists of the Yearn ecosystem protocols with heavy weighting toward $YFI and $SUSHI.
  - Current APY for staking both index tokens is around 300-400%.
- [Pickle Finance 🥒](https://pickle.finance/)
  - Pickle was recently "hacked". The hacker used a flashloan to take advantage of a smart contract vulnerability in the Pickle $DAI jar (Pickle's name for vaults).
  - In the aftermath of the attack, Yearn and Pickle announced that their developer teams were merging.
  - Currently, Pickle's next iteration of contracts and vault strategies are being audited and developed with the new Yearn ecosystem developer team.
  - When the new staking platform is released--which is slated for December or early January based on the Discord--the Farm contract will hopefully be ready for deployment to mainnet.
  - Previously staking $PICKLE token earned $WETH, but it seems that the new staking platform will use $PICKLE for rewards.

## TO-DO:

- Complete Farm contract and perfect it as testing begins.
- Optimize for gas fees. See if Zapper Uniswap contracts are viable and gas efficient.
- Evaluate whether 1Inch or Uniswap would be the best swap option for exiting positions and converting to USDC. 1Inch will likely route FARM and PICKLE transactions through Uniswap regardless since both tokens have their largest liquidity pools are Uniswap.
- Test Farm contract in TypeScript and in Solidity.
- Write node.js bot using websockets and test it on a mainnet fork using Alchemy as the provider.
- Potentially add USD stablecoin farms on Harvest. Solo $USDC and $DAI farms on Harvest are yielding ~40% APY.
- Add Pickle once the new staking platform contract is deployed.
