import { moneroChecksum } from "./checksum_monero.ts";
import { readCString } from "./src/utils.ts";
import { fns, loadMoneroDylib } from "./src/bindings.ts";

loadMoneroDylib();

export class ChecksumError extends Error {
  readonly code: number;
  readonly errors: string[];

  constructor(code: number, errors: string[]) {
    super("MoneroC binding checksum failed:\n" + errors.join("\n"));
    this.code = code;
    this.errors = errors;
  }
}

/**
 * Validates MoneroC checksums
 * @returns {null} if checksums are correct
 * @returns {ChecksumError} which contains information about why checksum failed
 */
export async function validateChecksum(): Promise<ChecksumError | null> {
  const cppHeaderHash = await readCString(await fns.checksum_wallet2_api_c_h!(), false);
  const tsHeaderHash = moneroChecksum.wallet2_api_c_h_sha256;

  const errors: string[] = [];

  let errorCode = 0;
  if (cppHeaderHash !== tsHeaderHash) {
    errors.push("ERR: Header file check mismatch");
    errorCode++;
  }

  const cppSourceHash = await readCString(await fns.checksum_wallet2_api_c_cpp!(), false);
  const tsSourceHash = moneroChecksum.wallet2_api_c_cpp_sha256;
  if (cppSourceHash !== tsSourceHash) {
    errors.push(`ERR: CPP source file check mismatch ${cppSourceHash} == ${tsSourceHash}`);
    errorCode++;
  }

  const cppExportHash = await readCString(await fns.checksum_wallet2_api_c_exp!(), false);
  const tsExportHash = moneroChecksum.wallet2_api_c_exp_sha256;
  if (cppExportHash !== tsExportHash) {
    if (Deno.build.os !== "darwin") {
      errors.push("WARN: EXP source file check mismatch");
    } else {
      errors.push(`ERR: EXP source file check mismatch ${cppExportHash} == ${tsExportHash}`);
    }
    errorCode++;
  }

  if (errorCode) {
    return new ChecksumError(errorCode, errors);
  }

  return null;
}

if (import.meta.main) {
  const maybeError = await validateChecksum();
  if (maybeError) {
    throw maybeError;
  }
}
