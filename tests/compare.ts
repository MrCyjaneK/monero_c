import { moneroSymbols as symbols, type MoneroTsDylib, type WowneroTsDylib } from "../impls/monero.ts/src/symbols.ts";
import { loadMoneroDylib, loadWowneroDylib } from "../impls/monero.ts/src/bindings.ts";
import { Wallet, WalletManager } from "../impls/monero.ts/mod.ts";
import { readCString } from "../impls/monero.ts/src/utils.ts";
import { assertEquals } from "jsr:@std/assert";

const coin = Deno.args[0] as "monero" | "wownero";
const version = Deno.args[1];
const walletInfo = JSON.parse(Deno.args[2]);

const moneroSymbols = {
  ...symbols,

  "MONERO_Wallet_secretViewKey": {
    nonblocking: true,
    // void* wallet_ptr
    parameters: ["pointer"],
    // const char*
    result: "pointer",
  },
  "MONERO_Wallet_publicViewKey": {
    nonblocking: true,
    // void* wallet_ptr
    parameters: ["pointer"],
    // const char*
    result: "pointer",
  },

  "MONERO_Wallet_secretSpendKey": {
    nonblocking: true,
    // void* wallet_ptr
    parameters: ["pointer"],
    // const char*
    result: "pointer",
  },
  "MONERO_Wallet_publicSpendKey": {
    nonblocking: true,
    // void* wallet_ptr
    parameters: ["pointer"],
    // const char*
    result: "pointer",
  },
} as const;

type ReplaceMonero<T extends string> = T extends `MONERO${infer Y}` ? `WOWNERO${Y}` : never;
type WowneroSymbols = { [Key in keyof typeof moneroSymbols as ReplaceMonero<Key>]: (typeof moneroSymbols)[Key] };
const wowneroSymbols = Object.fromEntries(
  Object.entries(moneroSymbols).map(([key, value]) => [key.replace("MONERO", "WOWNERO"), value]),
) as WowneroSymbols;

let getKey: (wallet: Wallet, type: `${"secret" | "public"}${"Spend" | "View"}Key`) => Promise<string | null>;

if (coin === "monero") {
  const dylib = Deno.dlopen(`tests/libs/${version}/monero_libwallet2_api_c.so`, moneroSymbols);
  loadMoneroDylib(dylib as MoneroTsDylib);

  getKey = async (wallet, type) =>
    await readCString(await dylib.symbols[`MONERO_Wallet_${type}` as const](wallet.getPointer()));
} else {
  const dylib = Deno.dlopen(`tests/libs/${version}/wownero_libwallet2_api_c.so`, wowneroSymbols);
  loadWowneroDylib(dylib as WowneroTsDylib);

  getKey = async (wallet, type) =>
    await readCString(
      await dylib.symbols[`WOWNERO_Wallet_${type}` as const](wallet.getPointer()),
    );
}

const walletManager = await WalletManager.new();
const wallet = await Wallet.open(walletManager, walletInfo.path, walletInfo.password);

assertEquals(await wallet.address(), walletInfo.address);

assertEquals(await getKey(wallet, "publicSpendKey"), walletInfo.publicSpendKey);
assertEquals(await getKey(wallet, "secretSpendKey"), walletInfo.secretSpendKey);

assertEquals(await getKey(wallet, "publicViewKey"), walletInfo.publicViewKey);
assertEquals(await getKey(wallet, "secretViewKey"), walletInfo.secretViewKey);

await wallet.store(walletInfo.path);
