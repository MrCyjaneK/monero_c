import { CString, getSymbol, readCString, type Sanitizer } from "./utils.ts";

export type UnsignedTransactionPtr = Deno.PointerObject<"unsignedTransaction">;

export class UnsignedTransaction {
  #unsignedTxPtr: UnsignedTransactionPtr;
  sanitizer?: Sanitizer;

  constructor(pendingTxPtr: UnsignedTransactionPtr, sanitizer?: Sanitizer) {
    this.sanitizer = sanitizer;
    this.#unsignedTxPtr = pendingTxPtr;
  }

  async status(): Promise<number> {
    return await getSymbol("UnsignedTransaction_status")(this.#unsignedTxPtr);
  }

  async errorString(): Promise<string | null> {
    if (!await this.status()) return null;

    const error = await getSymbol("UnsignedTransaction_errorString")(this.#unsignedTxPtr);
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

  async amount(separator = ","): Promise<string | null> {
    return readCString(await getSymbol("UnsignedTransaction_amount")(this.#unsignedTxPtr, CString(separator)));
  }

  async fee(separator = ","): Promise<string | null> {
    return readCString(await getSymbol("UnsignedTransaction_fee")(this.#unsignedTxPtr, CString(separator)));
  }

  async txCount(): Promise<bigint> {
    return await getSymbol("UnsignedTransaction_txCount")(this.#unsignedTxPtr);
  }

  async recipientAddress(separator = ","): Promise<string | null> {
    const result = await getSymbol("UnsignedTransaction_recipientAddress")(
      this.#unsignedTxPtr,
      CString(separator),
    );
    await this.throwIfError();
    return await readCString(result);
  }

  async sign(signedFileName: string): Promise<boolean> {
    return await getSymbol("UnsignedTransaction_sign")(
      this.#unsignedTxPtr,
      CString(signedFileName),
    );
  }

  async signUR(maxFragmentLength: number): Promise<string | null> {
    const output = await getSymbol("UnsignedTransaction_signUR")(
      this.#unsignedTxPtr,
      maxFragmentLength,
    );
    await this.throwIfError();
    return await readCString(output);
  }
}
