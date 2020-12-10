import {
  BaseProvider,
  InfuraProvider,
  Provider,
  InfuraWebSocketProvider,
} from "@ethersproject/providers";
import { Signer } from "@ethersproject/abstract-signer";
import { Contract, ContractInterface } from "@ethersproject/contracts";
import { Wallet } from "@ethersproject/wallet";
import {
  parseUnits,
  parseEther,
  formatUnits,
  formatEther,
} from "@ethersproject/units";
import { BigNumber, BigNumberish } from "@ethersproject/bignumber";
import { tokenAddressMap } from "./tokens";
import { getAddress } from "@ethersproject/address";

export const getWebSocketProvider = (network: string = "homestead") => (
  apiKey: string
): InfuraWebSocketProvider => new InfuraWebSocketProvider(network, apiKey);

export const getInfuraProvider = (network: string = "homestead") => (
  apiKey: string
): BaseProvider => new InfuraProvider(network, { infura: apiKey });

export const getWallet = (network: string = "homestead") => (
  pvtKey: string
) => (apiKey: string): Wallet =>
  new Wallet(pvtKey, getInfuraProvider(network)(apiKey));

export const getContract = (signerOrProvider: Signer | Provider) => (
  contractAddress: string
) => (contractABI: ContractInterface): Contract =>
  new Contract(contractAddress, contractABI, signerOrProvider);

export const formatEtherAsFloat = (
  wei: BigNumberish,
  digits: number = 2
): number => parseFloat(formatEtherDigits(wei, digits));

export const formatEtherDigits = (wei: BigNumberish, digits?: number): string =>
  Number(formatEther(wei)).toFixed(digits);

export const from18Decimal = (num: number): number => num / Math.pow(10, 18);

export const to18Decimal = (num: number): number => num * Math.pow(10, 18);

export const fromBN18Decimal = (BN: BigNumber): BigNumber =>
  BN.div(BigNumber.from("10").pow(BigNumber.from("18")));

export const toBN18Decimal = (BN: BigNumber): BigNumber =>
  BN.mul(BigNumber.from("10").pow(BigNumber.from("18")));

export const tryCatch = <T>(expression: T): T => {
  try {
    return expression;
  } catch (error) {
    throw error;
  }
};

// DISPLAY LOGIC

export const formatBTCTokens = (token: string) => (
  amount: BigNumber | string
): string => {
  if (!btcAddressMap.has(token))
    throw new Error("tokenAddress not contained in BTCAddresses Object");
  return token.toLowerCase() === "sbtc"
    ? formatEther(amount)
    : formatUnits(amount, 8);
};

export const parseBTCTokens = (token: string) => (
  amount: string
): BigNumber => {
  if (!btcAddressMap.has(token))
    throw new Error("tokenAddress not contained in BTCAddresses Object");
  return token.toLowerCase() === "sbtc"
    ? parseEther(amount)
    : parseUnits(amount, 8);
};

export const getTokenAddressFromSymbol = (symbol: string): string => {
  const adjSymbol = symbol.toUpperCase();
  if (!tokenAddressMap.has(adjSymbol)) throw new Error("Invalid token symbol");
  return getAddress(tokenAddressMap.get(adjSymbol)!);
};

type TokenData = [
  amountToken: number,
  amountTokenInWei: BigNumber,
  amountDaiInWei: BigNumber
];

const AMOUNT_BTC = 1;
const RECENT_BTC_PRICE = 19000;
const AMOUNT_BTC_WEI = parseEther(AMOUNT_BTC.toString());
const AMOUNT_DAI_WEI_BTC = parseEther(
  (AMOUNT_BTC * RECENT_BTC_PRICE).toString()
);

const AMOUNT_ETH = 100;
const RECENT_ETH_PRICE = 590;
const AMOUNT_ETH_WEI = parseEther(AMOUNT_ETH.toString());
const AMOUNT_DAI_WEI_ETH = parseEther(
  (AMOUNT_ETH * RECENT_ETH_PRICE).toString()
);

const AMOUNT_LINK = 100;
const RECENT_LINK_PRICE = 13;
const AMOUNT_LINK_WEI = parseEther(AMOUNT_LINK.toString());
const AMOUNT_DAI_WEI_LINK = parseEther(
  (AMOUNT_LINK * RECENT_LINK_PRICE).toString()
);

export const getTokenData = (
  memo: Map<string, TokenData> = new Map<string, TokenData>([
    ["BTC", [AMOUNT_BTC, AMOUNT_BTC_WEI, AMOUNT_DAI_WEI_BTC]],
    ["ETH", [AMOUNT_ETH, AMOUNT_ETH_WEI, AMOUNT_DAI_WEI_ETH]],
    ["LINK", [AMOUNT_LINK, AMOUNT_LINK_WEI, AMOUNT_DAI_WEI_LINK]],
  ])
) => (tokenSymbol: string) => (tokenInputData?: TokenData): TokenData => {
  const adjSymbol = tokenSymbol.toUpperCase();
  const tokenData: TokenData = tokenInputData ?? ({} as TokenData);
  if (memo.has(adjSymbol) && tokenInputData === undefined)
    return memo.get(adjSymbol) ?? tokenData;
  else {
    memo.set(adjSymbol, tokenData);
    return memo.get(adjSymbol) ?? tokenData;
  }
};

export const getTraderGasInWei = (
  instantGasPriceGwei: BigNumberish
): BigNumber => parseEther(formatUnits(instantGasPriceGwei, "gwei"));
