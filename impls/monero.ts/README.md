# monero.ts

`monero_c` bindings for Deno.

## Usage

This library does not ship with `monero_c` libraries.\
To use these bindings you have to bring your own `monero_c` libraries.\
There are at least two ways to do so:

- Ahead-of-time, during builds where you only ship necessary library for a given platform.\
  See [monero-tui](https://github.com/Im-Beast/monero-tui/blob/main/.github/workflows/dev-build.yml) build workflow as
  an example of doing so.
  ```ts
  import {
    loadMoneroDylib,
    Wallet,
    WalletManager,
  } from "https://raw.githubusercontent.com/MrCyjaneK/monero_c/master/impls/monero.ts/mod.ts";

  // Try to load dylib from the default lib/* path
  // You can also use loadWowneroDylib for Wownero
  loadMoneroDylib();

  const wm = await WalletManager.new();
  const wallet = await wm.createWallet("./my_wallet", "password");

  console.log(await wallet.address());

  await wallet.store();
  ```
- Just-in-time, where you download and cache the library at runtime.\
  You can use something like [plug](https://jsr.io/@denosaurs/plug) to achieve the result.
  ```ts
  import { dlopen } from "jsr:@denosaurs/plug";
  // It's recommened to put the monero.ts github link into your import_map to reduce the url clutter
  import { loadMoneroDylib, symbols, Wallet, WalletManager } from "https://raw.githubusercontent.com/MrCyjaneK/monero_c/master/impls/monero.ts/mod.ts";

  // Load dylib loaded by plug
  const lib = await dlopen(..., symbols);
  loadMoneroDylib(lib);

  const wm = await WalletManager.new();
  const wallet = await wm.createWallet("./my_wallet", "password");

  console.log(await wallet.address());

  await wallet.store();
  ```
