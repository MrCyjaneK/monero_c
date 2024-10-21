import { type Dylib, moneroSymbols, wowneroSymbols } from "../impls/monero.ts/src/symbols.ts";
import { loadMoneroDylib, loadWowneroDylib } from "../impls/monero.ts/src/bindings.ts";
import { Wallet, WalletManager } from "../impls/monero.ts/mod.ts";
import { readCString } from "../impls/monero.ts/src/utils.ts";
import { assertEquals } from "jsr:@std/assert";
import { getMoneroC } from "./utils.ts";
import { getSymbol } from "../impls/monero.ts/src/utils.ts";

const coin = Deno.env.get("COIN");
if (coin !== "monero" && coin !== "wownero") {
  throw new Error("COIN env var invalid or missing");
}

async function getKey(wallet: Wallet, type: `${"secret" | "public"}${"Spend" | "View"}Key`): Promise<string | null> {
  return await readCString(await getSymbol(`Wallet_${type}` as const)(wallet.getPointer()));
}

// TODO: Change for custom address on CI
const NODE_URL = "https://nodes.hashvault.pro:18081";

// await getMoneroC(coin, "next");

interface WalletInfo {
  coin: "monero" | "wownero";

  name: string;
  password: string;
  seed: string;
  offset?: string;
  address: string;
  restoreHeight: bigint;

  publicSpendKey: string;
  secretSpendKey: string;
  publicViewKey: string;
  secretViewKey: string;
}

Deno.test("0001-polyseed.patch", async (t) => {
  const WALLETS: WalletInfo[] = [
    //#region Cake wallet, no offset
    {
      coin: "monero",
      name: "English Wallet",
      password: "englishwallet",
      seed:
        "tortoise winter play argue laptop diary tell library travel cupboard view river embark rubber plunge student",
      restoreHeight: 3254619n,
      address: "49PL6qHMkc4Hw3dWT5wy5NbbVd2xda8zw3tLx2BoQsNZUWDQYYpwMEKjB9BLbEKSo3S3z34bncFw6ijToTwfiEJJ5m8aefx",
      publicSpendKey: "ccd6846ab69fdd653a8d092d89590dced40aa2862f3c24113fedfcd6469162a4",
      secretSpendKey: "37fd2e3e933c8468beb407e5350789e23bed5df33eeeb35d3b119401988e6709",
      publicViewKey: "6f0de7385aafd4fc259cbd0abb069295c5d3824b7e1b81f97ffcf8cccde6c72a",
      secretViewKey: "b8095208d61fc22e4ee3a79347a889e4872cdcf1cceff991542834cef5375907",
    },
    {
      coin: "monero",
      name: "Chinese Traditional Wallet",
      password: "chinesetraditionalwallet",
      seed: "旗 铁 革 酯 紧 毅 饱 应 第 兄 植 隙 点 吐 童 赞",
      restoreHeight: 3254619n,
      address: "4AR8YW51Ga3DR4a47F5J8rXaqyBa8pnnF557pTyt52ZqNMFa3gfxvi13R7sbt5zHfjbF5aKsLFZQrRod3qcr5MQj4f91rLh",
      publicSpendKey: "e80bab7b3e2d384a393b825cf4f2abb6d8d08f1742d87c1856c064a609a0647f",
      secretSpendKey: "c7de78f9819db6755e14d2e1411f1591c2d0b3a6ee19049c30e270f81eb50401",
      publicViewKey: "a366527c3a6d160e717ebaac11d08eccb95586991a4c87944ad750331adac020",
      secretViewKey: "aab2ea0dc6fa2745c8c7113399242c03300664a21cac9202c315ad789b67d004",
    },
    {
      coin: "monero",
      name: "Chinese Simplified Wallet",
      password: "chinesesimplifiedwallet",
      seed: "纹 触 集 驶 朋 辨 你 版 是 益 驳 修 偏 汽 录 吨",
      restoreHeight: 3254619n,
      address: "47E7p1mFGNj59QNfjpXcopP1YZuGdn7NhYJv25xbPKdicnThww5DUv2aNMH7oPWsKZjQQmXMkBzUze2T6gAaXafLAF9E4Dz",
      publicSpendKey: "93dec0155d30b818c7d64a0b0c3a678395e3e28bdd736abb2ef7c360b38449d5",
      secretSpendKey: "60084b4ff3d99d6ca38876078721c13692635429c74ef5d71f03310cf2e0690b",
      publicViewKey: "eff74761051a2fc77eac4d7ed1b564fd83c0e3e924199bdd5ba66b4bf4ecf351",
      secretViewKey: "3bde0d3a1bd2877f75fc9f6ea331c976d26a62e469db1d11ddaef2cce9405d02",
    },
    {
      coin: "monero",
      name: "Japanese Wallet",
      password: "japanesewallet",
      seed:
        "きほん　ことば　そうび　きどう　なまえ　ひさしぶり　ごうけい　ふひょう　ぎゅうにく　しはらい　きびしい　はんとし　ととのえる　たかい　とかい　るりがわら",
      restoreHeight: 3254619n,
      address: "45YYsW5do7NjGSaRZPAkPQ9mi4HQsMv3w86HFddtkZi4cCbqtFiVoqJjdFobCtCwpBPZWSnUtmrU2G9fLpEE7vsQU3aZyeE",
      publicSpendKey: "677ac034b7c3e9fcb178370e3df067346ff5703db8273e2a65010862a85935d2",
      secretSpendKey: "1fe9110cc46c58ed0f5cb6c6e189e246f6c3cfbf459de2ed1565838b6e08780e",
      publicViewKey: "7276d8537e0cd9fed6b9327177ed9086e159f7d63b9fb35a92693cdbf322ffef",
      secretViewKey: "f3c8f4121cdf07616453f005e7f2cf0474cf3608ec632f4e81165ec1c5b4aa0c",
    },
    {
      coin: "monero",
      name: "Korean Wallet",
      password: "koreanwallet",
      seed: "단골 운전 일대 제작 구역 보자기 대한민국 답장 쇼핑 논문 편견 대전 충돌 강당 형제 볼펜",
      restoreHeight: 3254619n,
      address: "42DNYppLMXki8j3urYuXaTU1S9EBrSJ71aVNbzr4fKfnXryMwJ2rFt6Y5eCP9vpej9AdrZqNFXDFB1VmkjzjX5e5URJ9q8c",
      publicSpendKey: "0f96caeac7cd4ff5eb55810b4eb87ca1779637e949d138c837fe9a776b3c51b8",
      secretSpendKey: "d86c40f13694e7511499cdb22db4e96ee2990cfffde52274248bb8818a36c406",
      publicViewKey: "826438a35b0f63b9d0b877269a0468399b3f60513e079602f73c4b0f7cd0e6f3",
      secretViewKey: "3773b61c0cac3a2e15d03b989461704c6e90916561c6b98d035bd3d2caf88c05",
    },
    {
      coin: "monero",
      name: "Portugese Wallet",
      password: "portugesewallet",
      seed:
        "inscrito raposa vermelho medusa apetite bacharel quantia usado poupar pilotar sigilo ideia robalo ignorado desgaste intimar",
      restoreHeight: 3254619n,
      address: "43xw29tpLnU5VaPZ8Nuzz7DqrnUip5tmWBn3aukkZAyzgHTscJHvESy6pmYutLebQAB9TJgGhoCAWhPK6WJ39CpiD29fbwj",
      publicSpendKey: "3dcbbde593acc11adc291eeeec8bc44cc7943192d54fb1406de435b4d7b73dea",
      secretSpendKey: "9b94f57038b07b8280f27cedbed6e53472b48fe4683de15cc9e034fdddfcbb05",
      publicViewKey: "dce02ef2ca595e22d1242a53b5235f3ca8508e22386d03f171bc77ef856e1b6a",
      secretViewKey: "27bdd486a74f9b7c7a79c39c8ff7438a3fc862bb1ec3f6ef035a8acedf876705",
    },
    {
      coin: "monero",
      name: "Czech Wallet",
      password: "czechwallet",
      seed:
        "ulice louskat odmlka parodie dominant slanina sukno vodivost zimnice vykonat sundat kalibr dobro moucha kometa legenda",
      restoreHeight: 3254619n,
      address: "499LrJgGPkFA1BPvF4xqr5bwZfKyCZah1C2CEhvqpW7YGQddwWYyR2L1F1TJhqyxxwa4TXKYZM4bb8ukq3kein1cPMNLLi4",
      publicSpendKey: "c6796799947e0c35d3720af264d6a6d0e5a574cea1cde441e343b828a00c875c",
      secretSpendKey: "61f9c86a71744a101c36b5628c1c4324e49e84861f136cbd2d0f1477ba5ace0b",
      publicViewKey: "1d75ed535e3dfd0171a4a714aef368c5a6862aaf9972422f49cd76d232f88fc6",
      secretViewKey: "47fd8eadc1848a09b343815a74185835a0b2cc8567e61022322dd52f6aaf2004",
    },
    {
      coin: "monero",
      name: "Spanish Wallet",
      password: "spanishwallet",
      seed: "rehén torpedo remo existir fuente dama culpa riqueza cebolla supremo vereda odio novio sumar espía margen",
      restoreHeight: 3254619n,
      address: "41xeBwVJEpVVrJntrvUXafJR4mk9x3tfW3zXxamh8G951SM9BbBLgJSgzwdCywLRrbZvipLL2Azu9jKbu4Y9Hey3MUF6f19",
      publicSpendKey: "08e31c09ad35beac7bcb9e4a689e40681df1b42cd2686511e344d02606bfc802",
      secretSpendKey: "19ae689bdd594fde5d06b66e4c7a89d9783c02694ae615e33928b38f0c52120c",
      publicViewKey: "9cdf4adfd9c7c7ef236c9084a0ceb4c4da6017b9fd1b6cfd04e02527ea6f06b5",
      secretViewKey: "40ae98266cadfbf546e861cac2b2e93ce921f9db2e02f072d86aea274a182006",
    },
    {
      coin: "monero",
      name: "Italian Wallet",
      password: "italianwallet",
      seed:
        "fuso rinvenire astenuto camicia erboso icona bollito esito spettrale abisso dogma appunto prefisso gracile podismo araldica",
      restoreHeight: 3254619n,
      address: "46Kkbh8jLorHRKJEV7C4hNczZknHeB6w4GHpLWkpfThMdPLeeU8MFRmDfMqioYyacCTAG9wZ9y9UHZDNhehEssDVHePj3Ja",
      publicSpendKey: "7c0b928d9d8349622a07673a9721e9d72f60ccfc8e83935b699c379999104cd9",
      secretSpendKey: "673b61bdb369cc61a022e0eab47e5e41cf86e99a80979f75ebcda1219ee0ab01",
      publicViewKey: "8858e908f756c44bb286d5b657824d9c660386c7db0b0ec0974d268a7432bc93",
      secretViewKey: "5012dbfa9e1cd2a30c2a18654dc9c8bee128af8fe7246c46e5f4def76705fe0f",
    },
    //#endregion
    //#region Feather wallet, offset
    {
      coin: "monero",
      name: "English Wallet (offset)",
      password: "englishwallet",
      seed: "loud fix cattle broken right main web rather write aunt left nation broken ship program ten",
      offset: "englishoffset",
      restoreHeight: 3263855n,
      address: "4B2QGWy9as7bwwLNq2DQ26Q3woahpTLbR7d8vJE1uKL5gobU9iMydFqbVrYa9ixfrnAvnuwT9BXpkBx1APocbJfb2drFuQi",
      publicSpendKey: "f817ca86625d1ed0ef81ccb8a4e82b89cfc3345512c7b82798ba2f5982b7daed",
      secretSpendKey: "39ae15e92e08a0903652b4b0f187d740d2a5bf08e77879babb345b9a78ca6504",
      publicViewKey: "f7fb585b9a288cce3f3b1a5f0ca6873b5a2fef8afb3bd94174ac31cbed53620e",
      secretViewKey: "d5676e49438b0cd38c6a699ab783c11f21e1a7ebc1c9174121e37456a97f380d",
    },
    //#endregion
  ];

  let dylib: Dylib;
  if (coin === "monero") {
    dylib = Deno.dlopen(`tests/libs/next/monero_libwallet2_api_c.so`, moneroSymbols);
    loadMoneroDylib(dylib);
  } else {
    dylib = Deno.dlopen(`tests/libs/next/wownero_libwallet2_api_c.so`, wowneroSymbols);
    loadWowneroDylib(dylib);
  }

  await Deno.remove("tests/wallets/", { recursive: true }).catch(() => {});
  await Deno.mkdir("tests/wallets/");

  for (const walletInfo of WALLETS) {
    if (walletInfo.coin !== coin) continue;

    await t.step(walletInfo.name, async () => {
      const walletManager = await WalletManager.new();
      const path = `tests/wallets/${walletInfo.name}`;

      const wallet = await Wallet.recoverFromPolyseed(
        walletManager,
        path,
        walletInfo.password,
        walletInfo.seed,
        walletInfo.restoreHeight,
        walletInfo.offset,
      );

      await wallet.initWallet(NODE_URL);

      assertEquals(await wallet.address(), walletInfo.address);

      assertEquals(await getKey(wallet, "publicSpendKey"), walletInfo.publicSpendKey);
      assertEquals(await getKey(wallet, "secretSpendKey"), walletInfo.secretSpendKey);

      assertEquals(await getKey(wallet, "publicViewKey"), walletInfo.publicViewKey);
      assertEquals(await getKey(wallet, "secretViewKey"), walletInfo.secretViewKey);

      await wallet.store();
    });
  }

  dylib.close();
});

Deno.test("0002-wallet-background-sync-with-just-the-view-key.patch", async () => {
  await Deno.remove("tests/wallets/", { recursive: true }).catch(() => {});
  await Deno.mkdir("tests/wallets/");

  let dylib: Dylib;
  if (coin === "monero") {
    dylib = Deno.dlopen(`tests/libs/next/monero_libwallet2_api_c.so`, moneroSymbols);
    loadMoneroDylib(dylib);
  } else {
    dylib = Deno.dlopen(`tests/libs/next/wownero_libwallet2_api_c.so`, wowneroSymbols);
    loadWowneroDylib(dylib);
  }

  const walletManager = await WalletManager.new();
  const wallet = await Wallet.create(walletManager, "tests/wallets/squirrel", "belka");
  await wallet.initWallet(NODE_URL);

  const walletInfo = {
    address: await wallet.address(),
    publicSpendKey: await getKey(wallet, "publicSpendKey"),
    secretSpendKey: await getKey(wallet, "secretSpendKey"),
    publicViewKey: await getKey(wallet, "publicViewKey"),
    secretViewKey: await getKey(wallet, "secretViewKey"),
  };

  await wallet.setupBackgroundSync(2, "belka", "background-belka");
  await wallet.startBackgroundSync();
  await wallet.close(true);

  const backgroundWallet = await Wallet.open(
    walletManager,
    "tests/wallets/squirrel.background",
    "background-belka",
  );
  await backgroundWallet.initWallet(NODE_URL);

  const blockChainHeight = await new Promise((resolve) => {
    const interval = setInterval(async () => {
      const blockChainHeight = BigInt(await backgroundWallet.blockChainHeight());
      const daemonBlockchainHeight = BigInt(await backgroundWallet.daemonBlockChainHeight());
      console.log("Blockchain height:", blockChainHeight, "Daemon blockchain height:", daemonBlockchainHeight);

      if (blockChainHeight === daemonBlockchainHeight) {
        clearInterval(interval);
        resolve(blockChainHeight);
      }
    }, 1000);
  });

  await backgroundWallet.close(true);

  const reopenedWallet = await Wallet.open(walletManager, "tests/wallets/squirrel", "belka");
  await reopenedWallet.throwIfError();
  await reopenedWallet.refreshAsync();

  assertEquals(BigInt(await reopenedWallet.blockChainHeight()), blockChainHeight);
  assertEquals(
    walletInfo,
    {
      address: await reopenedWallet.address(),
      publicSpendKey: await getKey(reopenedWallet, "publicSpendKey"),
      secretSpendKey: await getKey(reopenedWallet, "secretSpendKey"),
      publicViewKey: await getKey(reopenedWallet, "publicViewKey"),
      secretViewKey: await getKey(reopenedWallet, "secretViewKey"),
    },
  );

  dylib.close();
});

Deno.test("0009-Add-recoverDeterministicWalletFromSpendKey.patch", async (t) => {
  let dylib: Dylib;
  if (coin === "monero") {
    dylib = Deno.dlopen(`tests/libs/next/monero_libwallet2_api_c.so`, moneroSymbols);
    loadMoneroDylib(dylib);
  } else {
    dylib = Deno.dlopen(`tests/libs/next/wownero_libwallet2_api_c.so`, wowneroSymbols);
    loadWowneroDylib(dylib);
  }

  await dylib.close();
});
