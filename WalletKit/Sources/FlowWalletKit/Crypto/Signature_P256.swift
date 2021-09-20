import CryptoKit
import CryptoSwift
import Foundation

public class FlowSigner {
    public static func sign_P256(_ hash: Data, privateKey: Data) -> Data {
        let privateKey256 = try! P256.Signing.PrivateKey(rawRepresentation: privateKey)

        var fakeDigest = SHA256.hash(data: Data("42".bytes))
        withUnsafeMutableBytes(of: &fakeDigest) { pointerBuffer in
            for i in 0 ..< pointerBuffer.count {
                pointerBuffer[i] = hash.bytes[i]
            }
        }
        let signature = try! privateKey256.signature(for: fakeDigest)
        return signature.rawRepresentation
    }

    public static func signData(_ data: Data, privateKey: Data, signatureAlgorithm: FlowSignatureAlgorithm, hashAlgorithm: FlowHashAlgorithm) -> Data {
        var hash: Data

        switch hashAlgorithm {
        case FlowHashAlgorithm.SHA2_256:
            hash = Data(SHA256.hash(data: data))
        case FlowHashAlgorithm.SHA3_256:
            let sha3 = CryptoSwift.SHA3(variant: SHA3.Variant.sha256)
            hash = Data(sha3.calculate(for: data.bytes))
        }

        if signatureAlgorithm == FlowSignatureAlgorithm.ECDSA_secp256k1 {
            return sign_secp256k1(hash, privateKey: privateKey)
        } else {
            return sign_P256(hash, privateKey: privateKey)
        }
    }
}
