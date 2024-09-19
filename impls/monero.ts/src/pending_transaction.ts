import { dylib } from "./bindings.ts";
import { CString, readCString, type Sanitizer } from "./utils.ts";

export type PendingTransactionPtr = Deno.PointerObject<"transactionInfo">;

export class PendingTransaction {
  #pendingTxPtr: PendingTransactionPtr;
  sanitizer?: Sanitizer;

  constructor(pendingTxPtr: PendingTransactionPtr, sanitizer?: Sanitizer) {
    this.sanitizer = sanitizer;
    this.#pendingTxPtr = pendingTxPtr;
  }

  async status(): Promise<number> {
    return await dylib.symbols.MONERO_PendingTransaction_status(this.#pendingTxPtr);
  }

  async errorString(): Promise<string | null> {
    if (!await this.status()) return null;

    const error = await dylib.symbols.MONERO_PendingTransaction_errorString(this.#pendingTxPtr);
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
    const bool = await dylib.symbols.MONERO_PendingTransaction_commit(
      this.#pendingTxPtr,
      CString(fileName),
      overwrite,
    );
    await this.throwIfError(sanitize);
    return bool;
  }

  async commitUR(maxFragmentLength: number): Promise<string | null> {
    const result = await dylib.symbols.MONERO_PendingTransaction_commitUR(
      this.#pendingTxPtr,
      maxFragmentLength,
    );
    if (!result) return null;
    await this.throwIfError();
    return await readCString(result) || null;
  }

  async amount(): Promise<bigint> {
    return await dylib.symbols.MONERO_PendingTransaction_amount(this.#pendingTxPtr);
  }

  async dust(): Promise<bigint> {
    return await dylib.symbols.MONERO_PendingTransaction_dust(this.#pendingTxPtr);
  }

  async fee(): Promise<bigint> {
    return await dylib.symbols.MONERO_PendingTransaction_fee(this.#pendingTxPtr);
  }

  async txid(separator: string, sanitize = true): Promise<string | null> {
    const result = await dylib.symbols.MONERO_PendingTransaction_txid(
      this.#pendingTxPtr,
      CString(separator),
    );
    if (!result) return null;
    await this.throwIfError(sanitize);
    return await readCString(result) || null;
  }

  async txCount(): Promise<bigint> {
    return await dylib.symbols.MONERO_PendingTransaction_txCount(this.#pendingTxPtr);
  }
}
