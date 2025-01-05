import { fns } from "./bindings.ts";
import { C_SEPARATOR, CString, maybeMultipleStrings, readCString } from "./utils.ts";

export type PendingTransactionPtr = Deno.PointerObject<"pendingTransaction">;

export class PendingTransaction<MultDest extends boolean = false> {
  #ptr: PendingTransactionPtr;

  #amount!: bigint;
  #dust!: bigint;
  #fee!: bigint;
  #txid!: string | string[] | null;
  #txCount!: bigint;

  constructor(ptr: PendingTransactionPtr) {
    this.#ptr = ptr;
  }

  static async new(ptr: PendingTransactionPtr): Promise<PendingTransaction> {
    const instance = new PendingTransaction(ptr);

    const [amount, dust, fee, txCount, txid] = await Promise.all([
      fns.PendingTransaction_amount(ptr),
      fns.PendingTransaction_dust(ptr),
      fns.PendingTransaction_fee(ptr),
      fns.PendingTransaction_txCount(ptr),
      fns.PendingTransaction_txid(ptr, C_SEPARATOR),
    ]);

    instance.#amount = amount;
    instance.#dust = dust;
    instance.#fee = fee;
    instance.#txCount = txCount;
    instance.#txid = maybeMultipleStrings(await readCString(txid));

    return instance;
  }

  get amount(): bigint {
    return this.#amount;
  }

  get dust(): bigint {
    return this.#dust;
  }

  get fee(): bigint {
    return this.#fee;
  }

  get txCount(): bigint {
    return this.#txCount;
  }

  async commit(fileName: string, overwrite: boolean): Promise<boolean> {
    return await fns.PendingTransaction_commit(this.#ptr, CString(fileName), overwrite);
  }

  async commitUR(maxFragmentLength: number): Promise<string | null> {
    const commitUR = fns.PendingTransaction_commitUR;
    if (!commitUR) return null;

    return await readCString(
      await commitUR(this.#ptr, maxFragmentLength),
    );
  }

  async status(): Promise<number> {
    return await fns.PendingTransaction_status(this.#ptr);
  }

  async errorString(): Promise<string | null> {
    if (!await this.status()) return null;
    const error = await fns.PendingTransaction_errorString(this.#ptr);
    return await readCString(error);
  }

  async throwIfError(): Promise<void> {
    const maybeError = await this.errorString();
    if (maybeError) {
      throw new Error(maybeError);
    }
  }
}
