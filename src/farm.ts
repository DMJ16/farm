import "dotenv/config";
import { ethers } from "hardhat";
import { ContractReceipt } from "@ethersproject/contracts";
import { BigNumber } from "@ethersproject/bignumber";
import {
  getWebSocketProvider,
  formatEtherDigits,
  getTokenAddressFromSymbol,
  formatEtherAsFloat,
  getTraderGasInWei,
} from "../utils/helpers";
import axios from "axios";
import { Farm, Farm__factory } from "../typechain";

// set up websocket
const pvtKey = process.env.DEV_PRIVATE_KEY ?? "";
const apiKey = process.env.RPC_API_KEY ?? "";
const provider = getWebSocketProvider()(apiKey);

// deploy Farm contract helper
const deploy = async (): Promise<Farm> => {
  const admin = ethers.provider.getSigner(process.env.DEV_ADDRESS as string);
  const farmFactory = (await ethers.getContractFactory(
    "Farm",
    admin
  )) as Farm__factory;
  const farm = await farmFactory.deploy();
  await farm.deployed();
  return farm;
};

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
const main = async () => {
  const farm: Farm = await deploy();
};
