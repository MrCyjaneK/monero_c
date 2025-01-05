import { fns } from "./bindings.ts";

const textEncoder = new TextEncoder();
export const SEPARATOR = ",";
export const C_SEPARATOR = CString(SEPARATOR);

export function maybeMultipleStrings(input: string): string | string[];
export function maybeMultipleStrings(input: null | string): null | string | string[];
export function maybeMultipleStrings(input: null | string): null | string | string[] {
  if (!input) return null;
  const multiple = input.split(SEPARATOR);
  return multiple.length === 1 ? multiple[0] : multiple;
}

export function CString(string: string): Deno.PointerValue<string> {
  return Deno.UnsafePointer.of(textEncoder.encode(`${string}\x00`));
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
  if (string && free) await fns.free(pointer);
  return string;
}
