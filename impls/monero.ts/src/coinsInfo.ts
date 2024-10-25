import { getSymbol, readCString, type Sanitizer } from "./utils.ts";

export type CoinsInfoPtr = Deno.PointerObject<"coinsInfo">;

export class CoinsInfo {
  #coinsInfoPtr: CoinsInfoPtr;
  sanitizer?: Sanitizer;

  constructor(coinsInfoPtr: CoinsInfoPtr, sanitizer?: Sanitizer) {
    this.#coinsInfoPtr = coinsInfoPtr;
    this.sanitizer = sanitizer;
  }

  async hash(): Promise<string | null> {
    return await readCString(await getSymbol("CoinsInfo_hash")(this.#coinsInfoPtr));
  }

  async keyImage(): Promise<string | null> {
    return await readCString(await getSymbol("CoinsInfo_keyImage")(this.#coinsInfoPtr));
  }

  async blockHeight(): Promise<bigint> {
    return await getSymbol("CoinsInfo_blockHeight")(this.#coinsInfoPtr);
  }

  async amount(): Promise<bigint> {
    return await getSymbol("CoinsInfo_amount")(this.#coinsInfoPtr);
  }

  async spent(): Promise<boolean> {
    return await getSymbol("CoinsInfo_spent")(this.#coinsInfoPtr);
  }

  async spentHeight(): Promise<bigint> {
    return await getSymbol("CoinsInfo_spentHeight")(this.#coinsInfoPtr);
  }

  async frozen(): Promise<boolean> {
    return await getSymbol("CoinsInfo_frozen")(this.#coinsInfoPtr);
  }

  async unlocked(): Promise<boolean> {
    return await getSymbol("CoinsInfo_unlocked")(this.#coinsInfoPtr);
  }
}
