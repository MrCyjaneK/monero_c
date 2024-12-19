import { build$, CommandBuilder } from "jsr:@david/dax";
import { dirname, join } from "jsr:@std/path";
import {
  downloadDependencies,
  dylibInfos,
  getFileInfo,
  moneroCliInfo,
  Target,
  wowneroCliInfo,
} from "./download_deps.ts";
import { loadMoneroDylib, loadWowneroDylib, moneroSymbols, wowneroSymbols } from "../impls/monero.ts/mod.ts";

export type Coin = "monero" | "wownero";

const target = `${Deno.build.os}_${Deno.build.arch}` as const;

export const $ = build$({
  commandBuilder: new CommandBuilder()
    .printCommand(true)
    .stdin("inherit")
    .stdout("inherit")
    .stderr("inherit"),
});

export const dylibNames: (coin: Coin) => Partial<Record<Target, string>> = (coin) => ({
  linux_x86_64: `${coin}_x86_64-linux-gnu_libwallet2_api_c.so`,
  darwin_aarch64: `${coin}_aarch64-apple-darwin11_libwallet2_api_c.dylib`,
  windows_x86_64: `${coin}_x86_64-w64-mingw32_libwallet2_api_c.dll`,
});

export const moneroTsDylibNames: (coin: Coin) => Partial<Record<Target, string>> = (coin) => ({
  linux_x86_64: `${coin}_libwallet2_api_c.so`,
  darwin_aarch64: `${coin}_aarch64-apple-darwin11_libwallet2_api_c.dylib`,
  windows_x86_64: `${coin}_libwallet2_api_c.dll`,
});

export function loadDylib(coin: Coin, version: MoneroCVersion) {
  const dylibName = moneroTsDylibNames(coin)[target]!;

  if (coin === "monero") {
    const dylib = Deno.dlopen(`tests/dependencies/libs/${version}/${dylibName}`, moneroSymbols);
    loadMoneroDylib(dylib);
    return dylib;
  } else {
    const dylib = Deno.dlopen(`tests/dependencies/libs/${version}/${dylibName}`, wowneroSymbols);
    loadWowneroDylib(dylib);
    return dylib;
  }
}

export async function extract(path: string, out: string) {
  const outDir = out.endsWith("/") ? out : dirname(out);
  await Deno.mkdir(outDir, { recursive: true });

  if (path.endsWith(".tar.bz2")) {
    let args = `-C ${dirname(out)}`;
    if (outDir === out) {
      args = `-C ${out} --strip-components=1`;
    }
    await $.raw`tar -xf ${path} ${args}`;
  } else if (path.endsWith(".zip")) {
    await $.raw`unzip ${path} -nu -d ${outDir}`;
  } else if (path.endsWith(".xz")) {
    await $.raw`xz -kd ${path}`;
    await Deno.rename(path.slice(0, -3), out);
  } else {
    throw new Error("Unsupported archive file for:" + path);
  }
}

export async function prepareMoneroCli() {
  await downloadDependencies(moneroCliInfo);
  const path = join("./tests/dependencies", moneroCliInfo.outDir ?? "", getFileInfo(moneroCliInfo).name);
  await extract(path, "./tests/dependencies/monero-cli/");
}

export async function prepareWowneroCli() {
  await downloadDependencies(wowneroCliInfo);
  const path = join("./tests/dependencies", wowneroCliInfo.outDir ?? "", getFileInfo(wowneroCliInfo).name);
  await extract(path, "./tests/dependencies/wownero-cli/");
}

export function prepareCli(coin: Coin) {
  if (coin === "wownero") {
    return prepareWowneroCli();
  }
  return prepareMoneroCli();
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
  const cliPath = `./tests/dependencies/${coin}-cli/${coin}-wallet-cli`;

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
  const response = await fetch("https://static.mrcyjanek.net/monero_c/release.php");

  if (!response.ok) {
    throw new Error(`Could not receive monero_c release tags: ${await response.text()}`);
  }

  const json = await response.json() as { tag_name: string }[];
  return json.map(({ tag_name }) => tag_name);
}

export async function prepareMoneroC(coin: Coin, version: MoneroCVersion) {
  const dylibName = dylibNames(coin)[target];
  const moneroTsDylibName = moneroTsDylibNames(coin)[target];

  if (!dylibName || !moneroTsDylibName) {
    throw new Error(`Missing dylib name value for target: ${target}`);
  }

  const releaseDylibName = dylibName.slice(`${coin}_`.length);

  if (version === "next") {
    await extract(
      `./release/${coin}/${releaseDylibName}.xz`,
      `./tests/dependencies/libs/next/${moneroTsDylibName}`,
    );
  } else {
    const downloadInfo = dylibInfos[coin].find((info) => info.outDir?.endsWith(version));
    if (downloadInfo) {
      await downloadDependencies(downloadInfo);
    }

    await extract(
      `./tests/dependencies/libs/${version}/${dylibName}.xz`,
      `./tests/dependencies/libs/${version}/${moneroTsDylibName}`,
    );
  }
}
