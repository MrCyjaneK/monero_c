import { CoinsInfo, type CoinsInfoPtr } from "./coinsInfo.ts";
import { getSymbol, type Sanitizer } from "./utils.ts";

export type CoinsPtr = Deno.PointerObject<"coins">;

export class Coins {
  #coinsPtr: CoinsPtr;
  sanitizer?: Sanitizer;

  constructor(coinsPtr: CoinsPtr, sanitizer?: Sanitizer) {
    this.#coinsPtr = coinsPtr;
    this.sanitizer = sanitizer;
  }

  async count(): Promise<number> {
    return await getSymbol("Coins_count")(this.#coinsPtr);
  }

  async coin(index: number): Promise<CoinsInfo | null> {
    const coinPtr = await getSymbol("Coins_coin")(this.#coinsPtr, index);
    if (!coinPtr) return null;
    return new CoinsInfo(coinPtr as CoinsInfoPtr, this.sanitizer);
  }

  async setFrozen(index: number) {
    return await getSymbol("Coins_setFrozen")(this.#coinsPtr, index);
  }

  async thaw(index: number) {
    return await getSymbol("Coins_thaw")(this.#coinsPtr, index);
  }

  async getAllSize(): Promise<number> {
    return await getSymbol("Coins_getAll_size")(this.#coinsPtr);
  }

  async getAllByIndex(index: number): Promise<unknown> {
    return await getSymbol("Coins_getAll_byIndex")(this.#coinsPtr, index);
  }

  async refresh(): Promise<void> {
    return await getSymbol("Coins_refresh")(this.#coinsPtr);
  }
}
