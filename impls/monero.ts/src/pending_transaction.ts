import { CString, getSymbol, readCString, type Sanitizer } from "./utils.ts";

export type PendingTransactionPtr = Deno.PointerObject<"pendingTransaction">;

export class PendingTransaction {
  #pendingTxPtr: PendingTransactionPtr;
  sanitizer?: Sanitizer;

  constructor(pendingTxPtr: PendingTransactionPtr, sanitizer?: Sanitizer) {
    this.sanitizer = sanitizer;
    this.#pendingTxPtr = pendingTxPtr;
  }

  async status(): Promise<number> {
    return await getSymbol("PendingTransaction_status")(this.#pendingTxPtr);
  }

  async errorString(): Promise<string | null> {
    if (!await this.status()) return null;

    const error = await getSymbol("PendingTransaction_errorString")(this.#pendingTxPtr);
    if (!error) return null;

    return await readCString(error) || null;
  }

  async throwIfError(sanitize = true): Promise<void> {
    const maybeError = await this.errorString();
    if (maybeError) {
      if (sanitize) this.sanitizer?.();
      throw new Error(maybeError);
    }
  }

  async commit(fileName: string, overwrite: boolean, sanitize = true): Promise<boolean> {
    const bool = await getSymbol("PendingTransaction_commit")(
      this.#pendingTxPtr,
      CString(fileName),
      overwrite,
    );
    await this.throwIfError(sanitize);
    return bool;
  }

  async commitUR(maxFragmentLength: number): Promise<string | null> {
    const commitUR = getSymbol("PendingTransaction_commitUR");
    if (!commitUR) return null;

    const result = await commitUR(this.#pendingTxPtr, maxFragmentLength);

    return await readCString(result);
  }

  async amount(): Promise<bigint> {
    return await getSymbol("PendingTransaction_amount")(this.#pendingTxPtr);
  }

  async dust(): Promise<bigint> {
    return await getSymbol("PendingTransaction_dust")(this.#pendingTxPtr);
  }

  async fee(): Promise<bigint> {
    return await getSymbol("PendingTransaction_fee")(this.#pendingTxPtr);
  }

  async txid(separator: string, sanitize = true): Promise<string | null> {
    const result = await getSymbol("PendingTransaction_txid")(
      this.#pendingTxPtr,
      CString(separator),
    );
    if (!result) return null;
    await this.throwIfError(sanitize);
    return await readCString(result) || null;
  }

  async txCount(): Promise<bigint> {
    return await getSymbol("PendingTransaction_txCount")(this.#pendingTxPtr);
  }
}
