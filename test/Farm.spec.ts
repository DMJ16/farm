import "dotenv/config";
import { ethers } from "hardhat";
import { deployContract } from "ethereum-waffle";
import { ContractTransaction } from "@ethersproject/contracts";
import { TransactionResponse } from "@ethersproject/providers";
import { ContractReceipt } from "@ethersproject/contracts";
import { BigNumber } from "@ethersproject/bignumber";
import { Signer } from "@ethersproject/abstract-signer";
import { expect } from "chai";
import {
  getContract,
  getWebSocketProvider,
  formatEtherDigits,
  getTokenAddressFromSymbol,
  formatEtherAsFloat,
  getTraderGasInWei,
} from "../utils/helpers";
import axios from "axios";
import erc20ABI from "../utils/abi/erc20.json";
import FarmArtifact from "../artifacts/contracts/Farm.sol/Farm.json";
import { Farm, Farm__factory } from "../typechain";

const enterFarm = async (
  farm: Farm,
  stakingTokenName: string,
  useFundsInContract: boolean
): Promise<void> => {
  const gasPriceInWei: BigNumber = getTraderGasInWei(
    (await axios.get("http://ethgas.watch/api/gas")).data.instant.gwei
  );
  const tx = await farm.enterFarm(stakingTokenName, useFundsInContract, {
    gasPrice: gasPriceInWei,
    gasLimit: 5000000,
    value: 0,
  });
  await tx.wait(1);
};

const exitFarm = async (
  farm: Farm,
  stakingTokenName: string,
  returnTokenAddress: string
): Promise<void> => {
  const gasPriceInWei: BigNumber = getTraderGasInWei(
    (await axios.get("http://ethgas.watch/api/gas")).data.instant.gwei
  );
  const tx = await farm.exitFarm(stakingTokenName, returnTokenAddress, {
    gasPrice: gasPriceInWei,
    gasLimit: 5000000,
    value: 0,
  });
  await tx.wait(1);
};

let signers: Signer[];
let admin: Signer;
let adminAddress: string;
let FarmFactory: Farm__factory;
let FarmContract: Farm;
let farm: Farm;
describe("Farm Contract", () => {
  before(async () => {
    // admin = ethers.provider.getSigner();
    signers = await ethers.getSigners();
    admin = signers[0];
    adminAddress = await admin.getAddress();
    FarmFactory = (await ethers.getContractFactory(
      "Farm",
      admin
    )) as Farm__factory;
    FarmContract = await FarmFactory.deploy();
    farm = await FarmContract.deployed();
    console.log("Farm deployed to:", FarmContract.address);
  });

  it("enters Harvest profit sharing pool using caller's funds", async () => {
    // const farmTokenAddress = await farm.farmTokenAddress();
    // const farmToken = getContract(admin)(farmTokenAddress)(erc20ABI);
    // const initBalance: BigNumber = await farmToken.balanceOf(adminAddress);
    // await enterFarm(farm, "farm", false);
    // const stakedBalance = await farm.getStakedBalance("farm");
    // expect(stakedBalance == initBalance);
    // expect(stakedBalance.gt(BigNumber.from(0)));
  });

  it("enters Pickle rewards using caller's funds", async () => {
    // const pickleAddress = await farm.pickleAddress();
    // const pickleToken = getContract(admin)(pickleAddress)(erc20ABI);
    // const initBalance: BigNumber = await pickleToken.balanceOf(adminAddress);
    // await enterFarm(farm, "pickle", false);
    // const stakedBalance = await farm.getStakedBalance("pickle");
    // expect(stakedBalance == initBalance);
    // expect(stakedBalance.gt(BigNumber.from(0)));
  });
});
