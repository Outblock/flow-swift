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

    var i = 0
    for rawPublicKey in rawPublicKeys {
        keyList.add(
            PublicKey(
                publicKey: rawPublicKey.decodeHex(),
                signatureAlgorithm: SignatureAlgorithm(rawValue: signAlgos[i])!
            ),
            hashAlgorithm: HashAlgorithm(rawValue: hashAlgos[i])!,
            weight: weights[i]
        )
        i = i + 1
    }

    let signatureSet: [Crypto.KeyListSignature] = []

    var j = 0
    for signature in signatures {
        signatureSet.append(
            Crypto.KeyListSignature(
                keyIndex: j,
                signature: signature.decodeHex()
            )
        )
        j = j + 1
    }

    let signedData = message.decodeHex()

    return keyList.verify(
        signatureSet: signatureSet,
        signedData: signedData,
        domainSeparationTag: ""
    )
} 