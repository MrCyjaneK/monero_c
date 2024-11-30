import { type MoneroSymbols, moneroSymbols, type SymbolName, type WowneroSymbols, wowneroSymbols } from "./symbols.ts";

export type MoneroDylib = Deno.DynamicLibrary<MoneroSymbols>;
export type WowneroDylib = Deno.DynamicLibrary<WowneroSymbols>;
export type Dylib = MoneroDylib | WowneroDylib;

export let dylib: Dylib;

let dylibPrefix = "MONERO";
export const fns = new Proxy({} as { [K in SymbolName]: MoneroDylib["symbols"][`MONERO_${K}`] }, {
  get(_, symbolName: SymbolName) {
    return dylib.symbols[`${dylibPrefix}_${symbolName}` as keyof Dylib["symbols"]];
  },
});

export function loadMoneroDylib(newDylib?: MoneroDylib) {
  dylibPrefix = "MONERO";

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

export function loadWowneroDylib(newDylib?: WowneroDylib) {
  dylibPrefix = "WOWNERO";

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
