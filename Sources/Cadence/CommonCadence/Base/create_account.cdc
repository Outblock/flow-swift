import Crypto

transaction(publicKey: String, signatureAlgorithm: UInt8, hashAlgorithm: UInt8, weight: UFix64, contracts: {String: String}) {
    prepare(signer: auth(Storage, CreateAccount, Keys, Contracts) &Account) {
        let key = PublicKey(
            publicKey: publicKey.decodeHex(),
            signatureAlgorithm: SignatureAlgorithm(rawValue: signatureAlgorithm)!
        )
        let account = Account.create(payer: signer)
        account.keys.add(
            publicKey: key,
            hashAlgorithm: HashAlgorithm(rawValue: hashAlgorithm)!,
            weight: weight
        )

        for contract in contracts.keys {
            account.contracts.add(name: contract, code: contracts[contract]!.decodeHex())
        }
    }
} 