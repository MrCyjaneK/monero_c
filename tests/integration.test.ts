import {
  CoinsInfo,
  type Dylib,
  loadMoneroDylib,
  loadWowneroDylib,
  moneroSymbols,
  Wallet,
  WalletManager,
  wowneroSymbols,
} from "../impls/monero.ts/mod.ts";

import { assert, assertEquals } from "jsr:@std/assert";
import { $, downloadCli, getMoneroC } from "./utils.ts";

const coin = Deno.env.get("COIN");
if (coin !== "monero" && coin !== "wownero") {
  throw new Error("COIN env var invalid or missing");
}

async function syncBlockchain(wallet: Wallet): Promise<bigint> {
  // Wait for blockchain to sync
  const blockHeight = await new Promise<bigint>((resolve) => {
    let timeout: number;

    const poll = async () => {
      const blockChainHeight = await wallet.blockChainHeight();
      const daemonBlockchainHeight = await wallet.daemonBlockChainHeight();
      // console.log("Blockchain height:", blockChainHeight, "Daemon blockchain height:", daemonBlockchainHeight, "Remains:", daemonBlockchainHeight - blockChainHeight);
      if (blockChainHeight === daemonBlockchainHeight) {
        clearTimeout(timeout);
        resolve(blockChainHeight);
      } else {
        setTimeout(poll, 500);
      }
    };

    poll();
  });
  await new Promise((r) => setTimeout(r, 1500)); // wait for it to sync
  return blockHeight;
}

// TODO: Change for custom address on CI
const WOWNERO_NODE_URL = "https://node3.monerodevs.org:34568";
const MONERO_NODE_URL = "https://nodes.hashvault.pro:18081";
const NODE_URL = coin === "monero" ? MONERO_NODE_URL : WOWNERO_NODE_URL;

const WOWNERO_DESTINATION_ADDRESS =
  "WW3Zetw4Gg5Rk88ViCm8H8Ft8BqgAQ5DbTLZC1whv8GNFJPSoGfLViW3dAAb4Bcqpz2M1y31pZykd4ZKd8GH1UyF1fwEFg5mS";
const MONERO_DESTINATION_ADDRESS =
  "89BoVWjqdGVe68wdxbYurXR8sXaEb96eWKYRPxdT6wSCfZYK6XSHoj5ZRXQLtd7GzL2B2PD7Lb7GSKupkXMWjQVFAEb1CK8";
const DESTINATION_ADDRESS = coin === "monero" ? MONERO_DESTINATION_ADDRESS : WOWNERO_DESTINATION_ADDRESS;

const BILLION = 10n ** 9n;

await getMoneroC(coin, "next");

interface WalletInfo {
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

async function clearWallets() {
  await Deno.remove("tests/wallets/", { recursive: true }).catch(() => {});
  await Deno.mkdir("tests/wallets/");
}

let dylib: Dylib;
if (coin === "monero") {
  dylib = Deno.dlopen(`tests/libs/next/monero_libwallet2_api_c.so`, moneroSymbols);
  loadMoneroDylib(dylib);
} else {
  dylib = Deno.dlopen(`tests/libs/next/wownero_libwallet2_api_c.so`, wowneroSymbols);
  loadWowneroDylib(dylib);
}

Deno.test("0001-polyseed.patch", async (t) => {
  const WALLETS: Record<"monero" | "wownero", WalletInfo[]> = {
    monero: [
      //#region Cake wallet, no offset
      {
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
        name: "Spanish Wallet",
        password: "spanishwallet",
        seed:
          "rehén torpedo remo existir fuente dama culpa riqueza cebolla supremo vereda odio novio sumar espía margen",
        restoreHeight: 3254619n,
        address: "41xeBwVJEpVVrJntrvUXafJR4mk9x3tfW3zXxamh8G951SM9BbBLgJSgzwdCywLRrbZvipLL2Azu9jKbu4Y9Hey3MUF6f19",
        publicSpendKey: "08e31c09ad35beac7bcb9e4a689e40681df1b42cd2686511e344d02606bfc802",
        secretSpendKey: "19ae689bdd594fde5d06b66e4c7a89d9783c02694ae615e33928b38f0c52120c",
        publicViewKey: "9cdf4adfd9c7c7ef236c9084a0ceb4c4da6017b9fd1b6cfd04e02527ea6f06b5",
        secretViewKey: "40ae98266cadfbf546e861cac2b2e93ce921f9db2e02f072d86aea274a182006",
      },
      {
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
    ],
    wownero: [
      {
        name: "English Wowlet",
        password: "englishwallet",
        seed: "fragile proud oven shove trend visit oxygen dove pledge entire pencil exist throw type large chase",
        restoreHeight: 0n,
        address: "Wo4ExnCfajHZcVY9Q4XgjTYHu9GwyT9E7dZQuoFhY7HNWr2X6iD2wuB1asHQ1DVEtNYSLjqiCzJVDg5ZKeWnbKDe1LD9Wwy91",
        publicSpendKey: "88c53568fd38c2f957f229a7d4dabb142e4fcfd7c128da922b63e4f4df25b26e",
        secretSpendKey: "b131442ee0aecd410947a74bf622e2833397f372ee843fc3d291cb16a343e308",
        publicViewKey: "ea7a909bc832037db14c6a537357bbf2eedee84b7d00e9a2b1d718d92fe52693",
        secretViewKey: "96e03a70a4956656be6cc1fa2252f159ae0b2d2fdc21f761fc7e8d0316931708",
      },
      // TODO: Add other localized wallets for Wownero
    ],
  };

  await clearWallets();

  for (const walletInfo of WALLETS[coin]) {
    await t.step(walletInfo.name, async () => {
      const walletManager = await WalletManager.new();
      const path = `tests/wallets/${walletInfo.name}`;

      const wallet = await walletManager.recoverFromPolyseed(
        path,
        walletInfo.password,
        walletInfo.seed,
        walletInfo.restoreHeight,
        walletInfo.offset,
      );

      await wallet.init({}); // empty daemon address for offline test

      assertEquals(await wallet.address(), walletInfo.address);

      assertEquals(await wallet.publicSpendKey(), walletInfo.publicSpendKey);
      assertEquals(await wallet.secretSpendKey(), walletInfo.secretSpendKey);

      assertEquals(await wallet.publicViewKey(), walletInfo.publicViewKey);
      assertEquals(await wallet.secretViewKey(), walletInfo.secretViewKey);

      await wallet.close(true);
    });
  }
});

Deno.test("0002-wallet-background-sync-with-just-the-view-key.patch", async () => {
  await clearWallets();

  const walletManager = await WalletManager.new();
  const wallet = await walletManager.createWallet("tests/wallets/squirrel", "belka");
  await wallet.init({
    address: NODE_URL,
  });

  const walletInfo = {
    address: await wallet.address(),
    publicSpendKey: await wallet.publicSpendKey(),
    secretSpendKey: await wallet.secretSpendKey(),
    publicViewKey: await wallet.publicViewKey(),
    secretViewKey: await wallet.secretViewKey(),
  };

  await wallet.setupBackgroundSync(2, "belka", "background-belka");
  await wallet.startBackgroundSync();
  await wallet.close(true);

  const backgroundWallet = await walletManager.openWallet(
    "tests/wallets/squirrel.background",
    "background-belka",
  );
  await backgroundWallet.init({ address: NODE_URL });

  const blockChainHeight = await syncBlockchain(backgroundWallet);
  await backgroundWallet.refreshAsync();

  await backgroundWallet.close(true);

  const reopenedWallet = await walletManager.openWallet("tests/wallets/squirrel", "belka");
  await reopenedWallet.throwIfError();
  await reopenedWallet.refreshAsync();

  assertEquals(await reopenedWallet.blockChainHeight(), blockChainHeight);
  assertEquals(
    walletInfo,
    {
      address: await reopenedWallet.address(),
      publicSpendKey: await reopenedWallet.publicSpendKey(),
      secretSpendKey: await reopenedWallet.secretSpendKey(),
      publicViewKey: await reopenedWallet.publicViewKey(),
      secretViewKey: await reopenedWallet.secretViewKey(),
    },
  );

  await reopenedWallet.close(true);
});

Deno.test("0004-coin-control.patch", {
  ignore: coin === "wownero" || !(
    Deno.env.get("SECRET_WALLET_PASSWORD") &&
    Deno.env.get("SECRET_WALLET_MNEMONIC") &&
    Deno.env.get("SECRET_WALLET_RESTORE_HEIGHT")
  ),
}, async (t) => {
  await clearWallets();

  const walletManager = await WalletManager.new();
  const wallet = await walletManager.recoverFromPolyseed(
    "tests/wallets/secret-wallet",
    Deno.env.get("SECRET_WALLET_PASSWORD")!,
    Deno.env.get("SECRET_WALLET_MNEMONIC")!,
    BigInt(Deno.env.get("SECRET_WALLET_RESTORE_HEIGHT")!),
  );

  assertEquals(
    await wallet.address(),
    "434dZdLzhymcoNyGSBUJAqhDCLtBECN6698CGRMYByuEAYtpxXdbiibQb3t4qX3SiZi9vDWkxeiEF8kmDGmEoEZ4VMG8Nvh",
  );

  await wallet.init({ address: NODE_URL });
  await wallet.refreshAsync();

  // Wait for blockchain to sync
  await syncBlockchain(wallet);

  await wallet.refreshAsync();
  await wallet.store();
  await wallet.refreshAsync();

  const coins = (await wallet.coins())!;
  await coins.refresh();

  // COINS:
  // 5x 0.001XMR 1x 0.005XMR (in no particular order)
  await t.step("preffered_inputs", async (t) => {
    const coinsCount = await coins.count();

    const availableCoinsData: Record<string, {
      index: number;
      coin: CoinsInfo;
      keyImage: string | null;
      amount: bigint;
    }[]> = {
      ["0.001"]: [],
      ["0.005"]: [],
    };

    const freezeAll = async () => {
      for (const [_, coinsData] of Object.entries(availableCoinsData)) {
        for (const coinData of coinsData) {
          await coins.setFrozen(coinData.index);
        }
      }
      await coins.refresh();
    };

    const thawAll = async () => {
      for (const [_, coinsData] of Object.entries(availableCoinsData)) {
        for (const coinData of coinsData) {
          await coins.thaw(coinData.index);
        }
      }
      await coins.refresh();
    };

    let availableCoinsCount = 0;
    let totalAvailableAmount = 0n;
    for (let i = 0; i < coinsCount; ++i) {
      const coin = (await coins.coin(i))!;
      if (coin.spent) {
        continue;
      }

      let humanReadableAmount: string;
      if (coin.amount === BILLION) {
        humanReadableAmount = "0.001";
      } else if (coin.amount === 5n * BILLION) {
        humanReadableAmount = "0.005";
      } else {
        throw new Error("Invalid coin amount! Only 5x0.01XMR coins and 1x0.05XMR coin should be available");
      }

      availableCoinsData[humanReadableAmount].push({
        index: i,
        coin,
        keyImage: coin.keyImage,
        amount: coin.amount,
      });

      totalAvailableAmount += coin.amount;
      availableCoinsCount += 1;

      await coins.thaw(i);
    }

    await coins.refresh();

    assertEquals(availableCoinsCount, 6);
    assertEquals(totalAvailableAmount, 10n * BILLION);

    await t.step("Try to spend 0.002XMR by using only one 0.001XMR coin", async () => {
      const transaction = await wallet.createTransaction(
        DESTINATION_ADDRESS,
        2n * BILLION,
        0,
        0,
        availableCoinsData["0.001"][0].keyImage!,
      );

      if (!transaction) {
        throw new Error("Failed creating a transaction");
      }

      assertEquals(await transaction.status(), 1);
    });

    await t.step("Try to spend 0.002XMR with only 0.001XMR unlocked balance", async () => {
      await freezeAll();
      await coins.thaw(availableCoinsData["0.001"][0].index);

      const transaction = await wallet.createTransaction(DESTINATION_ADDRESS, 2n * BILLION, 0, 0);

      if (!transaction) {
        throw new Error("Failed creating a transaction: " + await wallet.errorString());
      }

      assertEquals(await transaction.status(), 1);
      assert((await transaction.errorString())?.includes("not enough money to transfer"));

      await thawAll();
    });

    await t.step("Try to spend 0.002XMR + fee with only 0.002XMR unlocked balance", async () => {
      await freezeAll();
      await coins.thaw(availableCoinsData["0.001"][0].index);
      await coins.thaw(availableCoinsData["0.001"][1].index);

      const transaction = await wallet.createTransaction(
        DESTINATION_ADDRESS,
        2n * BILLION,
        0,
        0,
        availableCoinsData["0.001"][0].keyImage!,
      );

      if (!transaction) {
        throw new Error("Failed creating a transaction: " + await wallet.errorString());
      }

      assertEquals(await transaction.status(), 1);
      assertEquals(
        await transaction.errorString(),
        "not enough money to transfer, overall balance only 0.002000000000, sent amount 0.002000000000",
      );
    });

    await thawAll();
  });

  await t.step("spend more than unfrozen balance", async () => {
    const unlockedBalance = await wallet.unlockedBalance();
    const transaction = await wallet.createTransaction(DESTINATION_ADDRESS, unlockedBalance + 1n, 0, 0);

    if (!transaction) {
      throw new Error("Failed creating a transaction: " + await wallet.errorString());
    }

    assertEquals(await transaction.status(), 1);
    assert(
      await transaction.errorString(),
      "not enough money to transfer, overall balance only 0.001000000000, sent amount 0.001000000001",
    );
  });

  await wallet.close(true);
});

Deno.test("0009-Add-recoverDeterministicWalletFromSpendKey.patch", async () => {
  await Promise.all([
    downloadCli(coin),
    clearWallets(),
  ]);

  const walletManager = await WalletManager.new();
  const wallet = await walletManager.createWallet("tests/wallets/stoat", "gornostay");
  const moneroCSeed = await wallet.seed();
  await wallet.close(true);

  await Deno.remove("./tests/wallets/stoat");

  const cliPath = `./tests/${coin}-cli/${coin}-wallet-cli`;
  const moneroCliSeed = (await $.raw`${cliPath} --wallet-file ./tests/wallets/stoat --password gornostay --command seed`
    .stdinText(`gornostay\n`)
    .lines()).slice(-3).join(" ");

  assertEquals(moneroCSeed, moneroCliSeed);
});

Deno.test("0012-WIP-UR-functions.patch", {
  ignore: coin === "wownero" || !(
    Deno.env.get("SECRET_WALLET_PASSWORD") &&
    Deno.env.get("SECRET_WALLET_MNEMONIC") &&
    Deno.env.get("SECRET_WALLET_RESTORE_HEIGHT")
  ),
}, async (t) => {
  for (const method of ["UR", "file"] as const) {
    await clearWallets();

    const walletManager = await WalletManager.new();

    const airgap = await walletManager.recoverFromPolyseed(
      "tests/wallets/secret-wallet",
      Deno.env.get("SECRET_WALLET_PASSWORD")!,
      Deno.env.get("SECRET_WALLET_MNEMONIC")!,
      BigInt(Deno.env.get("SECRET_WALLET_RESTORE_HEIGHT")!),
    );
    await airgap.init({ address: "" });

    const online = await walletManager.recoverFromKeys(
      "tests/wallets/horse-online",
      "loshad-online",
      BigInt(Deno.env.get("SECRET_WALLET_RESTORE_HEIGHT")!) - 2000n,
      (await airgap.address())!,
      (await airgap.secretViewKey())!,
      "",
    );
    await online.init({ address: NODE_URL });
    await online.refreshAsync();

    await syncBlockchain(online);

    await online.refreshAsync();
    await online.store();
    await online.refreshAsync();

    if (method === "UR") {
      await t.step({
        name: "Sync wallets (UR)",
        ignore: coin === "wownero", // Wownero doesn't have UR methods
        fn: async () => {
          try {
            const outputs = await online.exportOutputsUR(130n, false);
            await airgap.importOutputsUR(outputs!);

            const keyImages = await airgap.exportKeyImagesUR(130n, false);
            await online.importKeyImagesUR(keyImages!);
          } catch {
            const outputs = await online.exportOutputsUR(130n, true);
            await airgap.importOutputsUR(outputs!);

            const keyImages = await airgap.exportKeyImagesUR(130n, true);
            await online.importKeyImagesUR(keyImages!);
          }
        },
      });

      await t.step({
        name: "Transaction (UR)",
        ignore: coin === "wownero",
        fn: async () => {
          const transaction = await online.createTransaction(DESTINATION_ADDRESS, 1n * BILLION, 0, 0);
          if (!transaction) {
            throw new Error("Failed creating online transaction: " + await online.errorString());
          }

          const input = await transaction.commitUR(130);

          const unsignedTx = (await airgap.loadUnsignedTxUR(input!))!;
          if (!unsignedTx) {
            throw new Error("Failed creating unsigned transaction: " + await online.errorString());
          }

          assertEquals(await unsignedTx.status(), 0);
          assertEquals(unsignedTx.recipientAddress, DESTINATION_ADDRESS);
          assert(!isNaN(Number(unsignedTx.fee)));
          assertEquals(unsignedTx.amount, "1000000000");

          await unsignedTx.signUR(130);
          assertEquals(await unsignedTx.status(), 0, (await unsignedTx.errorString())!);
        },
      });
    } else {
      await t.step("Sync wallets (File)", async () => {
        try {
          await online.exportOutputs("tests/wallets/outputs", false);
          await airgap.importOutputs("tests/wallets/outputs");

          await airgap.exportKeyImages("tests/wallets/keyImages", false);
          await online.importKeyImages("tests/wallets/keyImages");
        } catch {
          await online.exportOutputs("tests/wallets/outputs", true);
          await airgap.importOutputs("tests/wallets/outputs");

          await airgap.exportKeyImages("tests/wallets/keyImages", true);
          await online.importKeyImages("tests/wallets/keyImages");
        }
      });

      await t.step("Transaction (File)", async () => {
        const transaction = await online.createTransaction(DESTINATION_ADDRESS, 1n * BILLION, 0, 0);
        if (!transaction) {
          throw new Error("Failed creating online transaction: " + await online.errorString());
        }

        await transaction.commit("tests/wallets/transaction", false);

        const unsignedTx = await airgap.loadUnsignedTx("tests/wallets/transaction");
        if (!unsignedTx) {
          throw new Error("Failed creating unsigned transaction: " + await online.errorString());
        }

        assertEquals(await unsignedTx.status(), 0);
        assertEquals(unsignedTx.amount, "1000000000");
        assertEquals(unsignedTx.recipientAddress, DESTINATION_ADDRESS);
        assert(!isNaN(Number(unsignedTx.fee)));

        await unsignedTx.sign("tests/wallets/signed-transaction");
        assertEquals(await unsignedTx.status(), 0);
      });
    }
  }
});
