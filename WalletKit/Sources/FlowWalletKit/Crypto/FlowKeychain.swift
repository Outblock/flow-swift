import FlowFoundation
import Foundation

public protocol FlowKeyChainProtocol {
    func addKey(address: Flow.Address, key: FlowKey) throws
    func removeKey(address: Flow.Address, key: FlowKey)
    func getKeyGroup(address: Flow.Address) throws -> KeyGroup
    func signData(address: Flow.Address, payload: Data) throws -> Data
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

public struct FlowKey: Codable {
    public var address: String
    public var keyId: Int
    public var key: String
    public var signingAlgorithm: Flow.SignatureAlgorithm
    public var hashAlgorithm: Flow.HashAlgorithm

    public init(address: Flow.Address,
                keyId: Int,
                key: String,
                signingAlgorithm: Flow.SignatureAlgorithm,
                hashAlgorithm: Flow.HashAlgorithm) {
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
