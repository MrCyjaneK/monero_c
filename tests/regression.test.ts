import { $, createWalletViaCli, downloadCli, getMoneroC, getMoneroCTags } from "./utils.ts";

const coin = Deno.env.get("COIN");
if (coin !== "monero" && coin !== "wownero") {
  throw new Error("COIN env var invalid or missing");
}

Deno.test(`Regression tests (${coin})`, async (t) => {
  await Deno.remove("./tests/wallets", { recursive: true }).catch(() => {});
  await Deno.mkdir("./tests/wallets", { recursive: true });

  const tags = await getMoneroCTags();
  const latestTag = tags[0];
  await Promise.all([getMoneroC(coin, "next"), await getMoneroC(coin, latestTag), downloadCli(coin)]);

  await t.step("Simple (next, latest, next)", async () => {
    const walletInfo = await createWalletViaCli(coin, "dog", "sobaka");

    for (const version of ["next", latestTag, "next"]) {
      await $`deno run -A ./tests/compare.ts ${coin} ${version} ${JSON.stringify(walletInfo)}`;
    }
  });

  await t.step("All releases sequentially (all tags in the release order, next)", async () => {
    tags.unshift("next");

    const walletInfo = await createWalletViaCli(coin, "cat", "koshka");

    for (const version of tags.toReversed()) {
      if (version !== "next" && version !== tags[0]) await getMoneroC(coin, version);
      await $`deno run -A ./tests/compare.ts ${coin} ${version} ${JSON.stringify(walletInfo)}`;
    }

    await Deno.remove("./tests/wallets", { recursive: true }).catch(() => {});
  });

  await Deno.remove("./tests/wallets", { recursive: true }).catch(() => {});
  await Deno.remove("./tests/libs", { recursive: true }).catch(() => {});
});
