import { dylib } from "./bindings.ts";
import { readCString, Sanitizer } from "./utils.ts";

export type TransactionInfoPtr = Deno.PointerObject<"transactionInfo">;

export class TransactionInfo {
  #txInfoPtr: TransactionInfoPtr;
  sanitizer?: Sanitizer;

  constructor(txInfoPtr: TransactionInfoPtr, sanitizer?: Sanitizer) {
    this.#txInfoPtr = txInfoPtr;
    this.sanitizer = sanitizer;
  }

  async direction(): Promise<"in" | "out"> {
    switch (await dylib.symbols.MONERO_TransactionInfo_direction(this.#txInfoPtr)) {
      case 0:
        return "in";
      case 1:
        return "out";
      default:
        await this.sanitizer?.();
        throw new Error("Invalid TransactionInfo direction");
    }
  }

  async isPending(): Promise<boolean> {
    return await dylib.symbols.MONERO_TransactionInfo_isPending(this.#txInfoPtr);
  }

  async isFailed(): Promise<boolean> {
    return await dylib.symbols.MONERO_TransactionInfo_isFailed(this.#txInfoPtr);
  }

  async isCoinbase(): Promise<boolean> {
    return await dylib.symbols.MONERO_TransactionInfo_isCoinbase(this.#txInfoPtr);
  }

  async amount(): Promise<bigint> {
    return await dylib.symbols.MONERO_TransactionInfo_amount(this.#txInfoPtr);
  }

  async fee(): Promise<bigint> {
    return await dylib.symbols.MONERO_TransactionInfo_fee(this.#txInfoPtr);
  }

  async blockHeight(): Promise<bigint> {
    return await dylib.symbols.MONERO_TransactionInfo_blockHeight(this.#txInfoPtr);
  }

  async description(): Promise<string> {
    const description = await dylib.symbols.MONERO_TransactionInfo_description(this.#txInfoPtr);
    return readCString(description) || "";
  }

  async subaddrIndex(): Promise<string> {
    const subaddrIndex = await dylib.symbols.MONERO_TransactionInfo_subaddrIndex(this.#txInfoPtr);
    return readCString(subaddrIndex) || "";
  }

  async subaddrAccount(): Promise<number> {
    return await dylib.symbols.MONERO_TransactionInfo_subaddrAccount(this.#txInfoPtr);
  }

  async label(): Promise<string> {
    const label = await dylib.symbols.MONERO_TransactionInfo_label(this.#txInfoPtr);
    return readCString(label) || "";
  }

  async confirmations(): Promise<bigint> {
    return await dylib.symbols.MONERO_TransactionInfo_confirmations(this.#txInfoPtr);
  }

  async unlockTime(): Promise<bigint> {
    return await dylib.symbols.MONERO_TransactionInfo_unlockTime(this.#txInfoPtr);
  }

  async hash(): Promise<string> {
    const hash = await dylib.symbols.MONERO_TransactionInfo_hash(this.#txInfoPtr);
    return readCString(hash) || "";
  }

  async timestamp(): Promise<bigint> {
    return await dylib.symbols.MONERO_TransactionInfo_timestamp(this.#txInfoPtr);
  }

  async paymentId(): Promise<string> {
    const paymentId = await dylib.symbols.MONERO_TransactionInfo_paymentId(this.#txInfoPtr);
    return readCString(paymentId) || "";
  }

  async transfersCount(): Promise<number> {
    return await dylib.symbols.MONERO_TransactionInfo_transfers_count(this.#txInfoPtr);
  }

  async transfersAmount(index: number): Promise<bigint> {
    return await dylib.symbols.MONERO_TransactionInfo_transfers_amount(this.#txInfoPtr, index);
  }

  async transfersAddress(index: number): Promise<string> {
    const transfersAddress = await dylib.symbols.MONERO_TransactionInfo_transfers_address(this.#txInfoPtr, index);
    return readCString(transfersAddress) || "";
  }
}
