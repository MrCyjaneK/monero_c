# airgap

Airgap allows you to create hardware wallet with a spare device that has a working camera.

## Implementations (URQR)

List of wallets that are compatible with URQR.

| View-Only                                                                                                | Offline                                                     |
|----------------------------------------------------------------------------------------------------------|-------------------------------------------------------------|
|                                                                                                          | [Feather Wallet](https://featherwallet.org)                 |
| [NERO](https://anonero.io)                                                                               | [NERO](https://anonero.io)                                  | 
| [xmruw](https://github.com/mrcyjanek/unnamed_monero_wallet)                                              | [xmruw](https://github.com/mrcyjanek/unnamed_monero_wallet) |
| [CakeWallet](https://cakewallet.com/) (WIP: [#1535](https://github.com/cake-tech/cake_wallet/pull/1535)) |                                                             |

## Usage

There are two ways to utilize airgap, over files and over UR, both options are more or less the same, but instead of
calling `<function>UR` you call `<function>`, and instead of file path you pass `\n` separated scanned QR codes.


## The flow

There are 2 devices, online and airgap, airgap device should never connect to internet, while view-only device can be
considered insecure as it can't spend funds without the airgap wallet signing the transaction.

### Wallet creation (airgap)

- Device: airgap

Create wallet normally, as you do, from polyseed, keys or whatever you want, when calling Wallet_init() function do not
pass daemon_address (pass just empty string).

As for now the wallet is offline without any balance inside, this is expected, airgap wallet can create QR code restore,
that encodes following data:

```json
{
  "version": 0,
  "primaryAddress": "Wallet_address(accountIndex: 0,addressIndex: 0)",
  "privateViewKey": "Wallet_secretViewKey()",
  "restoreHeight": "Wallet_getRefreshFromBlockHeight()"
}
```

### Wallet creation (online)

- Device: online

Online wallet can be restored from the data that offline wallet created. Use `WalletManager_createWalletFromKeys`, in
spendKeyString just pass an empty string.

### Wallet syncing

You will notice that the balance is out of sync on both wallets (equal to zero on airgap and equal to the sum of all 
received coins, including change in online). In order to sync, and be able to spend you need to do the following

> TIP: For UR you can specify max_fragment_length, I keep it 130 as a sane default, but feel free to adjust that.

> NOTE: UR returns const char* while non-ur return void.

- `online`: Wallet_exportOutputs
  - NOTE: Importing may error out, in that case you need to export all, by passing `all` as true
- `airgap`: Wallet_importOutputs
- `airgap`: Wallet_exportKeyImages
  - NOTE: Importing may error out, in that case you need to export all, by passing `all` as true
- `online`: Wallet_importKeyImages

Congrats! Now your balance should be correct on both `airgap` and `online`.

### Spending

On `online` wallet create transaction using createTransaction or createTransactionMultDest, on the receiving pointer
call `PendingTransaction_commit` or `PendingTransaction_commitUR`

On `airgap` you can grab the transaction and use `Wallet_loadUnsignedTx` or `Wallet_loadUnsignedTxUR`, use
`UnsignedTransaction_{status,amount,fee,recipientAddress}` to verify the tx, if it is then call UnsignedTransaction_sign
or UnsignedTransaction_signUR.

On `online` use `Wallet_submitTransaction` or `MONERO_Wallet_submitTransactionUR`, it will submit the transaction to the
node.