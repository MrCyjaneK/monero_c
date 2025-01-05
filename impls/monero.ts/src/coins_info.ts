import { fns } from "./bindings.ts";
import { readCString } from "./utils.ts";

export type CoinsInfoPtr = Deno.PointerObject<"coinsInfo">;

export class CoinsInfo {
  #ptr: CoinsInfoPtr;

  #hash!: string | null;
  #keyImage!: string | null;
  #blockHeight!: bigint;
  #amount!: bigint;
  #spent!: boolean;
  #spentHeight!: bigint;
  #frozen!: boolean;
  #unlocked!: boolean;

  constructor(ptr: CoinsInfoPtr) {
    this.#ptr = ptr;
  }

  getPointer(): CoinsInfoPtr {
    return this.#ptr;
  }

  static async new(ptr: CoinsInfoPtr): Promise<CoinsInfo> {
    const instance = new CoinsInfo(ptr);
    await instance.refresh();
    return instance;
  }

  async refresh() {
    const [hash, keyImage, blockHeight, amount, spent, spentHeight, frozen, unlocked] = await Promise.all([
      fns.CoinsInfo_hash(this.#ptr).then(readCString),
      fns.CoinsInfo_keyImage(this.#ptr).then(readCString),
      fns.CoinsInfo_blockHeight(this.#ptr),
      fns.CoinsInfo_amount(this.#ptr),
      fns.CoinsInfo_spent(this.#ptr),
      fns.CoinsInfo_spentHeight(this.#ptr),
      fns.CoinsInfo_frozen(this.#ptr),
      fns.CoinsInfo_unlocked(this.#ptr),
    ]);

    this.#hash = hash;
    this.#keyImage = keyImage;
    this.#blockHeight = blockHeight;
    this.#amount = amount;
    this.#spent = spent;
    this.#spentHeight = spentHeight;
    this.#frozen = frozen;
    this.#unlocked = unlocked;
  }

  get hash(): string | null {
    return this.#hash;
  }

  get keyImage(): string | null {
    return this.#keyImage;
  }

  get blockHeight(): bigint {
    return this.#blockHeight;
  }

  get amount(): bigint {
    return this.#amount;
  }

  get spent(): boolean {
    return this.#spent;
  }

  get spentHeight(): bigint {
    return this.#spentHeight;
  }

  get frozen(): boolean {
    return this.#frozen;
  }

  get unlocked(): boolean {
    return this.#unlocked;
  }
}
