import { fns } from "./bindings.ts";
import { CString } from "./utils.ts";
import { Wallet, WalletPtr } from "./wallet.ts";

export type WalletManagerPtr = Deno.PointerObject<"walletManager">;

export class WalletManager {
  #ptr: WalletManagerPtr;

  constructor(walletManagerPtr: WalletManagerPtr) {
    this.#ptr = walletManagerPtr;
  }

  getPointer(): WalletManagerPtr {
    return this.#ptr;
  }

  static async new() {
    const ptr = await fns.WalletManagerFactory_getWalletManager();
    if (!ptr) {
      throw new Error("Failed retrieving wallet manager");
    }

    return new WalletManager(ptr as WalletManagerPtr);
  }

  async setDaemonAddress(address: string): Promise<void> {
    return await fns.WalletManager_setDaemonAddress(this.#ptr, CString(address));
  }

  async createWallet(path: string, password: string): Promise<Wallet> {
    const walletPtr = await fns.WalletManager_createWallet(
      this.#ptr,
      CString(path),
      CString(password),
      CString("English"),
      0,
    );

    const wallet = new Wallet(this, walletPtr as WalletPtr);
    await wallet.throwIfError();
    return wallet;
  }

  async openWallet(path: string, password: string): Promise<Wallet> {
    const walletPtr = await fns.WalletManager_openWallet(
      this.#ptr,
      CString(path),
      CString(password),
      0,
    );

    const wallet = new Wallet(this, walletPtr as WalletPtr);
    await wallet.throwIfError();
    return wallet;
  }

  async recoverWallet(
    path: string,
    password: string,
    mnemonic: string,
    restoreHeight: bigint,
    seedOffset: string = "",
  ): Promise<Wallet> {
    const walletPtr = await fns.WalletManager_recoveryWallet(
      this.#ptr,
      CString(path),
      CString(password),
      CString(mnemonic),
      0,
      restoreHeight,
      1n,
      CString(seedOffset),
    );

    const wallet = new Wallet(this, walletPtr as WalletPtr);
    await wallet.throwIfError();
    return wallet;
  }

  async recoverFromPolyseed(
    path: string,
    password: string,
    mnemonic: string,
    restoreHeight: bigint,
    passphrase = "",
  ): Promise<Wallet> {
    return await this.createFromPolyseed(
      path,
      password,
      mnemonic,
      restoreHeight,
      passphrase,
      false,
    );
  }

  async createFromPolyseed(
    path: string,
    password: string,
    mnemonic: string,
    restoreHeight: bigint,
    passphrase = "",
    newWallet = true,
  ): Promise<Wallet> {
    const walletPtr = await fns.WalletManager_createWalletFromPolyseed(
      this.#ptr,
      CString(path),
      CString(password),
      0,
      CString(mnemonic),
      CString(passphrase),
      newWallet,
      restoreHeight,
      1n,
    );

    const wallet = new Wallet(this, walletPtr as WalletPtr);
    await wallet.throwIfError();
    return wallet;
  }

  async recoverFromKeys(
    path: string,
    password: string,
    restoreHeight: bigint,
    address: string,
    viewKey: string,
    spendKey: string,
  ): Promise<Wallet> {
    const walletPtr = await fns.WalletManager_createWalletFromKeys(
      this.#ptr,
      CString(path),
      CString(password),
      CString("English"),
      0,
      restoreHeight,
      CString(address),
      CString(viewKey),
      CString(spendKey),
      0n,
    );

    const wallet = new Wallet(this, walletPtr as WalletPtr);
    await wallet.throwIfError();
    return wallet;
  }
}
