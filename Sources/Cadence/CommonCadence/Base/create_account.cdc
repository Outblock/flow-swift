// create_account.cdc

import Crypto

transaction(
    publicKey: String,
    signatureAlgorithm: UInt8,
    hashAlgorithm: UInt8,
    weight: UFix64,
    contracts: {String: String}
) {
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

        for contractName in contracts.keys {
            let codeHex = contracts[contractName]!
            account.contracts.add(
                name: contractName,
                code: codeHex.decodeHex()
            )
        }
    }
}
