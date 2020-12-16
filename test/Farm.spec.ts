import "dotenv/config";
import { ethers } from "hardhat";
// import { deployContract } from "ethereum-waffle";
import { ContractTransaction } from "@ethersproject/contracts";
import { TransactionResponse } from "@ethersproject/providers";
import { ContractReceipt } from "@ethersproject/contracts";
import { BigNumber } from "@ethersproject/bignumber";
import { Signer } from "@ethersproject/abstract-signer";
import { expect } from "chai";
import {
  getWebSocketProvider,
  formatEtherDigits,
  getTokenAddressFromSymbol,
  formatEtherAsFloat,
  getTraderGasInWei,
} from "../utils/helpers";
import axios from "axios";
import { Farm, Farm__factory } from "../typechain";

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
  });

  it("enters farm", async () => {
    const enterFarm = async (
      farm: Farm,
      platformName: string
    ): Promise<ContractReceipt> => {
      const gasPriceInWei: BigNumber = getTraderGasInWei(
        (await axios.get("http://ethgas.watch/api/gas")).data.instant.gwei
      );
      const tx = await farm.enterFarm(platformName, {
        gasPrice: gasPriceInWei,
        gasLimit: 5000000,
        value: 0,
      });
      const txResponse = await tx.wait();
      return txResponse;
    };
  });

  it("exits farm", async () => {
    const exitFarm = async (
      farm: Farm,
      platformName: string
    ): Promise<ContractReceipt> => {
      const gasPriceInWei: BigNumber = getTraderGasInWei(
        (await axios.get("http://ethgas.watch/api/gas")).data.instant.gwei
      );
      const tx = await farm.exitFarm(platformName, {
        gasPrice: gasPriceInWei,
        gasLimit: 5000000,
        value: 0,
      });
      const txResponse = await tx.wait();
      return txResponse;
    };
  });
});
