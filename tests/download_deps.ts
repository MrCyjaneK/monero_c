import { join, resolve } from "jsr:@std/path";
import { getMoneroCTags } from "./utils.ts";

export type Target = `${typeof Deno["build"]["os"]}_${typeof Deno["build"]["arch"]}`;

export const target = (() => {
  let target: Target = `${Deno.build.os}_${Deno.build.arch}`;
  const FORCED_TARGET = Deno.env.get("FORCED_TARGET");
  if (FORCED_TARGET) target = FORCED_TARGET as Target;
  return target;
})();

interface FileInfo {
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

export function getFileInfo(downloadInfo: DownloadInfo): FileInfo {
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

const outDir = "./tests/dependencies";
export async function downloadDependencies(...infos: DownloadInfo[]): Promise<void> {
  try {
    await Deno.mkdir(outDir, { recursive: true });
  } catch (error) {
    if (!(error instanceof Deno.errors.AlreadyExists)) {
      throw error;
    }
  }

  for (const info of infos) {
    const fileInfo = getFileInfo(info);
    const fileName = fileInfo.name;
    const filePath = join(outDir, info.outDir ?? "", fileName);

    try {
      await Deno.stat(filePath);
      console.log(`File ${fileName} already exists, skipping`);
      continue;
    } catch { /**/ }

    let buffer: Uint8Array | undefined;

    for (const mirror of info.mirrors) {
      const url = `${mirror}/${fileName}`;

      const response = await fetch(url);
      if (!response.ok) {
        console.warn(`Could not reach file ${fileName} on mirror: ${mirror}`);
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
    linux_x86_64: {
      name: "wownero-x86_64-linux-gnu-59db3fe8d.tar.bz2",
      sha256: "03880967c70cc86558d962b8a281868c3934238ea457a36174ba72b99d70107e",
    },
    darwin_aarch64: {
      name: "wownero-aarch64-apple-darwin11-59db3fe8d.tar.bz2",
      sha256: "25ff454a92b1cf036df5f28cdd2c63dcaf4b03da7da9403087371f868827c957",
    },
    windows_x86_64: {
      name: "wownero-x86_64-w64-mingw32-59db3fe8d.zip",
      sha256: "7e0ed84afa51e3b403d635c706042859094eb6850de21c9e82cb0a104425510e",
    },
  },
};

export const moneroCliInfo: DownloadInfo = {
  mirrors: [
    "https://static.mrcyjanek.net/monero_c/",
    "https://downloads.getmonero.org/cli/",
  ],
  file: {
    linux_x86_64: {
      name: "monero-linux-x64-v0.18.3.4.tar.bz2",
      sha256: "51ba03928d189c1c11b5379cab17dd9ae8d2230056dc05c872d0f8dba4a87f1d",
    },
    darwin_aarch64: {
      name: "monero-mac-armv8-v0.18.3.4.tar.bz2",
      sha256: "44520cb3a05c2518ca9aeae1b2e3080fe2bba1e3596d014ceff1090dfcba8ab4",
    },
    windows_x86_64: {
      name: "monero-win-x64-v0.18.3.4.zip",
      sha256: "54a66db6c892b2a0999754841f4ca68511741b88ea3ab20c7cd504a027f465f5",
    },
  },
};

export const moneroCInfos: DownloadInfo[] = [];
for (const tag of await getMoneroCTags()) {
  for (const coin of ["monero", "wownero"]) {
    moneroCInfos.push({
      mirrors: [
        `https://static.mrcyjanek.net/monero_c/libs/${tag}/`,
        `https://github.com/MrCyjaneK/monero_c/releases/download/${tag}/`,
      ],
      file: {
        linux_x86_64: { name: `${coin}_x86_64-linux-gnu_libwallet2_api_c.so.xz` },
        darwin_aarch64: { name: `${coin}_aarch64-apple-darwin11_libwallet2_api_c.dylib.xz` },
        windows_x86_64: { name: `${coin}_x86_64-w64-mingw32_libwallet2_api_c.dll.xz` },
      },
      outDir: `libs/${tag}`,
    });
  }
}

if (import.meta.main) {
  downloadDependencies(moneroCliInfo, wowneroCliInfo, ...moneroCInfos);
}
