import Foundation

public protocol FlowKeyChainProtocol {
    func addKey(address: FlowAddress, key: FlowKey) throws
    func removeKey(address: FlowAddress, key: FlowKey)
    func getKeyGroup(address: FlowAddress) throws -> KeyGroup
    func signData(signerIndex: Int, address: FlowAddress, payload: Data) throws -> FlowTransactionSignature
}

public struct KeyGroup: Codable {
    public var keys: [FlowKey] = [FlowKey]()

    public mutating func remove(_ key: FlowKey) {
        for i in 0 ..< keys.count {
            if keys[i].address == key.address, keys[i].keyId == key.keyId {
                keys.remove(at: i)
                return
            }
        }
    }
}

public class FlowKey: FlowEntity, Codable {
    public var address: String
    public var keyId: Int
    public var key: String
    public var signingAlgorithm: FlowSignatureAlgorithm
    public var hashAlgorithm: FlowHashAlgorithm

    public init(address: FlowAddress, keyId: Int, key: String, signingAlgorithm: FlowSignatureAlgorithm, hashAlgorithm: FlowHashAlgorithm) {
        self.address = address.hex
        self.keyId = keyId
        self.key = key
        self.signingAlgorithm = signingAlgorithm
        self.hashAlgorithm = hashAlgorithm
    }

    public var uid: String {
        return String(format: "%@_%@", address, keyId)
    }
}
