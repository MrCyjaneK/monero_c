import { dylib } from "../mod.ts";
import type { moneroSymbols, MoneroTsDylib, WowneroTsDylib } from "./symbols.ts";

export type Sanitizer = () => void | PromiseLike<void>;

const textEncoder = new TextEncoder();
export function CString(string: string): Deno.PointerValue<string> {
  return Deno.UnsafePointer.of(textEncoder.encode(`${string}\x00`));
}

type SymbolWithoutPrefix = keyof typeof moneroSymbols extends `MONERO_${infer DylibSymbol}` ? DylibSymbol : never;
export function getSymbol<S extends SymbolWithoutPrefix>(
  symbol: S,
): MoneroTsDylib["symbols"][`MONERO_${S}`] | WowneroTsDylib["symbols"][`WOWNERO_${S}`] {
  if ("MONERO_free" in dylib.symbols) {
    return dylib.symbols[`MONERO_${symbol}` as const];
  } else {
    return dylib.symbols[`WOWNERO_${symbol}` as const];
  }
}

/**
 * This method reads string from the given pointer and frees the string.
 *
 * SAFETY: Do not use readCString twice on the same pointer as it will cause double free\
 *          If you want to read CString without freeing it set the {@linkcode free} parameter to false
 */
export async function readCString(pointer: Deno.PointerObject, free?: boolean): Promise<string>;
export async function readCString(pointer: Deno.PointerValue, free?: boolean): Promise<string | null>;
export async function readCString(pointer: Deno.PointerValue, free = true): Promise<string | null> {
  if (!pointer) return null;
  const string = new Deno.UnsafePointerView(pointer).getCString();
  if (free) {
    await getSymbol("free")(pointer);
  }
  return string;
}
