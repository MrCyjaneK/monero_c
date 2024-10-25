import { dylib } from "./bindings.ts";
import { CString, getSymbol, readCString, Sanitizer } from "./utils.ts";

import { WalletManager, type WalletManagerPtr } from "./wallet_manager.ts";
import { TransactionHistory, TransactionHistoryPtr } from "./transaction_history.ts";
import { PendingTransaction } from "./pending_transaction.ts";
import { PendingTransactionPtr } from "./pending_transaction.ts";
import { Coins, type CoinsPtr } from "./coins.ts";

export type WalletPtr = Deno.PointerObject<"walletManager">;

export class Wallet {
  #walletManagerPtr: WalletManagerPtr;
  #walletPtr: WalletPtr;
  sanitizer?: Sanitizer;

  constructor(walletManagerPtr: WalletManager, walletPtr: WalletPtr, sanitizer?: Sanitizer) {
    this.#walletPtr = walletPtr;
    this.#walletManagerPtr = walletManagerPtr.getPointer();
    this.sanitizer = sanitizer;
  }

  getPointer(): WalletPtr {
    return this.#walletPtr;
  }

  async store(path = ""): Promise<boolean> {
    const bool = await getSymbol("Wallet_store")(this.#walletPtr, CString(path));
    await this.throwIfError();
    return bool;
  }

  async initWallet(daemonAddress: string): Promise<void> {
    await this.init(daemonAddress);
    // await this.init3(); - enable logging to console
    await this.setTrustedDaemon(true);
    await this.setDaemonAddress(daemonAddress);
    await this.startRefresh();
    await this.refreshAsync();
    await this.throwIfError();
  }

  async setDaemonAddress(address: string): Promise<void> {
    await getSymbol("WalletManager_setDaemonAddress")(
      this.#walletManagerPtr,
      CString(address),
    );
  }

  async startRefresh(): Promise<void> {
    await getSymbol("Wallet_startRefresh")(this.#walletPtr);
    await this.throwIfError();
  }

  async refreshAsync(): Promise<void> {
    await getSymbol("Wallet_refreshAsync")(this.#walletPtr);
    await this.throwIfError();
  }

  async setupBackgroundSync(
    backgroundSyncType: number,
    walletPassword: string,
    backgroundCachePassword: string,
  ): Promise<boolean> {
    const bool = await getSymbol("Wallet_setupBackgroundSync")(
      this.#walletPtr,
      backgroundSyncType,
      CString(walletPassword),
      CString(backgroundCachePassword),
    );
    await this.throwIfError();
    return bool;
  }

  async startBackgroundSync(): Promise<boolean> {
    const bool = await getSymbol("Wallet_startBackgroundSync")(this.#walletPtr);
    await this.throwIfError();
    return bool;
  }

  async stopBackgroundSync(walletPassword: string): Promise<boolean> {
    const bool = await getSymbol("Wallet_stopBackgroundSync")(this.#walletPtr, CString(walletPassword));
    await this.throwIfError();
    return bool;
  }

  async init(daemonAddress: string): Promise<boolean> {
    const bool = await getSymbol("Wallet_init")(
      this.#walletPtr,
      CString(daemonAddress),
      0n,
      CString(""),
      CString(""),
      false,
      false,
      CString(""),
    );
    await this.throwIfError();
    return bool;
  }

  async init3(): Promise<void> {
      // void* wallet_ptr, const char* argv0, const char* default_log_base_name,
    //  const char* log_path, bool console
    const bool = await getSymbol("Wallet_init3")(
      this.#walletPtr,
      CString(""),
      CString(""),
      CString(""),
      true,
   );
  }

  async setTrustedDaemon(value: boolean): Promise<void> {
    await getSymbol("Wallet_setTrustedDaemon")(this.#walletPtr, value);
  }

  static async create(
    walletManager: WalletManager,
    path: string,
    password: string,
    sanitizeError = true,
  ): Promise<Wallet> {
    const walletManagerPtr = walletManager.getPointer();

    const walletPtr = await getSymbol("WalletManager_createWallet")(
      walletManagerPtr,
      CString(path),
      CString(password),
      CString("English"),
      0,
    );

    const wallet = new Wallet(walletManager, walletPtr as WalletPtr, walletManager.sanitizer);
    await wallet.throwIfError(sanitizeError);

    return wallet;
  }

  static async open(
    walletManager: WalletManager,
    path: string,
    password: string,
    sanitizeError = true,
  ): Promise<Wallet> {
    const walletManagerPtr = walletManager.getPointer();

    const walletPtr = await getSymbol("WalletManager_openWallet")(
      walletManagerPtr,
      CString(path),
      CString(password),
      0,
    );

    const wallet = new Wallet(walletManager, walletPtr as WalletPtr, walletManager.sanitizer);
    await wallet.throwIfError(sanitizeError);

    return wallet;
  }

  static async recover(
    walletManager: WalletManager,
    path: string,
    password: string,
    mnemonic: string,
    restoreHeight: bigint,
    seedOffset: string = "",
    sanitizeError = true,
  ): Promise<Wallet> {
    const walletManagerPtr = walletManager.getPointer();

    const walletPtr = await getSymbol("WalletManager_recoveryWallet")(
      walletManagerPtr,
      CString(path),
      CString(password),
      CString(mnemonic),
      0,
      restoreHeight,
      1n,
      CString(seedOffset),
    );

    const wallet = new Wallet(walletManager, walletPtr as WalletPtr, walletManager.sanitizer);
    await wallet.throwIfError(sanitizeError);

    return wallet;
  }

  static async recoverFromPolyseed(
    walletManager: WalletManager,
    path: string,
    password: string,
    mnemonic: string,
    restoreHeight: bigint,
    passphrase = "",
    sanitizeError = true,
  ): Promise<Wallet> {
    return await this.createFromPolyseed(
      walletManager,
      path,
      password,
      mnemonic,
      restoreHeight,
      passphrase,
      sanitizeError,
      false,
    );
  }

  static async createFromPolyseed(
    walletManager: WalletManager,
    path: string,
    password: string,
    mnemonic: string,
    restoreHeight: bigint,
    passphrase = "",
    sanitizeError = true,
    newWallet = true,
  ): Promise<Wallet> {
    const walletManagerPtr = walletManager.getPointer();

    const walletPtr = await getSymbol("WalletManager_createWalletFromPolyseed")(
      walletManagerPtr,
      CString(path),
      CString(password),
      0,
      CString(mnemonic),
      CString(passphrase),
      newWallet,
      restoreHeight,
      1n,
    );

    const wallet = new Wallet(walletManager, walletPtr as WalletPtr, walletManager.sanitizer);
    await wallet.throwIfError(sanitizeError);

    return wallet;
  }

  async close(store: boolean): Promise<void> {
    await getSymbol("WalletManager_closeWallet")(
      this.#walletManagerPtr,
      this.#walletPtr,
      store,
    );
  }

  async address(accountIndex = 0n, addressIndex = 0n): Promise<string> {
    const address = await getSymbol("Wallet_address")(this.#walletPtr, accountIndex, addressIndex);
    if (!address) {
      const error = await this.errorString();
      throw new Error(`Failed getting address from a wallet: ${error ?? "<Error unknown>"}`);
    }
    return await readCString(address);
  }

  async balance(accountIndex = 0): Promise<bigint> {
    return await getSymbol("Wallet_balance")(this.#walletPtr, accountIndex);
  }

  async unlockedBalance(accountIndex = 0): Promise<bigint> {
    return await getSymbol("Wallet_unlockedBalance")(this.#walletPtr, accountIndex);
  }

  status(): Promise<number> {
    return getSymbol("Wallet_status")(this.#walletPtr);
  }

  async errorString(): Promise<string | null> {
    if (!await this.status()) return null;

    const error = await getSymbol("Wallet_errorString")(this.#walletPtr);
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

  async synchronized(): Promise<boolean> {
    const synchronized = await getSymbol("Wallet_synchronized")(this.#walletPtr);
    await this.throwIfError();
    return synchronized;
  }

  async blockChainHeight(): Promise<bigint> {
    const height = await getSymbol("Wallet_blockChainHeight")(this.#walletPtr);
    await this.throwIfError();
    return height;
  }

  async daemonBlockChainHeight(): Promise<bigint> {
    const height = await getSymbol("Wallet_daemonBlockChainHeight")(this.#walletPtr);
    await this.throwIfError();
    return height;
  }

  async managerBlockChainHeight(): Promise<bigint> {
    const height = await getSymbol("WalletManager_blockchainHeight")(this.#walletManagerPtr);
    await this.throwIfError();
    return height;
  }

  async managerTargetBlockChainHeight(): Promise<bigint> {
    const height = await getSymbol("WalletManager_blockchainTargetHeight")(this.#walletManagerPtr);
    await this.throwIfError();
    return height;
  }

  async addSubaddressAccount(label: string): Promise<void> {
    await getSymbol("Wallet_addSubaddressAccount")(
      this.#walletPtr,
      CString(label),
    );
    await this.throwIfError();
  }

  async numSubaddressAccounts(): Promise<bigint> {
    const accountsLen = await getSymbol("Wallet_numSubaddressAccounts")(this.#walletPtr);
    await this.throwIfError();
    return accountsLen;
  }

  async addSubaddress(accountIndex: number, label: string): Promise<void> {
    await getSymbol("Wallet_addSubaddress")(
      this.#walletPtr,
      accountIndex,
      CString(label),
    );
    await this.throwIfError();
  }

  async numSubaddresses(accountIndex: number): Promise<bigint> {
    const address = await getSymbol("Wallet_numSubaddresses")(
      this.#walletPtr,
      accountIndex,
    );
    await this.throwIfError();
    return address;
  }

  async getSubaddressLabel(accountIndex: number, addressIndex: number): Promise<string> {
    const label = await getSymbol("Wallet_getSubaddressLabel")(this.#walletPtr, accountIndex, addressIndex);
    if (!label) {
      const error = await this.errorString();
      throw new Error(`Failed getting subaddress label from a wallet: ${error ?? "<Error unknown>"}`);
    }
    return await readCString(label);
  }

  async setSubaddressLabel(accountIndex: number, addressIndex: number, label: string): Promise<void> {
    await getSymbol("Wallet_setSubaddressLabel")(
      this.#walletPtr,
      accountIndex,
      addressIndex,
      CString(label),
    );
    await this.throwIfError();
  }

  async getHistory(): Promise<TransactionHistory> {
    const transactionHistoryPointer = await getSymbol("Wallet_history")(this.#walletPtr);
    await this.throwIfError();
    return new TransactionHistory(transactionHistoryPointer as TransactionHistoryPtr);
  }

  async createTransaction(
    destinationAddress: string,
    amount: bigint,
    pendingTransactionPriority = 0 | 1 | 2 | 3,
    subaddressAccount: number,
    sanitize = true,
    prefferedInputs = "",
    mixinCount = 0,
    paymentId = "",
    separator = ",",
  ): Promise<PendingTransaction> {
    const pendingTxPtr = await getSymbol("Wallet_createTransaction")(
      this.#walletPtr,
      CString(destinationAddress),
      CString(paymentId),
      amount,
      mixinCount,
      pendingTransactionPriority,
      subaddressAccount,
      CString(prefferedInputs),
      CString(separator),
    );
    await this.throwIfError(sanitize);
    return new PendingTransaction(pendingTxPtr as PendingTransactionPtr);
  }

  async amountFromString(amount: string): Promise<bigint> {
    return await getSymbol("Wallet_amountFromString")(CString(amount));
  }

  async seed(seedOffset = ""): Promise<string | null> {
    const seed = await readCString(await getSymbol("Wallet_seed")(this.#walletPtr, CString(seedOffset)));
    await this.throwIfError();
    return seed;
  }

  async isOffline(): Promise<boolean> {
    return await getSymbol("Wallet_isOffline")(this.#walletPtr);
  }

  async setOffline(offline: boolean): Promise<void> {
    await getSymbol("Wallet_setOffline")(this.#walletPtr, offline);
  }

  async coins(): Promise<Coins | null> {
    const coinsPtr = await getSymbol("Wallet_coins")(this.#walletPtr);
    if (!coinsPtr) return null;

    return new Coins(coinsPtr as CoinsPtr, this.sanitizer);
  }
}
