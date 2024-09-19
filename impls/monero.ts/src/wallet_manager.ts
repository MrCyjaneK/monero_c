import { dylib } from "./bindings.ts";
import { Sanitizer } from "./utils.ts";

export type WalletManagerPtr = Deno.PointerObject<"walletManager">;

export class WalletManager {
  #ptr: WalletManagerPtr;
  sanitizer?: Sanitizer;

  constructor(walletManagerPtr: WalletManagerPtr, sanitizer?: Sanitizer) {
    this.#ptr = walletManagerPtr;
    this.sanitizer = sanitizer;
  }

  getPointer(): WalletManagerPtr {
    return this.#ptr;
  }

  static async new(sanitizer?: Sanitizer) {
    const ptr = await dylib.symbols.MONERO_WalletManagerFactory_getWalletManager();
    if (!ptr) {
      sanitizer?.();
      throw new Error("Failed retrieving wallet manager");
    }
    return new WalletManager(ptr as WalletManagerPtr, sanitizer);
  }
}
