export type Sanitizer = () => void | PromiseLike<void>;

const textEncoder = new TextEncoder();
export function CString(string: string): Deno.PointerValue<string> {
  return Deno.UnsafePointer.of(textEncoder.encode(`${string}\x00`));
}

export function readCString(pointer: Deno.PointerObject): string;
export function readCString(pointer: Deno.PointerValue): string | null;
export function readCString(pointer: Deno.PointerValue): string | null {
  if (!pointer) return null;
  return new Deno.UnsafePointerView(pointer).getCString();
}
