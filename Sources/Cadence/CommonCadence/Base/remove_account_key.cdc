// remove_account_key.cdc

transaction(keyIndex: Int) {
    prepare(signer: auth(Storage, Keys) &Account) {
        signer.keys.revoke(keyIndex: keyIndex)
    }
}
