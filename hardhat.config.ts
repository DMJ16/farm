import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-ethers";
import "hardhat-typechain";
import { HardhatUserConfig } from "hardhat/config";
require("dotenv").config();

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      forking: {
        url: process.env.ALCHEMY_RPC as string,
        blockNumber: 11463565,
      },
    },
    // ropsten: {
    //   url: `https://ropsten.infura.io/v3/${process.env.RPC_API_KEY as string}`,
    //   accounts: [process.env.PRIVATE_KEY as string],
    // },
    // rinkeby: {
    //   url: `https://rinkeby.infura.io/v3/${process.env.RPC_API_KEY as string}`,
    //   accounts: [process.env.PRIVATE_KEY as string],
    // },
    // kovan: {
    //   url: `https://kovan.infura.io/v3/${process.env.RPC_API_KEY as string}`,
    //   accounts: [process.env.PRIVATE_KEY as string],
    // },
  },
  solidity: {
    compilers: [
      {
        version: "0.7.5",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.6.12",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  typechain: {
    outDir: "typechain",
    target: "ethers-v5",
  },
};

export default config;
