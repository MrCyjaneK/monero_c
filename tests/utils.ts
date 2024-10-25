import { build$, CommandBuilder } from "jsr:@david/dax";

export const $ = build$({
  commandBuilder: new CommandBuilder()
    .printCommand(true)
    .stdin("inherit")
    .stdout("inherit")
    .stderr("inherit"),
});

type Coin = "monero" | "wownero";

export async function downloadMoneroCli() {
  const MONERO_CLI_FILE_NAME = "monero-linux-x64-v0.18.3.4";
  const MONERO_WALLET_CLI_URL = `https://downloads.getmonero.org/cli/${MONERO_CLI_FILE_NAME}.tar.bz2`;

  await $`wget -q -o /dev/null ${MONERO_WALLET_CLI_URL}`;
  await $
    .raw`tar -xf ${MONERO_CLI_FILE_NAME}.tar.bz2 --one-top-level=monero-cli --strip-components=1 -C tests`;
  await $.raw`rm ${MONERO_CLI_FILE_NAME}.tar.bz2`;
}

export async function downloadWowneroCli() {
  const WOWNERO_CLI_FILE_NAME = "wownero-x86_64-linux-gnu-59db3fe8d";
  const WOWNERO_WALLET_CLI_URL =
    `https://codeberg.org/wownero/wownero/releases/download/v0.11.2.0/wownero-x86_64-linux-gnu-59db3fe8d.tar.bz2`;

  await $`wget -q -o /dev/null ${WOWNERO_WALLET_CLI_URL}`;
  await $
    .raw`tar -xf ${WOWNERO_CLI_FILE_NAME}.tar.bz2 --one-top-level=wownero-cli --strip-components=1 -C tests`;
  await $.raw`rm ${WOWNERO_CLI_FILE_NAME}.tar.bz2`;
}

export function downloadCli(coin: Coin) {
  if (coin === "wownero") {
    return downloadWowneroCli();
  }
  return downloadMoneroCli();
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
  coin: Coin,
  name: string,
  password: string,
): Promise<WalletInfo> {
  const path = `./tests/wallets/${name}`;
  const cliPath = `./tests/${coin}-cli/${coin}-wallet-cli`;

  await $
    .raw`${cliPath} --generate-new-wallet ${path} --password ${password} --mnemonic-language English --command exit`
    .stdout("null");

  const address = (await $.raw`${cliPath} --wallet-file ${path} --password ${password} --command address`
    .stdinText(`${password}\n`)
    .lines())
    .at(-1)!
    .split(/\s+/)[1];

  const retrieveKeys = (lines: string[]) =>
    lines.slice(-2)
      .map((line) => line.split(": ")[1]);

  const [secretSpendKey, publicSpendKey] = retrieveKeys(
    await $.raw`${cliPath} --wallet-file ${path} --password ${password} --command spendkey`
      .stdinText(`${password}\n`)
      .lines(),
  );

  const [secretViewKey, publicViewKey] = retrieveKeys(
    await $.raw`${cliPath} --wallet-file ${path} --password ${password} --command viewkey`
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
export async function getMoneroC(coin: Coin, version: MoneroCVersion) {
  const dylibName = `${coin}_x86_64-linux-gnu_libwallet2_api_c.so`;
  const endpointDylibName = `${coin}_libwallet2_api_c.so`;
  const releaseDylibName = dylibName.slice(`${coin}_`.length);

  if (version === "next") {
    await $.raw`xz -kd release/${coin}/${releaseDylibName}.xz`;
    await $`mkdir -p tests/libs/next`;
    await $`mv release/${coin}/${releaseDylibName} tests/libs/next/${endpointDylibName}`;
  } else {
    const downloadUrl = `https://github.com/MrCyjaneK/monero_c/releases/download/${version}/${dylibName}.xz`;

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
