import { fns } from "./bindings.ts";
import { C_SEPARATOR, CString, maybeMultipleStrings, readCString, SEPARATOR } from "./utils.ts";

export type TransactionInfoPtr = Deno.PointerObject<"pendingTransaction">;

export interface TransferData {
  address: string | null;
  amount: bigint;
}

export class TransactionInfo<MultDest extends boolean = boolean> {
  #ptr: TransactionInfoPtr;

  #amount!: bigint;
  #fee!: bigint;
  #timestamp!: bigint;
  #transfersCount!: number;
  #paymentId!: string | null;
  #hash!: string | null;

  #subaddrAccount!: number;
  #subaddrIndex!: string | null;

  #transfers!: readonly TransferData[];

  constructor(ptr: TransactionInfoPtr) {
    this.#ptr = ptr;
  }

  static async new(ptr: TransactionInfoPtr): Promise<TransactionInfo> {
    const instance = new TransactionInfo(ptr);

    const [amount, paymentId, fee, hash, subaddrIndex, subaddrAccount, timestamp, transfersCount] = await Promise.all([
      fns.TransactionInfo_amount(ptr),
      fns.TransactionInfo_paymentId(ptr).then(readCString),
      fns.TransactionInfo_fee(ptr),
      fns.TransactionInfo_hash(ptr).then(readCString),
      fns.TransactionInfo_subaddrIndex(ptr, C_SEPARATOR).then(readCString),
      fns.TransactionInfo_subaddrAccount(ptr),
      fns.TransactionInfo_timestamp(ptr),
      fns.TransactionInfo_transfers_count(ptr),
    ]);

    instance.#amount = amount;
    instance.#fee = fee;
    instance.#timestamp = timestamp;
    instance.#transfersCount = transfersCount;
    instance.#paymentId = paymentId;
    instance.#hash = hash;

    instance.#subaddrAccount = subaddrAccount;
    instance.#subaddrIndex = subaddrIndex;

    const transfers = [];
    for (let i = 0; i < transfersCount; ++i) {
      const [amount, address] = await Promise.all([
        fns.TransactionInfo_transfers_amount(ptr, i),
        fns.TransactionInfo_transfers_address(ptr, i).then(readCString),
      ]);

      transfers.push({ amount, address });
    }
    Object.freeze(transfers);
    instance.#transfers = transfers;

    return instance;
  }

  get amount(): bigint {
    return this.#amount;
  }

  get fee(): bigint {
    return this.#fee;
  }

  get timestamp(): bigint {
    return this.#timestamp;
  }

  get transfersCount(): number {
    return this.#transfersCount;
  }

  get paymentId(): string | null {
    return this.#paymentId;
  }

  get hash(): string | null {
    return this.#hash;
  }

  get subaddrAccount(): number {
    return this.#subaddrAccount;
  }

  get subaddrIndex(): string | null {
    return this.#subaddrIndex;
  }

  get transfers(): readonly TransferData[] {
    return this.#transfers;
  }

  async direction(): Promise<"in" | "out"> {
    switch (await fns.TransactionInfo_direction(this.#ptr)) {
      case 0:
        return "in";
      case 1:
        return "out";
      default:
        throw new Error("Invalid TransactionInfo direction");
    }
  }

  async description(): Promise<string | null> {
    return await readCString(
      await fns.TransactionInfo_description(this.#ptr),
    );
  }

  async label(): Promise<string | null> {
    return await readCString(
      await fns.TransactionInfo_label(this.#ptr),
    );
  }

  async confirmations(): Promise<bigint> {
    return await fns.TransactionInfo_confirmations(this.#ptr);
  }

  async unlockTime(): Promise<bigint> {
    return await fns.TransactionInfo_unlockTime(this.#ptr);
  }

  async isPending(): Promise<boolean> {
    return await fns.TransactionInfo_isPending(this.#ptr);
  }

  async isFailed(): Promise<boolean> {
    return await fns.TransactionInfo_isFailed(this.#ptr);
  }

  async isCoinbase(): Promise<boolean> {
    return await fns.TransactionInfo_isCoinbase(this.#ptr);
  }
}
