// remove_contract.cdc

transaction(name: String) {
    prepare(signer: auth(Contracts) &Account) {
        signer.contracts.remove(name: name)
    }
}
