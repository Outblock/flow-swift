import Foundation

public class AppleKeychain: FlowKeyChainProtocol {
    public init() {}

    enum KeyChainError: Error {
        case accountNotFound
    }

    public func addKey(address: FlowAddress, key: FlowKey) throws {
        assert(address.hex == key.address)

        var keyGroup = try getKeyGroup(address: address)

        for k in keyGroup.keys {
            if k.address == key.address, k.keyId == key.keyId {
                return
            }
        }
        keyGroup.keys.append(key)

        let data = try JSONEncoder().encode(keyGroup)
        let query = [
            kSecValueData: data,
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: "Flow Account Key",
            kSecAttrAccount: address.hex,
        ] as CFDictionary

        let status = SecItemAdd(query, nil)

        if status != errSecSuccess {
            print("Error: \(status)")
        }
    }

    public func removeKey(address _: FlowAddress, key _: FlowKey) {
        // self.keys[address.hex]?.remove(at: index)
    }

    public func getKeyGroup(address: FlowAddress) throws -> KeyGroup {
        let query = [
            kSecAttrService: "Flow Account Key",
            kSecAttrAccount: address.hex,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true,
        ] as CFDictionary

        var result: AnyObject?
        SecItemCopyMatching(query, &result)

        if result == nil {
            return KeyGroup()
        }
        do {
            let data = result as! Data
            let group = try JSONDecoder().decode(KeyGroup.self, from: data)
            return group
        } catch {
            print(error)
            return KeyGroup()
        }
    }

    public func signData(signerIndex: Int, address: FlowAddress, payload: Data) throws -> FlowTransactionSignature {
        guard let signerKey = try self.getKeyGroup(address: address).keys.first else {
            throw KeyChainError.accountNotFound
        }

        let signature = FlowSigner.signData(payload,
                                            privateKey: signerKey.key.data(using: .hexadecimal)!,
                                            signatureAlgorithm: signerKey.signingAlgorithm,
                                            hashAlgorithm: signerKey.hashAlgorithm)

        return FlowTransactionSignature(signerIndex: signerIndex, address: address, keyId: signerKey.keyId, signature: signature)
    }
}
