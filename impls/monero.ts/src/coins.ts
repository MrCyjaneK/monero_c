import { CoinsInfo, type CoinsInfoPtr } from "./coins_info.ts";
import { fns } from "./bindings.ts";

export type CoinsPtr = Deno.PointerObject<"coins">;

export class Coins {
  #ptr: CoinsPtr;

  #coins: CoinsInfo[] = [];

  constructor(ptr: CoinsPtr) {
    this.#ptr = ptr;
  }

  async count(): Promise<number> {
    return await fns.Coins_count(this.#ptr);
  }

  async coin(index: number): Promise<CoinsInfo | null> {
    if (this.#coins[index]) {
      return this.#coins[index];
    }

    const coinPtr = await fns.Coins_coin(this.#ptr, index);
    if (!coinPtr) return null;

    return CoinsInfo.new(coinPtr as CoinsInfoPtr);
  }

  async setFrozen(index: number) {
    return await fns.Coins_setFrozen(this.#ptr, index);
  }

  async thaw(index: number) {
    return await fns.Coins_thaw(this.#ptr, index);
  }

  async getAllSize(): Promise<number> {
    return await fns.Coins_getAll_size(this.#ptr);
  }

  async getAllByIndex(index: number): Promise<unknown> {
    return await fns.Coins_getAll_byIndex(this.#ptr, index);
  }

  async refresh(): Promise<void> {
    await fns.Coins_refresh(this.#ptr);

    for (const coin of this.#coins) {
      coin.refresh();
    }
  }
}
