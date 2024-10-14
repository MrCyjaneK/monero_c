import { loadDylib, symbols as bindingsSymbols } from "../impls/monero.ts/src/bindings.ts";
import { Wallet, WalletManager } from "../impls/monero.ts/mod.ts";
import { readCString } from "../impls/monero.ts/src/utils.ts";
import { assertEquals } from "jsr:@std/assert";

const version = Deno.args[0];
const walletInfo = JSON.parse(Deno.args[1]);

// Those don't exist on older versions of monero_c
// @ts-expect-error -
delete bindingsSymbols.MONERO_checksum_wallet2_api_c_h;
// @ts-expect-error -
delete bindingsSymbols.MONERO_checksum_wallet2_api_c_cpp;
// @ts-expect-error -
delete bindingsSymbols.MONERO_checksum_wallet2_api_c_exp;

const symbols = {
  ...bindingsSymbols,

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

const dylib = Deno.dlopen(`tests/libs/${version}/monero_libwallet2_api_c.so`, symbols);
loadDylib(dylib as Deno.DynamicLibrary<typeof bindingsSymbols>);

const walletManager = await WalletManager.new();
const wallet = await Wallet.open(walletManager, walletInfo.path, walletInfo.password);

assertEquals(await wallet.address(), walletInfo.address);

const getKey = async (wallet: Wallet, type: `${"secret" | "public"}${"Spend" | "View"}Key`) =>
  await readCString(
    await dylib.symbols[`MONERO_Wallet_${type}` as const](wallet.getPointer()),
  );

assertEquals(await getKey(wallet, "publicSpendKey"), walletInfo.publicSpendKey);
assertEquals(await getKey(wallet, "secretSpendKey"), walletInfo.secretSpendKey);

assertEquals(await getKey(wallet, "publicViewKey"), walletInfo.publicViewKey);
assertEquals(await getKey(wallet, "secretViewKey"), walletInfo.secretViewKey);

await wallet.store(walletInfo.path);
