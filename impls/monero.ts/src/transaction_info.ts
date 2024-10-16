import { dylib } from "./bindings.ts";
import { getSymbol, readCString, Sanitizer } from "./utils.ts";

export type TransactionInfoPtr = Deno.PointerObject<"transactionInfo">;

export class TransactionInfo {
  #txInfoPtr: TransactionInfoPtr;
  sanitizer?: Sanitizer;

  constructor(txInfoPtr: TransactionInfoPtr, sanitizer?: Sanitizer) {
    this.#txInfoPtr = txInfoPtr;
    this.sanitizer = sanitizer;
  }

  async direction(): Promise<"in" | "out"> {
    switch (await getSymbol("TransactionInfo_direction")(this.#txInfoPtr)) {
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
    return await getSymbol("TransactionInfo_isPending")(this.#txInfoPtr);
  }

  async isFailed(): Promise<boolean> {
    return await getSymbol("TransactionInfo_isFailed")(this.#txInfoPtr);
  }

  async isCoinbase(): Promise<boolean> {
    return await getSymbol("TransactionInfo_isCoinbase")(this.#txInfoPtr);
  }

  async amount(): Promise<bigint> {
    return await getSymbol("TransactionInfo_amount")(this.#txInfoPtr);
  }

  async fee(): Promise<bigint> {
    return await getSymbol("TransactionInfo_fee")(this.#txInfoPtr);
  }

  async blockHeight(): Promise<bigint> {
    return await getSymbol("TransactionInfo_blockHeight")(this.#txInfoPtr);
  }

  async description(): Promise<string> {
    const description = await getSymbol("TransactionInfo_description")(this.#txInfoPtr);
    return await readCString(description) || "";
  }

  async subaddrIndex(): Promise<string> {
    const subaddrIndex = await getSymbol("TransactionInfo_subaddrIndex")(this.#txInfoPtr);
    return await readCString(subaddrIndex) || "";
  }

  async subaddrAccount(): Promise<number> {
    return await getSymbol("TransactionInfo_subaddrAccount")(this.#txInfoPtr);
  }

  async label(): Promise<string> {
    const label = await getSymbol("TransactionInfo_label")(this.#txInfoPtr);
    return await readCString(label) || "";
  }

  async confirmations(): Promise<bigint> {
    return await getSymbol("TransactionInfo_confirmations")(this.#txInfoPtr);
  }

  async unlockTime(): Promise<bigint> {
    return await getSymbol("TransactionInfo_unlockTime")(this.#txInfoPtr);
  }

  async hash(): Promise<string> {
    const hash = await getSymbol("TransactionInfo_hash")(this.#txInfoPtr);
    return await readCString(hash) || "";
  }

  async timestamp(): Promise<bigint> {
    return await getSymbol("TransactionInfo_timestamp")(this.#txInfoPtr);
  }

  async paymentId(): Promise<string> {
    const paymentId = await getSymbol("TransactionInfo_paymentId")(this.#txInfoPtr);
    return await readCString(paymentId) || "";
  }

  async transfersCount(): Promise<number> {
    return await getSymbol("TransactionInfo_transfers_count")(this.#txInfoPtr);
  }

  async transfersAmount(index: number): Promise<bigint> {
    return await getSymbol("TransactionInfo_transfers_amount")(this.#txInfoPtr, index);
  }

  async transfersAddress(index: number): Promise<string> {
    const transfersAddress = await getSymbol("TransactionInfo_transfers_address")(this.#txInfoPtr, index);
    return await readCString(transfersAddress) || "";
  }
}
