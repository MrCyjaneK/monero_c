import { WalletManager } from "./wallet_manager.ts";

import { C_SEPARATOR, CString, readCString, SEPARATOR } from "./utils.ts";
import { PendingTransaction, PendingTransactionPtr } from "./pending_transaction.ts";
import { UnsignedTransaction, UnsignedTransactionPtr } from "./unsigned_transaction.ts";
import { Coins, CoinsPtr } from "./coins.ts";
import { fns } from "./bindings.ts";

export type WalletPtr = Deno.PointerObject<"walletManager">;

interface DaemonInfo {
  address?: string;
  username?: string;
  password?: string;
  lightWallet?: boolean;
  proxyAddress?: string;
}

export class Wallet {
  #walletManager: WalletManager;
  #ptr: WalletPtr;

  constructor(walletManager: WalletManager, ptr: WalletPtr) {
    this.#walletManager = walletManager;
    this.#ptr = ptr;
  }

  getPointer() {
    return this.#ptr;
  }

  async init(daemonInfo: DaemonInfo, log = false): Promise<boolean> {
    const success = await fns.Wallet_init(
      this.#ptr,
      CString(daemonInfo.address ?? ""),
      0n,
      CString(daemonInfo.username ?? ""),
      CString(daemonInfo.password ?? ""),
      false,
      daemonInfo.lightWallet ?? false,
      CString(daemonInfo.proxyAddress ?? ""),
    );

    if (log) {
      await fns.Wallet_init3(
        this.#ptr,
        CString(""),
        CString(""),
        CString(""),
        true,
      );
    }

    await this.setTrustedDaemon(true);
    await this.startRefresh();
    await this.refreshAsync();

    return success;
  }

  async setTrustedDaemon(value: boolean): Promise<void> {
    return await fns.Wallet_setTrustedDaemon(this.#ptr, value);
  }

  async startRefresh(): Promise<void> {
    return await fns.Wallet_startRefresh(this.#ptr);
  }

  async refreshAsync(): Promise<void> {
    return await fns.Wallet_refreshAsync(this.#ptr);
  }

  async setupBackgroundSync(
    backgroundSyncType: number,
    walletPassword: string,
    backgroundCachePassword: string,
  ): Promise<boolean> {
    return await fns.Wallet_setupBackgroundSync(
      this.#ptr,
      backgroundSyncType,
      CString(walletPassword),
      CString(backgroundCachePassword),
    );
  }

  async startBackgroundSync(): Promise<boolean> {
    return await fns.Wallet_startBackgroundSync(this.#ptr);
  }

  async stopBackgroundSync(walletPassword: string): Promise<boolean> {
    return await fns.Wallet_stopBackgroundSync(this.#ptr, CString(walletPassword));
  }

  async store(path = ""): Promise<boolean> {
    return await fns.Wallet_store(this.#ptr, CString(path));
  }

  async close(store: boolean): Promise<boolean> {
    return await fns.WalletManager_closeWallet(this.#walletManager.getPointer(), this.#ptr, store);
  }

  async seed(offset = ""): Promise<string | null> {
    return await readCString(
      await fns.Wallet_seed(this.#ptr, CString(offset)),
    );
  }

  async address(accountIndex = 0n, addressIndex = 0n): Promise<string | null> {
    return await readCString(
      await fns.Wallet_address(this.#ptr, accountIndex, addressIndex),
    );
  }

  async balance(accountIndex = 0): Promise<bigint> {
    return await fns.Wallet_balance(this.#ptr, accountIndex);
  }

  async unlockedBalance(accountIndex = 0): Promise<bigint> {
    return await fns.Wallet_unlockedBalance(this.#ptr, accountIndex);
  }

  async synchronized(): Promise<boolean> {
    return await fns.Wallet_synchronized(this.#ptr);
  }

  async blockChainHeight(): Promise<bigint> {
    return await fns.Wallet_blockChainHeight(this.#ptr);
  }

  async daemonBlockChainHeight(): Promise<bigint> {
    return await fns.Wallet_daemonBlockChainHeight(this.#ptr);
  }

  async addSubaddressAccount(label: string): Promise<void> {
    return await fns.Wallet_addSubaddressAccount(this.#ptr, CString(label));
  }

  async numSubaddressAccounts(): Promise<bigint> {
    return await fns.Wallet_numSubaddressAccounts(this.#ptr);
  }

  async addSubaddress(accountIndex: number, label: string): Promise<void> {
    return await fns.Wallet_addSubaddress(
      this.#ptr,
      accountIndex,
      CString(label),
    );
  }

  async numSubaddresses(accountIndex: number): Promise<bigint> {
    return await fns.Wallet_numSubaddresses(
      this.#ptr,
      accountIndex,
    );
  }

  async getSubaddressLabel(accountIndex: number, addressIndex: number): Promise<string | null> {
    return await readCString(
      await fns.Wallet_getSubaddressLabel(this.#ptr, accountIndex, addressIndex),
    );
  }

  async setSubaddressLabel(accountIndex: number, addressIndex: number, label: string): Promise<void> {
    return await fns.Wallet_setSubaddressLabel(this.#ptr, accountIndex, addressIndex, CString(label));
  }

  async isOffline(): Promise<boolean> {
    return await fns.Wallet_isOffline(this.#ptr);
  }

  async setOffline(offline: boolean): Promise<void> {
    return await fns.Wallet_setOffline(this.#ptr, offline);
  }

  async publicViewKey(): Promise<string | null> {
    return await readCString(await fns.Wallet_publicViewKey(this.#ptr));
  }

  async secretViewKey(): Promise<string | null> {
    return await readCString(await fns.Wallet_secretViewKey(this.#ptr));
  }

  async publicSpendKey(): Promise<string | null> {
    return await readCString(await fns.Wallet_publicSpendKey(this.#ptr));
  }

  async secretSpendKey(): Promise<string | null> {
    return await readCString(await fns.Wallet_secretSpendKey(this.#ptr));
  }

  async exportOutputs(fileName: string, all: boolean): Promise<boolean> {
    return await fns.Wallet_exportOutputs(this.#ptr, CString(fileName), all);
  }

  async exportOutputsUR(maxFragmentLength: bigint, all: boolean): Promise<string | null> {
    const exportOutputsUR = fns.Wallet_exportOutputsUR;
    if (!exportOutputsUR) return null;

    return await readCString(
      await exportOutputsUR(this.#ptr, maxFragmentLength, all),
    );
  }

  async importOutputs(fileName: string): Promise<boolean> {
    return await fns.Wallet_importOutputs(this.#ptr, CString(fileName));
  }

  async importOutputsUR(input: string): Promise<boolean | null> {
    const importOutputsUR = fns.Wallet_importOutputsUR;
    if (!importOutputsUR) return null;

    return await importOutputsUR(this.#ptr, CString(input));
  }

  async exportKeyImages(fileName: string, all: boolean): Promise<boolean> {
    return await fns.Wallet_exportKeyImages(this.#ptr, CString(fileName), all);
  }

  async exportKeyImagesUR(maxFragmentLength: bigint, all: boolean): Promise<string | null> {
    const exportKeyImagesUR = fns.Wallet_exportKeyImagesUR;
    if (!exportKeyImagesUR) return null;

    return await readCString(
      await exportKeyImagesUR(this.#ptr, maxFragmentLength, all),
    );
  }

  async importKeyImages(fileName: string): Promise<boolean> {
    return await fns.Wallet_importKeyImages(this.#ptr, CString(fileName));
  }

  async importKeyImagesUR(input: string): Promise<boolean | null> {
    const importKeyImagesUR = fns.Wallet_importKeyImagesUR;
    if (!importKeyImagesUR) return null;

    return await importKeyImagesUR(this.#ptr, CString(input));
  }

  async loadUnsignedTx(fileName: string): Promise<UnsignedTransaction> {
    const pendingTxPtr = await fns.Wallet_loadUnsignedTx(this.#ptr, CString(fileName));
    return UnsignedTransaction.new(pendingTxPtr as UnsignedTransactionPtr);
  }

  async loadUnsignedTxUR(input: string): Promise<UnsignedTransaction | null> {
    const loadUnsignedTxUR = fns.Wallet_loadUnsignedTxUR;
    if (!loadUnsignedTxUR) return null;

    const pendingTxPtr = await loadUnsignedTxUR(this.#ptr, CString(input));
    if (await this.status()) {
      throw this.errorString();
    }
    return UnsignedTransaction.new(pendingTxPtr as UnsignedTransactionPtr);
  }

  async createTransaction(
    destinationAddress: string,
    amount: bigint,
    pendingTransactionPriority: 0 | 1 | 2 | 3,
    subaddressAccount: number,
    prefferedInputs = "",
    mixinCount = 0,
    paymentId = "",
  ): Promise<PendingTransaction | null> {
    const pendingTxPtr = await fns.Wallet_createTransaction(
      this.#ptr,
      CString(destinationAddress),
      CString(paymentId),
      amount,
      mixinCount,
      pendingTransactionPriority,
      subaddressAccount,
      CString(prefferedInputs),
      C_SEPARATOR,
    );

    if (!pendingTxPtr) return null;
    return PendingTransaction.new(pendingTxPtr as PendingTransactionPtr);
  }

  async createTransactionMultDest(
    destinationAddresses: string[],
    amounts: bigint[],
    amountSweepAll: boolean,
    pendingTransactionPriority: 0 | 1 | 2 | 3,
    subaddressAccount: number,
    preferredInputs: string[] = [],
    mixinCount = 0,
    paymentId = "",
  ): Promise<PendingTransaction> {
    const pendingTxPtr = await fns.Wallet_createTransactionMultDest(
      this.#ptr,
      CString(destinationAddresses.join(SEPARATOR)),
      C_SEPARATOR,
      CString(paymentId),
      amountSweepAll,
      CString(amounts.join(SEPARATOR)),
      C_SEPARATOR,
      mixinCount,
      pendingTransactionPriority,
      subaddressAccount,
      CString(preferredInputs.join(SEPARATOR)),
      C_SEPARATOR,
    );
    return PendingTransaction.new(pendingTxPtr as PendingTransactionPtr);
  }

  async coins(): Promise<Coins | null> {
    const coinsPtr = await fns.Wallet_coins(this.#ptr);
    if (!coinsPtr) return null;

    return new Coins(coinsPtr as CoinsPtr);
  }

  async status(): Promise<number> {
    return await fns.Wallet_status(this.#ptr);
  }

  async errorString(): Promise<string | null> {
    if (!await this.status()) return null;
    const error = await fns.Wallet_errorString(this.#ptr);
    return await readCString(error);
  }

  async throwIfError(): Promise<void> {
    const maybeError = await this.errorString();
    if (maybeError) {
      throw new Error(maybeError);
    }
  }
}
