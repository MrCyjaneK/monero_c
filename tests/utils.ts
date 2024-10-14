import { build$, CommandBuilder } from "jsr:@david/dax";

export const $ = build$({
  commandBuilder: new CommandBuilder()
    .printCommand(true)
    .stdin("inherit")
    .stdout("inherit")
    .stderr("inherit"),
});

export async function downloadMoneroCli() {
  const MONERO_CLI_VERSION = "monero-linux-x64-v0.18.3.4";
  const MONERO_WALLET_CLI =
    `https://downloads.getmonero.org/cli/${MONERO_CLI_VERSION}.tar.bz2`;

  await $`wget ${MONERO_WALLET_CLI}`;
  await $
    .raw`tar -xvf ${MONERO_CLI_VERSION}.tar.bz2 --one-top-level=monero-cli --strip-components=1 -C tests`;
  await $.raw`rm ${MONERO_CLI_VERSION}.tar.bz2`;
}

interface WalletInfo {
  path: string;
  password: string;
  address: string;
  secretSpendKey: string;
  publicSpendKey: string;
  secretViewKey: string;
  publicViewKey: string;
}

export async function createWalletViaCli(
  name: string,
  password: string,
): Promise<WalletInfo> {
  const path = `./tests/wallets/${name}`;

  await $`./tests/monero-cli/monero-wallet-cli --generate-new-wallet ${path} --password ${password} --mnemonic-language English --command exit`
    .stdout("null");

  const address =
    (await $`./tests/monero-cli/monero-wallet-cli --wallet-file ${path} --password ${password} --command address`
      .stdinText(`${password}\n`)
      .lines())
      .at(-1)!
      .split(/\s+/)[1];

  const retrieveKeys = (lines: string[]) =>
    lines.slice(-2)
      .map((line) => line.split(": ")[1]);

  const [secretSpendKey, publicSpendKey] = retrieveKeys(
    await $`./tests/monero-cli/monero-wallet-cli --wallet-file ${path} --password ${password} --command spendkey`
      .stdinText(`${password}\n`)
      .lines(),
  );

  const [secretViewKey, publicViewKey] = retrieveKeys(
    await $`./tests/monero-cli/monero-wallet-cli --wallet-file ${path} --password ${password} --command viewkey`
      .stdinText(`${password}\n`)
      .lines(),
  );

  return {
    path,
    password,
    address,
    secretSpendKey,
    publicSpendKey,
    secretViewKey,
    publicViewKey,
  };
}

// deno-lint-ignore ban-types
export type MoneroCVersion = "next" | (string & {});

export async function getMoneroCTags(): Promise<string[]> {
  return ((
    await (await fetch(
      "https://api.github.com/repos/MrCyjanek/monero_c/releases",
    )).json()
  ) as { tag_name: string }[])
    .map(({ tag_name }) => tag_name);
}
export async function getMoneroC(version: MoneroCVersion) {
  const triple = "x86_64-linux-gnu";
  const dylibName = "monero_x86_64-linux-gnu_libwallet2_api_c.so";
  const endpointDylibName = "monero_libwallet2_api_c.so";
  const releaseDylibName = dylibName.slice("monero_".length);

  if (version === "next") {
    await $.raw`xz -kd release/monero/${releaseDylibName}.xz`;
    await $`mkdir -p tests/libs/next`;
    await $`mv release/monero/${releaseDylibName} tests/libs/next/${endpointDylibName}`;
  } else {
    const downloadUrl =
      `https://github.com/MrCyjaneK/monero_c/releases/download/${version}/${dylibName}.xz`;

    const file = await Deno.open(`./tests/${dylibName}.xz`, {
      create: true,
      write: true,
    });
    file.write(await (await fetch(downloadUrl)).bytes());
    file.close();

    await $.raw`xz -d ./tests/${dylibName}.xz`;
    await $.raw`mkdir -p ./tests/libs/${version}`;
    await $
      .raw`mv ./tests/${dylibName} ./tests/libs/${version}/${endpointDylibName}`;
  }
}
