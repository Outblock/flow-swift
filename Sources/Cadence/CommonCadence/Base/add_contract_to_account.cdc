// add_contract_to_account.cdc

transaction(name: String, code: String) {
    prepare(signer: auth(Storage, Contracts) &Account) {
        signer.contracts.add(
            name: name,
            code: code.decodeHex()
        )
    }
}
