// verify_user_signature.cdc

import Crypto

access(all) fun main(
    message: String,
    rawPublicKeys: [String],
    weights: [UFix64],
    signAlgos: [UInt8],
    hashAlgos: [UInt8],
    signatures: [String]
): Bool {
    let keyList = Crypto.KeyList()

    for i, rawPublicKey in rawPublicKeys {
        keyList.add(
            PublicKey(
                publicKey: rawPublicKey.decodeHex(),
                signatureAlgorithm: SignatureAlgorithm(rawValue: signAlgos[i])!
            ),
            hashAlgorithm: HashAlgorithm(rawValue: hashAlgos[i])!,
            weight: weights[i]
        )
    }

    var signatureSet: [Crypto.KeyListSignature] = []

    for j, signature in signatures {
        signatureSet.append(
            Crypto.KeyListSignature(
                keyIndex: j,
                signature: signature.decodeHex()
            )
        )
    }

    let signedData = message.decodeHex()

    return keyList.verify(
        signatureSet: signatureSet,
        signedData: signedData,
        domainSeparationTag: "FLOW-V0.0-user"
    )
}
ADD_KEY_TO_ACCOUNT.CDC
// add_key_to_account.cdc

import Crypto

transaction(
    publicKey: String,
    signatureAlgorithm: UInt8,
    hashAlgorithm: UInt8,
    weight: UFix64
) {
    prepare(signer: auth(Keys) &Account) {
        let key = PublicKey(
            publicKey: publicKey.decodeHex(),
            signatureAlgorithm: SignatureAlgorithm(rawValue: signatureAlgorithm)!
        )
        signer.keys.add(
            publicKey: key,
            hashAlgorithm: HashAlgorithm(rawValue: hashAlgorithm)!,
            weight: weight
        )
    }
}
