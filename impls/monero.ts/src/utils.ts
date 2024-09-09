import { dylib } from "../mod.ts";

export type Sanitizer = () => void | PromiseLike<void>;

const textEncoder = new TextEncoder();
export function CString(string: string): Deno.PointerValue<string> {
  return Deno.UnsafePointer.of(textEncoder.encode(`${string}\x00`));
}

// This method reads string from the given pointer and frees the string
// SAFETY: Do not use readCString twice on the same pointer as it will cause double free
//         In that case just use `Deno.UnsafePointerView(ptr).getCString()` directly
export async function readCString(pointer: Deno.PointerObject): Promise<string>;
export async function readCString(pointer: Deno.PointerValue): Promise<string | null>;
export async function readCString(pointer: Deno.PointerValue): Promise<string | null> {
  if (!pointer) return null;
  const string = new Deno.UnsafePointerView(pointer).getCString();
  await dylib.symbols.MONERO_free(pointer);
  return string;
}
