import { type Dylib, moneroSymbols, type MoneroTsDylib, wowneroSymbols, type WowneroTsDylib } from "./symbols.ts";

export let dylib: Dylib;

export function loadMoneroDylib(newDylib?: MoneroTsDylib) {
  if (newDylib) {
    dylib = newDylib;
    return;
  }

  let libPath: string;
  switch (Deno.build.os) {
    case "darwin":
      libPath = "./lib/monero_libwallet2_api_c.dylib";
      break;
    case "android":
      libPath = "./lib/libmonero_libwallet2_api_c.so";
      break;
    case "windows":
      libPath = "./lib/monero_libwallet2_api_c.dll";
      break;
    default:
      libPath = "./lib/monero_libwallet2_api_c.so";
      break;
  }

  dylib = Deno.dlopen(libPath, moneroSymbols);
}

export function loadWowneroDylib(newDylib?: WowneroTsDylib) {
  if (newDylib) {
    dylib = newDylib;
    return;
  }

  let libPath: string;
  switch (Deno.build.os) {
    case "darwin":
      libPath = "./lib/wownero_libwallet2_api_c.dylib";
      break;
    case "android":
      libPath = "./lib/libwownero_libwallet2_api_c.so";
      break;
    case "windows":
      libPath = "./lib/wownero_libwallet2_api_c.dll";
      break;
    default:
      libPath = "./lib/wownero_libwallet2_api_c.so";
      break;
  }

  dylib = Deno.dlopen(libPath, wowneroSymbols);
}
