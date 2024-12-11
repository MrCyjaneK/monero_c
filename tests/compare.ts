import { assertEquals } from "jsr:@std/assert";

import { WalletManager } from "../impls/monero.ts/mod.ts";
import { loadDylib } from "./utils.ts";

const coin = Deno.args[0] as "monero" | "wownero";
const version = Deno.args[1];
const walletInfo = JSON.parse(Deno.args[2]);

loadDylib(coin, version);

const walletManager = await WalletManager.new();
const wallet = await walletManager.openWallet(walletInfo.path, walletInfo.password);

assertEquals(await wallet.address(), walletInfo.address);

assertEquals(await wallet.publicSpendKey(), walletInfo.publicSpendKey);
assertEquals(await wallet.secretSpendKey(), walletInfo.secretSpendKey);

assertEquals(await wallet.publicViewKey(), walletInfo.publicViewKey);
assertEquals(await wallet.secretViewKey(), walletInfo.secretViewKey);

await wallet.store(walletInfo.path);
