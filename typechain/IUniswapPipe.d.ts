/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import {
  ethers,
  EventFilter,
  Signer,
  BigNumber,
  BigNumberish,
  PopulatedTransaction,
} from "ethers";
import {
  Contract,
  ContractTransaction,
  Overrides,
  CallOverrides,
} from "@ethersproject/contracts";
import { BytesLike } from "@ethersproject/bytes";
import { Listener, Provider } from "@ethersproject/providers";
import { FunctionFragment, EventFragment, Result } from "@ethersproject/abi";

interface IUniswapPipeInterface extends ethers.utils.Interface {
  functions: {
    "PipeUniV2(address,address,uint256,address,uint256)": FunctionFragment;
    "PipeUniV2WithPermit(address,address,uint256,address,uint256,uint256,uint256,uint8,bytes32,bytes32)": FunctionFragment;
  };

  encodeFunctionData(
    functionFragment: "PipeUniV2",
    values: [string, string, BigNumberish, string, BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "PipeUniV2WithPermit",
    values: [
      string,
      string,
      BigNumberish,
      string,
      BigNumberish,
      BigNumberish,
      BigNumberish,
      BigNumberish,
      BytesLike,
      BytesLike
    ]
  ): string;

  decodeFunctionResult(functionFragment: "PipeUniV2", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "PipeUniV2WithPermit",
    data: BytesLike
  ): Result;

  events: {};
}

export class IUniswapPipe extends Contract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  on(event: EventFilter | string, listener: Listener): this;
  once(event: EventFilter | string, listener: Listener): this;
  addListener(eventName: EventFilter | string, listener: Listener): this;
  removeAllListeners(eventName: EventFilter | string): this;
  removeListener(eventName: any, listener: Listener): this;

  interface: IUniswapPipeInterface;

  functions: {
    PipeUniV2(
      _toWhomToIssue: string,
      _incomingUniV2Exchange: string,
      _IncomingLPT: BigNumberish,
      _toUniV2Exchange: string,
      _minPoolTokens: BigNumberish,
      overrides?: Overrides
    ): Promise<ContractTransaction>;

    "PipeUniV2(address,address,uint256,address,uint256)"(
      _toWhomToIssue: string,
      _incomingUniV2Exchange: string,
      _IncomingLPT: BigNumberish,
      _toUniV2Exchange: string,
      _minPoolTokens: BigNumberish,
      overrides?: Overrides
    ): Promise<ContractTransaction>;

    PipeUniV2WithPermit(
      _toWhomToIssue: string,
      _incomingUniV2Exchange: string,
      _IncomingLPT: BigNumberish,
      _toUniV2Exchange: string,
      _minPoolTokens: BigNumberish,
      _approvalAmount: BigNumberish,
      _deadline: BigNumberish,
      v: BigNumberish,
      r: BytesLike,
      s: BytesLike,
      overrides?: Overrides
    ): Promise<ContractTransaction>;

    "PipeUniV2WithPermit(address,address,uint256,address,uint256,uint256,uint256,uint8,bytes32,bytes32)"(
      _toWhomToIssue: string,
      _incomingUniV2Exchange: string,
      _IncomingLPT: BigNumberish,
      _toUniV2Exchange: string,
      _minPoolTokens: BigNumberish,
      _approvalAmount: BigNumberish,
      _deadline: BigNumberish,
      v: BigNumberish,
      r: BytesLike,
      s: BytesLike,
      overrides?: Overrides
    ): Promise<ContractTransaction>;
  };

  PipeUniV2(
    _toWhomToIssue: string,
    _incomingUniV2Exchange: string,
    _IncomingLPT: BigNumberish,
    _toUniV2Exchange: string,
    _minPoolTokens: BigNumberish,
    overrides?: Overrides
  ): Promise<ContractTransaction>;

  "PipeUniV2(address,address,uint256,address,uint256)"(
    _toWhomToIssue: string,
    _incomingUniV2Exchange: string,
    _IncomingLPT: BigNumberish,
    _toUniV2Exchange: string,
    _minPoolTokens: BigNumberish,
    overrides?: Overrides
  ): Promise<ContractTransaction>;

  PipeUniV2WithPermit(
    _toWhomToIssue: string,
    _incomingUniV2Exchange: string,
    _IncomingLPT: BigNumberish,
    _toUniV2Exchange: string,
    _minPoolTokens: BigNumberish,
    _approvalAmount: BigNumberish,
    _deadline: BigNumberish,
    v: BigNumberish,
    r: BytesLike,
    s: BytesLike,
    overrides?: Overrides
  ): Promise<ContractTransaction>;

  "PipeUniV2WithPermit(address,address,uint256,address,uint256,uint256,uint256,uint8,bytes32,bytes32)"(
    _toWhomToIssue: string,
    _incomingUniV2Exchange: string,
    _IncomingLPT: BigNumberish,
    _toUniV2Exchange: string,
    _minPoolTokens: BigNumberish,
    _approvalAmount: BigNumberish,
    _deadline: BigNumberish,
    v: BigNumberish,
    r: BytesLike,
    s: BytesLike,
    overrides?: Overrides
  ): Promise<ContractTransaction>;

  callStatic: {
    PipeUniV2(
      _toWhomToIssue: string,
      _incomingUniV2Exchange: string,
      _IncomingLPT: BigNumberish,
      _toUniV2Exchange: string,
      _minPoolTokens: BigNumberish,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    "PipeUniV2(address,address,uint256,address,uint256)"(
      _toWhomToIssue: string,
      _incomingUniV2Exchange: string,
      _IncomingLPT: BigNumberish,
      _toUniV2Exchange: string,
      _minPoolTokens: BigNumberish,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    PipeUniV2WithPermit(
      _toWhomToIssue: string,
      _incomingUniV2Exchange: string,
      _IncomingLPT: BigNumberish,
      _toUniV2Exchange: string,
      _minPoolTokens: BigNumberish,
      _approvalAmount: BigNumberish,
      _deadline: BigNumberish,
      v: BigNumberish,
      r: BytesLike,
      s: BytesLike,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    "PipeUniV2WithPermit(address,address,uint256,address,uint256,uint256,uint256,uint8,bytes32,bytes32)"(
      _toWhomToIssue: string,
      _incomingUniV2Exchange: string,
      _IncomingLPT: BigNumberish,
      _toUniV2Exchange: string,
      _minPoolTokens: BigNumberish,
      _approvalAmount: BigNumberish,
      _deadline: BigNumberish,
      v: BigNumberish,
      r: BytesLike,
      s: BytesLike,
      overrides?: CallOverrides
    ): Promise<BigNumber>;
  };

  filters: {};

  estimateGas: {
    PipeUniV2(
      _toWhomToIssue: string,
      _incomingUniV2Exchange: string,
      _IncomingLPT: BigNumberish,
      _toUniV2Exchange: string,
      _minPoolTokens: BigNumberish,
      overrides?: Overrides
    ): Promise<BigNumber>;

    "PipeUniV2(address,address,uint256,address,uint256)"(
      _toWhomToIssue: string,
      _incomingUniV2Exchange: string,
      _IncomingLPT: BigNumberish,
      _toUniV2Exchange: string,
      _minPoolTokens: BigNumberish,
      overrides?: Overrides
    ): Promise<BigNumber>;

    PipeUniV2WithPermit(
      _toWhomToIssue: string,
      _incomingUniV2Exchange: string,
      _IncomingLPT: BigNumberish,
      _toUniV2Exchange: string,
      _minPoolTokens: BigNumberish,
      _approvalAmount: BigNumberish,
      _deadline: BigNumberish,
      v: BigNumberish,
      r: BytesLike,
      s: BytesLike,
      overrides?: Overrides
    ): Promise<BigNumber>;

    "PipeUniV2WithPermit(address,address,uint256,address,uint256,uint256,uint256,uint8,bytes32,bytes32)"(
      _toWhomToIssue: string,
      _incomingUniV2Exchange: string,
      _IncomingLPT: BigNumberish,
      _toUniV2Exchange: string,
      _minPoolTokens: BigNumberish,
      _approvalAmount: BigNumberish,
      _deadline: BigNumberish,
      v: BigNumberish,
      r: BytesLike,
      s: BytesLike,
      overrides?: Overrides
    ): Promise<BigNumber>;
  };

  populateTransaction: {
    PipeUniV2(
      _toWhomToIssue: string,
      _incomingUniV2Exchange: string,
      _IncomingLPT: BigNumberish,
      _toUniV2Exchange: string,
      _minPoolTokens: BigNumberish,
      overrides?: Overrides
    ): Promise<PopulatedTransaction>;

    "PipeUniV2(address,address,uint256,address,uint256)"(
      _toWhomToIssue: string,
      _incomingUniV2Exchange: string,
      _IncomingLPT: BigNumberish,
      _toUniV2Exchange: string,
      _minPoolTokens: BigNumberish,
      overrides?: Overrides
    ): Promise<PopulatedTransaction>;

    PipeUniV2WithPermit(
      _toWhomToIssue: string,
      _incomingUniV2Exchange: string,
      _IncomingLPT: BigNumberish,
      _toUniV2Exchange: string,
      _minPoolTokens: BigNumberish,
      _approvalAmount: BigNumberish,
      _deadline: BigNumberish,
      v: BigNumberish,
      r: BytesLike,
      s: BytesLike,
      overrides?: Overrides
    ): Promise<PopulatedTransaction>;

    "PipeUniV2WithPermit(address,address,uint256,address,uint256,uint256,uint256,uint8,bytes32,bytes32)"(
      _toWhomToIssue: string,
      _incomingUniV2Exchange: string,
      _IncomingLPT: BigNumberish,
      _toUniV2Exchange: string,
      _minPoolTokens: BigNumberish,
      _approvalAmount: BigNumberish,
      _deadline: BigNumberish,
      v: BigNumberish,
      r: BytesLike,
      s: BytesLike,
      overrides?: Overrides
    ): Promise<PopulatedTransaction>;
  };
}
