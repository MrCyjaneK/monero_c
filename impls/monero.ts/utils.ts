const textEncoder = new TextEncoder();
export function CString(string: string): Deno.PointerValue<string> {
    return Deno.UnsafePointer.of(textEncoder.encode(`${string}\x00`));
}
