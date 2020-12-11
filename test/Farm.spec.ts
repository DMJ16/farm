import "dotenv/config";
import { ethers } from "hardhat";
import { Signer } from "ethers";
import { deployContract } from "ethereum-waffle";
import {
  Contract,
  ContractInterface,
  ContractTransaction,
} from "@ethersproject/contracts";
import { formatEther, parseEther } from "@ethersproject/units";
import { BigNumber, BigNumberish } from "@ethersproject/bignumber";
import { TransactionResponse } from "@ethersproject/providers";
import { expect } from "chai";
import {
  // getWallet,
  // getContract,
  // getWebSocketProvider,
  // formatEtherDigits,
  // getTokenAddressFromSymbol,
  // from18Decimal,
  // formatEtherAsFloat,
  getFarmAddress,
  getTraderGasInWei,
} from "../utils/helpers";
import axios from "axios";

import * as path from "path";
import express from "express";
// const fileGetContents = require("file-get-contents");
import erc20ABI from "../utils/abi/erc20.json";
import FarmArtifact from "../artifacts/contracts/Farm.sol/Farm.json";
import { Farm, Farm__factory } from "../typechain";

// impermanent_loss = 2 * sqrt(price_ratio) / (1+price_ratio) — 1
// const pvtKey = process.env.DEV_PRIVATE_KEY ?? "";
// const apiKey = process.env.RPC_API_KEY ?? "";
// const PORT = process.env.PORT || 5000;

let admin: Signer;
let farmFactory: Farm__factory;
let farm: Farm;
describe("Example", () => {
  beforeEach(async () => {
    admin = ethers.provider.getSigner(process.env.DEV_ADDRESS as string);
    farmFactory = (await ethers.getContractFactory(
      "Farm",
      admin
    )) as Farm__factory;
    farm = await farmFactory.deploy();
    await farm.deployed();
    console.log("farm deployed to:", farm.address);
    // const farm = getContract()(farm.address)(FarmArtifact.abi);
  });

  it("enters farm", async () => {
    const enterFarm = async (farmId: BigNumberish, lpTokenAddress: string) => {
      //more advanced version would set a high enough gas price,
      // and accept multiple parameters for specifiying specific farms and amounts,
      // as well as have special handlers in the smart contract to handle LP token liquidations
      const gasPriceInWei: BigNumber = getTraderGasInWei(
        (await axios.get("http://ethgas.watch/api/gas")).data.instant.gwei
      );
      const tx: ContractTransaction = await farm.enterFarm(
        farmId,
        lpTokenAddress,
        {
          gasPrice: gasPriceInWei,
          gasLimit: 5000000,
          value: 0,
        }
      );
      const txResponse: TransactionResponse = await admin.sendTransaction(tx);
    };
  });

  it("exits farm", async () => {
    const exitFarm = async (farmId: BigNumberish, lpTokenAddress: string) => {
      //more advanced version would set a high enough gas price,
      // and accept multiple parameters for specifiying specific farms and amounts,
      // as well as have special handlers in the smart contract to handle LP token liquidations
      const gasPriceInWei: BigNumber = getTraderGasInWei(
        (await axios.get("http://ethgas.watch/api/gas")).data.instant.gwei
      );
      const tx: ContractTransaction = await farm.exitFarm(
        farmId,
        lpTokenAddress,
        {
          gasPrice: gasPriceInWei,
          gasLimit: 5000000,
          value: 0,
        }
      );
      const txResponse: TransactionResponse = await admin.sendTransaction(tx);
    };
  });
});
// express()
//   .use(express.static(path.join(__dirname, "public")))
//   .set("views", path.join(__dirname, "views"))
//   .set("view engine", "ejs")
//   .get("/", (_, res) => res.send("Farm Enter & Exit Bot"))
//   .get("/enterFarm", function (_, res) {
//more advanced version would set a high enough gas price, and accept multiple parameters for specifiying specific farms and amounts, as well as have special handlers in the smart contract to handle LP token liquidations
//replace with your token from Harvest
// enterFarm(1, "0xa0246c9032bC3A600820415aE600c6388619A14D");
//     res.send("exitFarm transaction attempted");
//   })
//   .get("/exitFarm", function (_, res) {
//     //more advanced version would set a high enough gas price, and accept multiple parameters for specifiying specific farms and amounts, as well as have special handlers in the smart contract to handle LP token liquidations
//     //replace with your token from Harvest
//     // exitFarm(1, "0xa0246c9032bC3A600820415aE600c6388619A14D");
//     res.send("exitFarm transaction attempted");
//   })
//   .listen(PORT, () => console.log(`Listening on ${PORT}`));
