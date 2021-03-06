/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer } from "ethers";
import { Provider } from "@ethersproject/providers";

import type { IUniswapV2ZapOut } from "../IUniswapV2ZapOut";

export class IUniswapV2ZapOut__factory {
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): IUniswapV2ZapOut {
    return new Contract(address, _abi, signerOrProvider) as IUniswapV2ZapOut;
  }
}

const _abi = [
  {
    inputs: [
      {
        internalType: "address",
        name: "_ToTokenContractAddress",
        type: "address",
      },
      {
        internalType: "address",
        name: "_FromUniPoolAddress",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "_IncomingLP",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "_minTokensRec",
        type: "uint256",
      },
    ],
    name: "ZapOut",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "payable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "_FromUniPoolAddress",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "_IncomingLP",
        type: "uint256",
      },
    ],
    name: "ZapOut2PairToken",
    outputs: [
      {
        internalType: "uint256",
        name: "amountA",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "amountB",
        type: "uint256",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
];
