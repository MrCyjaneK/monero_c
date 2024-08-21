import { dylib } from "./monero_bindings.ts";
import { CString } from "./utils.ts";
import { WalletManager, type WalletManagerPtr } from "./wallet_manager.ts";

export type WalletPtr = Deno.PointerObject<"walletManager">;

export class Wallet {
    #walletManagerPtr: WalletManagerPtr;
    #walletPtr: WalletPtr;

    constructor(walletManagerPtr: WalletManager, walletPtr: WalletPtr) {
        this.#walletPtr = walletPtr;
        this.#walletManagerPtr = walletManagerPtr.getPointer(this);
    }

    async address(accountIndex = 0n, addressIndex = 0n): Promise<string> {
        const address = await dylib.symbols.MONERO_Wallet_address(this.#walletPtr, accountIndex, addressIndex);
        if (!address) {
            const error = await this.error();
            throw new Error(`Failed getting address from a wallet: ${error ?? "<Error unknown>"}`);
        }
        return new Deno.UnsafePointerView(address).getCString();
    }

    async balance(accountIndex = 0): Promise<bigint> {
        return await dylib.symbols.MONERO_Wallet_balance(this.#walletPtr, accountIndex);
    }

    static async create(walletManager: WalletManager, path: string, password: string): Promise<Wallet> {
        // We assign holder of the pointer in Wallet constructor
        const walletManagerPtr = walletManager.getPointer();

        const walletPtr = await dylib.symbols.MONERO_WalletManager_createWallet(
            walletManagerPtr,
            CString(path),
            CString(password),
            CString("English"),
            0,
        );

        const wallet = new Wallet(walletManager, walletPtr as WalletPtr);

        const maybeError = await wallet.error();
        if (maybeError) throw new Error(maybeError);

        return wallet;
    }

    static async open(walletManager: WalletManager, path: string, password: string): Promise<Wallet> {
        // We assign holder of the pointer in Wallet constructor
        const walletManagerPtr = walletManager.getPointer();

        const walletPtr = await dylib.symbols.MONERO_WalletManager_openWallet(
            walletManagerPtr,
            CString(path),
            CString(password),
            0,
        );

        const wallet = new Wallet(walletManager, walletPtr as WalletPtr);

        const maybeError = await wallet.error();
        if (maybeError) throw new Error(maybeError);

        return wallet;
    }

    static async recover(
        walletManager: WalletManager,
        path: string,
        password: string,
        mnemonic: string,
        restoreHeight: bigint = 0n,
        seedOffset: string = "",
    ): Promise<Wallet> {
        // We assign holder of the pointer in Wallet constructor
        const walletManagerPtr = walletManager.getPointer();

        const walletPtr = await dylib.symbols.MONERO_WalletManager_recoveryWallet(
            walletManagerPtr,
            CString(path),
            CString(password),
            CString(mnemonic),
            0,
            restoreHeight,
            1n,
            CString(seedOffset),
        );

        const wallet = new Wallet(walletManager, walletPtr as WalletPtr);

        const maybeError = await wallet.error();
        if (maybeError) throw new Error(maybeError);

        return wallet;
    }

    status(): Promise<number> {
        return dylib.symbols.MONERO_Wallet_status(this.#walletPtr);
    }

    async error(): Promise<string | null> {
        if (!await this.status()) return null;

        const error = await dylib.symbols.MONERO_Wallet_errorString(this.#walletPtr);
        if (!error) return null;

        const errorString = new Deno.UnsafePointerView(error).getCString();
        return errorString || null;
    }
}
