import { $, createWalletViaCli, downloadMoneroCli, getMoneroC, getMoneroCTags } from "./utils.ts";

Deno.test("Regression tests", async (t) => {
  await Deno.remove("./tests/wallets", { recursive: true }).catch(() => {});
  await Deno.mkdir("./tests/wallets", { recursive: true });

  const tags = await getMoneroCTags();
  const latestTag = tags[0];
  await Promise.all([getMoneroC("next"), await getMoneroC(latestTag), downloadMoneroCli()]);

  await t.step("Simple (next, latest, next)", async () => {
    const walletInfo = await createWalletViaCli("dog", "sobaka");

    for (const version of ["next", latestTag, "next"]) {
      await $`deno run -A ./tests/compare.ts ${version} ${JSON.stringify(walletInfo)}`;
    }
  });

  await t.step("All releases sequentially (all tags in the release order, next)", async () => {
    tags.unshift("next");

    const walletInfo = await createWalletViaCli("cat", "koshka");

    for (const version of tags.toReversed()) {
      if (version !== "next" && version !== tags[0]) await getMoneroC(version);
      await $`deno run -A ./tests/compare.ts ${version} ${JSON.stringify(walletInfo)}`;
    }

    await Deno.remove("./tests/wallets", { recursive: true }).catch(() => {});
  });

  await Deno.remove("./tests/wallets", { recursive: true }).catch(() => {});
  await Deno.remove("./tests/libs", { recursive: true }).catch(() => {});
});
