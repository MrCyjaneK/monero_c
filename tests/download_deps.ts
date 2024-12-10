import { join, resolve } from "jsr:@std/path";
import { Coin, getMoneroCTags } from "./utils.ts";

export type Target = `${typeof Deno["build"]["os"]}_${typeof Deno["build"]["arch"]}`;

interface FileInfo {
  overrideMirrors?: string[];
  name: string;
  sha256?: string;
}

interface DownloadInfo {
  mirrors: string[];
  file:
    | FileInfo
    | { [os in Target]?: FileInfo };
  outDir?: string;
}

export function getFileInfo(
  downloadInfo: DownloadInfo,
  target: Target = `${Deno.build.os}_${Deno.build.arch}`,
): FileInfo {
  const fileInfo = "name" in downloadInfo.file ? downloadInfo.file : downloadInfo.file[target];
  if (!fileInfo) {
    throw new Error(`No fileInfo set for target: ${target}`);
  }
  return fileInfo;
}

async function sha256(buffer: Uint8Array): Promise<string> {
  const hashed = new Uint8Array(await crypto.subtle.digest("SHA-256", buffer));
  return Array.from(hashed).map((i) => i.toString(16).padStart(2, "0")).join("");
}

export async function downloadDependencies(...infos: DownloadInfo[]): Promise<void> {
  return await downloadFiles("./tests/dependencies", `${Deno.build.os}_${Deno.build.arch}`, ...infos);
}

export async function downloadFiles(outDir: string, target: Target, ...infos: DownloadInfo[]): Promise<void> {
  try {
    await Deno.mkdir(outDir, { recursive: true });
  } catch (error) {
    if (!(error instanceof Deno.errors.AlreadyExists)) {
      throw error;
    }
  }

  for (const info of infos) {
    const fileInfo = getFileInfo(info, target);
    const fileName = fileInfo.name;
    const filePath = join(outDir, info.outDir ?? "", fileName);

    file_might_exist: try {
      const fileBuffer = await Deno.readFile(filePath);

      // File exists, make sure checksum matches
      if (fileInfo.sha256) {
        const fileChecksum = await sha256(fileBuffer);
        if (fileChecksum !== fileInfo.sha256) {
          console.log(
            `File ${fileName} already exists, but checksum is mismatched (${fileChecksum} != ${fileInfo.sha256}), redownloading`,
          );
          await Deno.remove(filePath);
          break file_might_exist;
        }
      }

      console.log(`File ${fileName} already exists, skipping`);
      continue;
    } catch { /**/ }

    let buffer: Uint8Array | undefined;

    for (const mirror of fileInfo.overrideMirrors ?? info.mirrors) {
      const url = `${mirror}/${fileName}`;

      const response = await fetch(url);
      if (!response.ok) {
        console.warn(`Could not reach file ${fileName} on mirror: ${mirror}`);
        await response.body?.cancel();
        continue;
      }

      const responseBuffer = await response.bytes();

      if (fileInfo.sha256) {
        const responseChecksum = await sha256(responseBuffer);
        if (responseChecksum !== fileInfo.sha256) {
          console.warn(
            `Checksum mismatch on file ${fileName} on mirror: ${mirror} (${responseChecksum} != ${fileInfo.sha256})`,
          );
          continue;
        }
      }

      buffer = responseBuffer;
    }

    if (!buffer) {
      throw new Error(`None of the mirrors for ${fileName} are available`);
    }

    await Deno.mkdir(resolve(filePath, ".."), {
      recursive: true,
    }).catch(() => {});

    await Deno.writeFile(filePath, buffer);
    console.info("Downloaded file", fileInfo.name);
  }
}

export const wowneroCliInfo: DownloadInfo = {
  mirrors: [
    "https://static.mrcyjanek.net/monero_c/",
    "https://codeberg.org/wownero/wownero/releases/download/v0.11.2.0/",
  ],
  file: {
    linux_aarch64: {
      name: "wownero-aarch64-linux-gnu-59db3fe8d.tar.bz2",
      sha256: "07ce678302c07a6e79d90be65cbda243d843d414fbadb30f972d6c226575cfa7",
    },
    linux_x86_64: {
      name: "wownero-x86_64-linux-gnu-59db3fe8d.tar.bz2",
      sha256: "03880967c70cc86558d962b8a281868c3934238ea457a36174ba72b99d70107e",
    },

    darwin_aarch64: {
      name: "wownero-aarch64-apple-darwin11-59db3fe8d.tar.bz2",
      sha256: "25ff454a92b1cf036df5f28cdd2c63dcaf4b03da7da9403087371f868827c957",
    },
    darwin_x86_64: {
      name: "wownero-x86_64-apple-darwin11-59db3fe8d.tar.bz2",
      sha256: "7e9b6a84a560ed7a9ed7117c6f07fb228d77a06afac863d0ea1dbf833c4eddf6",
    },

    windows_x86_64: {
      name: "wownero-x86_64-w64-mingw32-59db3fe8d.zip",
      sha256: "7e0ed84afa51e3b403d635c706042859094eb6850de21c9e82cb0a104425510e",
    },

    android_aarch64: {
      overrideMirrors: [
        "https://static.mrcyjanek.net/monero_c/",
        "https://codeberg.org/wownero/wownero/releases/download/v0.11.1.0/",
      ],
      name: "wownero-aarch64-linux-android-v0.11.1.0.tar.bz2",
      sha256: "236188f8d8e7fad2ff35973f8c2417afffa8855d1a57b4c682fff5b199ea40f5",
    },
  },
};

export const moneroCliInfo: DownloadInfo = {
  mirrors: [
    "https://static.mrcyjanek.net/monero_c/",
    "https://downloads.getmonero.org/cli/",
  ],
  file: {
    linux_aarch64: {
      name: "monero-linux-armv8-v0.18.3.4.tar.bz2",
      sha256: "33ca2f0055529d225b61314c56370e35606b40edad61c91c859f873ed67a1ea7",
    },
    linux_x86_64: {
      name: "monero-linux-x64-v0.18.3.4.tar.bz2",
      sha256: "51ba03928d189c1c11b5379cab17dd9ae8d2230056dc05c872d0f8dba4a87f1d",
    },

    darwin_aarch64: {
      name: "monero-mac-armv8-v0.18.3.4.tar.bz2",
      sha256: "44520cb3a05c2518ca9aeae1b2e3080fe2bba1e3596d014ceff1090dfcba8ab4",
    },
    darwin_x86_64: {
      name: "monero-mac-x64-v0.18.3.4.tar.bz2",
      sha256: "32c449f562216d3d83154e708471236d07db7477d6b67f1936a0a85a5005f2b8",
    },

    windows_x86_64: {
      name: "monero-win-x64-v0.18.3.4.zip",
      sha256: "54a66db6c892b2a0999754841f4ca68511741b88ea3ab20c7cd504a027f465f5",
    },

    android_aarch64: {
      name: "monero-android-armv8-v0.18.3.4.tar.bz2",
      sha256: "d9c9249d1408822ce36b346c6b9fb6b896cda16714d62117fb1c588a5201763c",
    },
  },
};

export const dylibInfos: Record<Coin, DownloadInfo[]> = {
  monero: [],
  wownero: [],
};

for (const tag of await getMoneroCTags()) {
  for (const coin of ["monero", "wownero"] as const) {
    dylibInfos[coin].push({
      mirrors: [
        `https://static.mrcyjanek.net/monero_c/libs/${tag}/`,
        `https://github.com/MrCyjaneK/monero_c/releases/download/${tag}/`,
      ],
      file: {
        linux_aarch64: { name: `${coin}_aarch64-linux-gnu_libwallet2_api_c.so.xz` },
        linux_x86_64: { name: `${coin}_x86_64-linux-gnu_libwallet2_api_c.so.xz` },
        darwin_aarch64: { name: `${coin}_aarch64-apple-darwin11_libwallet2_api_c.dylib.xz` },
        darwin_x86_64: { name: `${coin}_x86_64-apple-darwin11_libwallet2_api_c.dylib.xz` },
        windows_x86_64: { name: `${coin}_x86_64-w64-mingw32_libwallet2_api_c.dll.xz` },
        android_aarch64: { name: `${coin}_aarch64-linux-android_libwallet2_api_c.so.xz` },
      },
      outDir: `libs/${tag}`,
    });
  }
}

// Download files to the monero_c folder
// (used on mirror to keep files up to date)
if (import.meta.main) {
  const supportedTargets: Target[] = [
    "linux_x86_64",
    "linux_aarch64",
    "darwin_x86_64",
    "darwin_aarch64",
    "windows_x86_64",
    "android_aarch64",
  ];

  for (const target of supportedTargets) {
    await downloadFiles("./monero_c", target, moneroCliInfo, wowneroCliInfo, ...Object.values(dylibInfos).flat());
  }
}
