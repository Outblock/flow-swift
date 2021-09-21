import FlowFoundation
import Foundation

public class MemoryKeychain: FlowKeyChainProtocol {
    public init() {}

    enum KeyChainError: Error {
        case accountNotFound
    }

    public var keys: [String: KeyGroup] = [:]

    public func addKey(address: Flow.Address, key: FlowKey) {
        if !keys.keys.contains(address.hex) {
            keys[address.hex] = KeyGroup()
        }
        keys[address.hex]!.keys.append(key)
    }

    public func removeKey(address: Flow.Address, key: FlowKey) {
        var group = keys[address.hex]!
        group.remove(key)
    }

    public func getKeyGroup(address: Flow.Address) throws -> KeyGroup {
        if !keys.keys.contains(address.hex) {
            throw KeyChainError.accountNotFound
        }
        return keys[address.hex]!
    }

    public func signData(address: Flow.Address, payload: Data) throws -> Data {
        guard let signerKey = try self.getKeyGroup(address: address).keys.first else {
            throw KeyChainError.accountNotFound
        }

        let signature = FlowSigner.signData(payload,
                                            privateKey: signerKey.key.data(using: .hexadecimal)!,
                                            signatureAlgorithm: signerKey.signingAlgorithm,
                                            hashAlgorithm: signerKey.hashAlgorithm)

        return signature
    }
}
