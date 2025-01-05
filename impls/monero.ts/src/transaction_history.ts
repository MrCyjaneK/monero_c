import { fns } from "./bindings.ts";
import { TransactionInfo, TransactionInfoPtr } from "./transaction_info.ts";
import { CString } from "./utils.ts";

export type TransactionHistoryPtr = Deno.PointerObject<"transactionHistory">;

export class TransactionHistory {
  #ptr: TransactionHistoryPtr;

  #count!: number;

  constructor(ptr: TransactionHistoryPtr) {
    this.#ptr = ptr;
  }

  static async new(ptr: TransactionHistoryPtr) {
    const instance = new TransactionHistory(ptr);
    instance.#count = await fns.TransactionHistory_count(ptr);
    return instance;
  }

  get count(): number {
    return this.#count;
  }

  async transaction(index: number): Promise<TransactionInfo> {
    return TransactionInfo.new(
      await fns.TransactionHistory_transaction(this.#ptr, index) as TransactionInfoPtr,
    );
  }

  async refresh(): Promise<void> {
    await fns.TransactionHistory_refresh(this.#ptr);
  }

  async setTxNote(transactionId: string, note: string): Promise<void> {
    await fns.TransactionHistory_setTxNote(
      this.#ptr,
      CString(transactionId),
      CString(note),
    );
  }
}
