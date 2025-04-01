transaction(name: String) {
    prepare(signer: auth(Storage, Contracts) &Account) {
        signer.contracts.remove(name: name)
    }
} 