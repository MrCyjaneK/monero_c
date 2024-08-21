import { dylib } from "./monero_bindings.ts";

export type WalletManagerPtr = Deno.PointerObject<"walletManager">;

export class WalletManager {
    #ptr: WalletManagerPtr;
    // Stores data about who uses the pointer
    #pointerUsers: WeakSet<object>;

    constructor(walletManagerPtr: WalletManagerPtr) {
        this.#ptr = walletManagerPtr;
        this.#pointerUsers = new WeakSet();
    }

    getPointer(holder?: object) {
        if (holder) this.#pointerUsers.add(holder);
        return this.#ptr;
    }

    static async new() {
        const ptr = await dylib.symbols.MONERO_WalletManagerFactory_getWalletManager();
        if (!ptr) throw new Error("Failed retrieving wallet manager");
        return new WalletManager(ptr as WalletManagerPtr);
    }
}
