import { dylib } from "./bindings.ts";
import { CString, readCString, Sanitizer } from "./utils.ts";
import { WalletManager, type WalletManagerPtr } from "./wallet_manager.ts";
import { TransactionHistory, TransactionHistoryPtr } from "./transaction_history.ts";

import { PendingTransaction } from "./pending_transaction.ts";
import { PendingTransactionPtr } from "./pending_transaction.ts";

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

  async store(path = ""): Promise<boolean> {
    const bool = await dylib.symbols.MONERO_Wallet_store(this.#walletPtr, CString(path));
    await this.throwIfError();
    return bool;
  }

  async initWallet(): Promise<void> {
    await this.init();
    await this.setTrustedDaemon(true);
    await this.setDaemonAddress("http://nodex.monerujo.io:18081");
    await this.startRefresh();
    await this.refreshAsync();
    await this.throwIfError();
  }

  async setDaemonAddress(address: string): Promise<void> {
    await dylib.symbols.MONERO_WalletManager_setDaemonAddress(
      this.#walletManagerPtr,
      CString(address),
    );
  }

  async startRefresh(): Promise<void> {
    await dylib.symbols.MONERO_Wallet_startRefresh(this.#walletPtr);
    await this.throwIfError();
  }

  async refreshAsync(): Promise<void> {
    await dylib.symbols.MONERO_Wallet_refreshAsync(this.#walletPtr);
    await this.throwIfError();
  }

  async init(): Promise<boolean> {
    const bool = await dylib.symbols.MONERO_Wallet_init(
      this.#walletPtr,
      CString("http://nodex.monerujo.io:18081"),
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

  async setTrustedDaemon(value: boolean): Promise<void> {
    await dylib.symbols.MONERO_Wallet_setTrustedDaemon(this.#walletPtr, value);
  }

  static async create(
    walletManager: WalletManager,
    path: string,
    password: string,
    sanitizeError = true,
  ): Promise<Wallet> {
    // We assign holder of the pointer in Wallet constructor
    const walletManagerPtr = walletManager.getPointer();

    const walletPtr = await dylib.symbols.MONERO_WalletManager_createWallet(
      walletManagerPtr,
      CString(path),
      CString(password),
      CString("English"),
      0,
    );

    const wallet = new Wallet(walletManager, walletPtr as WalletPtr, walletManager.sanitizer);
    await wallet.throwIfError(sanitizeError);
    await wallet.initWallet();

    return wallet;
  }

  static async open(
    walletManager: WalletManager,
    path: string,
    password: string,
    sanitizeError = true,
  ): Promise<Wallet> {
    // We assign holder of the pointer in Wallet constructor
    const walletManagerPtr = walletManager.getPointer();

    const walletPtr = await dylib.symbols.MONERO_WalletManager_openWallet(
      walletManagerPtr,
      CString(path),
      CString(password),
      0,
    );

    const wallet = new Wallet(walletManager, walletPtr as WalletPtr, walletManager.sanitizer);
    await wallet.throwIfError(sanitizeError);
    await wallet.initWallet();

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

    const wallet = new Wallet(walletManager, walletPtr as WalletPtr, walletManager.sanitizer);
    await wallet.throwIfError(sanitizeError);
    await wallet.initWallet();

    return wallet;
  }

  async address(accountIndex = 0n, addressIndex = 0n): Promise<string> {
    const address = await dylib.symbols.MONERO_Wallet_address(this.#walletPtr, accountIndex, addressIndex);
    if (!address) {
      const error = await this.errorString();
      throw new Error(`Failed getting address from a wallet: ${error ?? "<Error unknown>"}`);
    }
    return await readCString(address);
  }

  async balance(accountIndex = 0): Promise<bigint> {
    return await dylib.symbols.MONERO_Wallet_balance(this.#walletPtr, accountIndex);
  }

  async unlockedBalance(accountIndex = 0): Promise<bigint> {
    return await dylib.symbols.MONERO_Wallet_unlockedBalance(this.#walletPtr, accountIndex);
  }

  status(): Promise<number> {
    return dylib.symbols.MONERO_Wallet_status(this.#walletPtr);
  }

  async errorString(): Promise<string | null> {
    if (!await this.status()) return null;

    const error = await dylib.symbols.MONERO_Wallet_errorString(this.#walletPtr);
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
    const synchronized = await dylib.symbols.MONERO_Wallet_synchronized(this.#walletPtr);
    await this.throwIfError();
    return synchronized;
  }

  async blockChainHeight(): Promise<bigint> {
    const height = await dylib.symbols.MONERO_Wallet_blockChainHeight(this.#walletPtr);
    await this.throwIfError();
    return height;
  }

  async daemonBlockChainHeight(): Promise<bigint> {
    const height = await dylib.symbols.MONERO_Wallet_daemonBlockChainHeight(this.#walletPtr);
    await this.throwIfError();
    return height;
  }

  async managerBlockChainHeight(): Promise<bigint> {
    const height = await dylib.symbols.MONERO_WalletManager_blockchainHeight(this.#walletManagerPtr);
    await this.throwIfError();
    return height;
  }

  async managerTargetBlockChainHeight(): Promise<bigint> {
    const height = await dylib.symbols.MONERO_WalletManager_blockchainTargetHeight(this.#walletManagerPtr);
    await this.throwIfError();
    return height;
  }

  async addSubaddressAccount(label: string): Promise<void> {
    await dylib.symbols.MONERO_Wallet_addSubaddressAccount(
      this.#walletPtr,
      CString(label),
    );
    await this.throwIfError();
  }

  async numSubaddressAccounts(): Promise<bigint> {
    const accountsLen = await dylib.symbols.MONERO_Wallet_numSubaddressAccounts(this.#walletPtr);
    await this.throwIfError();
    return accountsLen;
  }

  async addSubaddress(accountIndex: number, label: string): Promise<void> {
    await dylib.symbols.MONERO_Wallet_addSubaddress(
      this.#walletPtr,
      accountIndex,
      CString(label),
    );
    await this.throwIfError();
  }

  async numSubaddresses(accountIndex: number): Promise<bigint> {
    const address = await dylib.symbols.MONERO_Wallet_numSubaddresses(
      this.#walletPtr,
      accountIndex,
    );
    await this.throwIfError();
    return address;
  }

  async getSubaddressLabel(accountIndex: number, addressIndex: number): Promise<string> {
    const label = await dylib.symbols.MONERO_Wallet_getSubaddressLabel(this.#walletPtr, accountIndex, addressIndex);
    if (!label) {
      const error = await this.errorString();
      throw new Error(`Failed getting subaddress label from a wallet: ${error ?? "<Error unknown>"}`);
    }
    return await readCString(label);
  }

  async setSubaddressLabel(accountIndex: number, addressIndex: number, label: string): Promise<void> {
    await dylib.symbols.MONERO_Wallet_setSubaddressLabel(
      this.#walletPtr,
      accountIndex,
      addressIndex,
      CString(label),
    );
    await this.throwIfError();
  }

  async getHistory(): Promise<TransactionHistory> {
    const transactionHistoryPointer = await dylib.symbols.MONERO_Wallet_history(this.#walletPtr);
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
    const pendingTxPtr = await dylib.symbols.MONERO_Wallet_createTransaction(
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
    return await dylib.symbols.MONERO_Wallet_amountFromString(CString(amount));
  }
}
