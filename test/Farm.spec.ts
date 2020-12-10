import { ethers } from "hardhat";
import { expect } from "chai";
import { deployContract } from "ethereum-waffle";
import { Signer, BigNumber } from "ethers";
import { parseUnits, formatEther } from "@ethersproject/units";
import { Contract } from "@ethersproject/contracts";
import { Wallet } from "@ethersproject/wallet";
// import Artifact from ""
// import {  } from "../typechain";

describe("Example", () => {
  let signers: Signer[];
  let accounts: string[];
  let admin: Signer;

  beforeEach(async () => {
    signers = await ethers.getSigners();
    accounts = signers.map((wallet) => (<Wallet>wallet).address);
    admin = signers[0];
  });
});
