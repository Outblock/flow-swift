import CryptoSwift
import Foundation
import secp256k1

extension FlowSigner {
    public static func sign_secp256k1(_ hash: Data, privateKey: Data) -> Data {
        let privateKeyBytes = privateKey.bytes
        let privatekeySecp256k1 = try! secp256k1.Signing.PrivateKey(rawRepresentation: privateKeyBytes)

        print(String(byteArray: privatekeySecp256k1.publicKey.rawRepresentation))

        var fakeDigest = SHA256.hash(data: Data("42".bytes))
        withUnsafeMutableBytes(of: &fakeDigest) { pointerBuffer in
            for i in 0 ..< pointerBuffer.count {
                pointerBuffer[i] = hash.bytes[i]
            }
        }

        let signature = try! privatekeySecp256k1.signature(for: fakeDigest)
        print(signature.rawRepresentation)
        return signature.rawRepresentation
    }
}
