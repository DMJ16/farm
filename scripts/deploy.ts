import { ethers } from "hardhat";
// import {  } from "../typechain";

const main = async (): Promise<void> => {
  //   const factory = (await ethers.getContractFactory(
  //     ""
  //   )) as ;
  //   const contract = await factory.deploy();
  //   await contract.deployed();
  //   console.log("Contract deployed to:", contract.address);
};

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
