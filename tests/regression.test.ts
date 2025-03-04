import { $, createWalletViaCli, getMoneroCTags, prepareCli, prepareMoneroC } from "./utils.ts";

const coin = Deno.env.get("COIN");
if (coin !== "monero" && coin !== "wownero") {
  throw new Error("COIN env var invalid or missing");
}

Deno.test(`Regression tests (${coin})`, async (t) => {
  await Deno.remove("./tests/wallets", { recursive: true }).catch(() => {});
  await Deno.mkdir("./tests/wallets", { recursive: true });

  const tags = await getMoneroCTags();
  const latestTag = tags[0];
  await Promise.all([prepareMoneroC(coin, "next"), await prepareMoneroC(coin, latestTag), prepareCli(coin)]);

  await t.step("Simple (next, latest, next)", async () => {
    const walletInfo = await createWalletViaCli(coin, "dog", "sobaka");

    for (const version of ["next", latestTag, "next"]) {
      await $`deno run -A ./tests/compare.ts ${coin} ${version} ${JSON.stringify(walletInfo)}`;
    }
  });

  await Deno.remove("./tests/wallets", { recursive: true }).catch(() => {});
});
