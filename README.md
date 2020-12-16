# 🚜 🌾 Farm

## Farm Contract

- The Farm contract provides functions for entering, exiting, and harvesting rewards from the below protocols.

- Node.js stop-loss strategy bot is forthcoming to monitor staked token prices.

- The bot calls the Farm contract to exit positions when prices are falling. The unstaked tokens are converted to USDC to preserve gains. Currently, the contract uses 1Inch for swaps.

- Once prices flatten out, the bot calls the Farm contract to convert USDC back into staking tokens and enter the previously exited staking position.

- All staking positions are composed of single ERC20 tokens opposed to liquidity provider (LP) tokens.

- The decision to exclude LP token staking was made so that the bot can more easily determine when to exit and enter staking positions. LP token staking would require monitoring impermanent loss--potentially an upgrade for the future.

- Big thank you to OrFeed/Proof's YouTube channel where I got the yield farming stop-loss idea. They generously provide examples for the discussed projects on their Github. [Proof YouTube Channel](https://www.youtube.com/channel/UCKDNphVF9TItP7PP9wJPM6g).

## Assets

- [Harvest Finance 🚜](https://harvest.finance/)
  - Stake $FARM token in the profit sharing pool.
  - Profit sharing pool receives 30% of the cashflows from the total revenues of the platform.
- [Power Index 🎱](https://powerindex.io/#/mainnet/)
  - Power Index has two index pools.
  - PIPT consists of 8 "blue chip" DeFi tokens with equal 12.5% weights.
  - YETI consists of the Yearn ecosystem protocols with heavy weighting toward $YFI and $SUSHI.
  - Current PIPT and YETI staking yields are around 300-400%.
- [Pickle Finance 🥒](https://pickle.finance/)
  - Pickle was recently "hacked". The hacker used a flashloan to take advantage of a smart contract vulnerability in one of the Pickle jars (Pickle's name for vaults).
  - In the aftermath of the attack, Yearn and Pickle announced that their developer teams were merging.
  - Currently, Pickle's next iteration of contracts and vault strategies are being audited and developed with the new Yearn ecosystem developer team.
  - When the new staking platform is released--which is slated for December or early January based on the Discord--the Farm contract will add Pickle staking and deploy to mainnet.
  - Previously, staking $PICKLE token earned $WETH. It seems that the new staking platform will discontinue $WETH rewards in favor of $PICKLE rewards.

## TO-DO:

- Complete Farm contract and iterate on it.
- Test smart contract security using MythX.
- Test Farm contract in TypeScript and in Solidity.
- Optimize for gas fees. See if Zapper-Uniswap contracts are more gas efficient than 1Inch.
- Evaluate whether 1Inch or Uniswap would be the best swap option for exiting positions and converting to USDC in terms of slippage and fees. 1Inch will likely route FARM and PICKLE transactions through Uniswap regardless since both tokens have their largest liquidity pools on Uniswap (FARM/USDC, FARM/WETH, PICKLE/WETH). PIPT/YETI largest pools are on Balancer and both against WETH.
- Write node.js bot using websockets and test it on a mainnet fork using Alchemy as the provider.
- Potentially add USD stablecoin farms on Harvest. Solo $USDC and $DAI farms on Harvest are yielding ~40% APY.
- Add Pickle once the new staking platform contract is deployed.
