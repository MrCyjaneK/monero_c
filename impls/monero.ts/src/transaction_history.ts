import { TransactionInfo, TransactionInfoPtr } from "./transaction_info.ts";
import { CString, getSymbol } from "./utils.ts";

export type TransactionHistoryPtr = Deno.PointerObject<"transactionHistory">;

export class TransactionHistory {
  #txHistoryPtr: TransactionHistoryPtr;

  constructor(txHistoryPtr: TransactionHistoryPtr) {
    this.#txHistoryPtr = txHistoryPtr;
  }

  async count(): Promise<number> {
    return await getSymbol("TransactionHistory_count")(this.#txHistoryPtr);
  }

  async transaction(index: number): Promise<TransactionInfo> {
    return new TransactionInfo(
      (
        await getSymbol("TransactionHistory_transaction")(this.#txHistoryPtr, index)
      ) as TransactionInfoPtr,
    );
  }

  async refresh(): Promise<void> {
    await getSymbol("TransactionHistory_refresh")(this.#txHistoryPtr);
  }

  async setTxNote(transactionId: string, note: string): Promise<void> {
    await getSymbol("TransactionHistory_setTxNote")(
      this.#txHistoryPtr,
      CString(transactionId),
      CString(note),
    );
  }
}
