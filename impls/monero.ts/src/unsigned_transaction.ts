import { fns } from "./bindings.ts";
import { C_SEPARATOR, CString, maybeMultipleStrings, readCString } from "./utils.ts";

export type UnsignedTransactionPtr = Deno.PointerObject<"pendingTransaction">;

export class UnsignedTransaction<MultDest extends boolean = false> {
  #ptr: UnsignedTransactionPtr;

  #amount!: string | string[] | null;
  #fee!: string | string[] | null;
  #txCount!: bigint;
  #paymentId!: string | null;
  #recipientAddress!: string | string[] | null;

  constructor(ptr: UnsignedTransactionPtr) {
    this.#ptr = ptr;
  }

  async status(): Promise<number> {
    return await fns.UnsignedTransaction_status(this.#ptr);
  }

  async errorString(): Promise<string | null> {
    return await readCString(await fns.UnsignedTransaction_errorString(this.#ptr));
  }

  static async new(ptr: UnsignedTransactionPtr): Promise<UnsignedTransaction> {
    const instance = new UnsignedTransaction(ptr);

    const [amount, paymentId, fee, txCount, recipientAddress] = await Promise.all([
      fns.UnsignedTransaction_amount(ptr, C_SEPARATOR).then(readCString),
      fns.UnsignedTransaction_paymentId(ptr, C_SEPARATOR).then(readCString),
      fns.UnsignedTransaction_fee(ptr, C_SEPARATOR).then(readCString),
      fns.UnsignedTransaction_txCount(ptr),
      fns.UnsignedTransaction_recipientAddress(ptr, C_SEPARATOR).then(readCString),
    ]);

    instance.#amount = maybeMultipleStrings(amount);
    instance.#fee = maybeMultipleStrings(fee);
    instance.#recipientAddress = maybeMultipleStrings(recipientAddress);
    instance.#txCount = txCount;
    instance.#paymentId = paymentId;

    return instance;
  }

  get amount(): string | string[] | null {
    return this.#amount;
  }

  get fee(): string | string[] | null {
    return this.#fee;
  }

  get txCount(): bigint {
    return this.#txCount;
  }

  get paymentId(): string | null {
    return this.#paymentId;
  }

  get recipientAddress(): string | string[] | null {
    return this.#recipientAddress;
  }

  async sign(signedFileName: string): Promise<boolean> {
    return await fns.UnsignedTransaction_sign(this.#ptr, CString(signedFileName));
  }

  async signUR(maxFragmentLength: number): Promise<string | null> {
    const signUR = fns.UnsignedTransaction_signUR;
    if (!signUR) return null;

    return await readCString(
      await signUR(this.#ptr, maxFragmentLength),
    );
  }
}
