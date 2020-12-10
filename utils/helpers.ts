import {
  BaseProvider,
  InfuraProvider,
  Provider,
} from "@ethersproject/providers";
import { Signer } from "@ethersproject/abstract-signer";
import { Contract, ContractInterface } from "@ethersproject/contracts";
import { Wallet } from "@ethersproject/wallet";

export const getInfuraProvider = (network: string = "homestead") => (
  infuraProject_ID: string
): BaseProvider => new InfuraProvider(network, { infura: infuraProject_ID });

export const getWallet = (network: string = "homestead") => (
  pvtKey: string
) => (infuraProject_ID: string): Wallet =>
  new Wallet(pvtKey, getInfuraProvider(network)(infuraProject_ID));

export const getContract = (signerOrProvider: Signer | Provider) => (
  contractAddress: string
) => (contractABI: ContractInterface): Contract =>
  new Contract(contractAddress, contractABI, signerOrProvider);
