import "dotenv/config";
import { ethers } from "ethers";
import {
  getWallet,
  getContract,
  getWebSocketProvider,
  formatEtherDigits,
  getTokenAddressFromSymbol,
  from18Decimal,
  formatEtherAsFloat,
  getTraderGasInWei,
} from "../utils/helpers";
// import axios from "axios";
import { formatEther, parseEther } from "@ethersproject/units";
import { BigNumber } from "@ethersproject/bignumber";
import { ContractInterface } from "@ethersproject/contracts";
import { TransactionRequest } from "@ethersproject/providers";
import erc20ABI from "../utils/abi/erc20.json";
import * as path from "path";
import express from "express";
// const fileGetContents = require("file-get-contents");

// impermanent_loss = 2 * sqrt(price_ratio) / (1+price_ratio) — 1
const pvtKey = process.env.DEV_PRIVATE_KEY ?? "";
const apiKey = process.env.RPC_API_KEY ?? "";
const PORT = process.env.PORT || 5000;
// const wallet = getWallet()(pvtKey)(apiKey);
// const farmAddress = "YOURCONTRACTADDRESS";
// const farm = getContract()(farmAddress)(FarmArtifact.abi);

// const exitFarm = (whichFarm: string) => async (whichToken: string) => {
//   const tx = farm.exitFarm(parseInt(whichFarm), whichToken, {
//     from: process.env.DEV_ADDRESS,
//     //more advanced version would set a high enough gas price, and accept multiple parameters for specifiying specific farms and amounts, as well as have special handlers in the smart contract to handle LP token liquidations
//     gas: 5000000,
//     value: 0,
//   });
// };

// const enterFarm = (whichFarm: string) => async (whichToken: string) => {
//   //more advanced version would set a high enough gas price, and accept multiple parameters for specifiying specific farms and amounts, as well as have special handlers in the smart contract to handle LP token liquidations
//   const tx = farm.enterFarm(parseInt(whichFarm), whichToken, {
//     from: process.env.DEV_ADDRESS,
//     //'gasPrice':gasPriceGeneratedFast,
//     gas: 5000000,
//     value: 0,
//   });
// };

express()
  .use(express.static(path.join(__dirname, "public")))
  .set("views", path.join(__dirname, "views"))
  .set("view engine", "ejs")
  .get("/", (_, res) => res.send("Farm Enter & Exit Bot"))
  .get("/enterFarm", function (_, res) {
    //more advanced version would set a high enough gas price, and accept multiple parameters for specifiying specific farms and amounts, as well as have special handlers in the smart contract to handle LP token liquidations
    //replace with your token from Harvest
    // enterFarm(1, "0xa0246c9032bC3A600820415aE600c6388619A14D");
    res.send("exitFarm transaction attempted");
  })
  .get("/exitFarm", function (_, res) {
    // more advanced version would set a high enough gas price, and accept multiple parameters for specifiying specific farms and amounts, as well as have special handlers in the smart contract to handle LP token liquidations
    // replace with your token from Harvest
    // exitFarm(1, "0xa0246c9032bC3A600820415aE600c6388619A14D");
    res.send("exitFarm transaction attempted");
  })
  .listen(PORT, () => console.log(`Listening on ${PORT}`));
