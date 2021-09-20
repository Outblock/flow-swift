import Flow
import Foundation
import SwiftPrettyPrint
import SwiftProtobuf

public class FlowEntity: Equatable {
    public init() {}
    public typealias Element = FlowEntity
    public var pretty: String {
        var debug: String = ""
        Pretty.prettyPrintDebug(self, to: &debug)
        return debug
    }

    public func set(transform: @escaping ((Element) -> Void)) {
        transform(self)
    }

    public static func == (lhs: FlowEntity, rhs: FlowEntity) -> Bool {
        return lhs.pretty == rhs.pretty
    }
}

public class FlowAddress: FlowBlob {
    enum AddressError: Error {
        case InvalidHex
        case InvalidLength
        case InvalidType
    }

    public var bytes: [UInt8] {
        return data.bytes
    }

    public var hex: String {
        return data.bytes.map { String(format: "%02x", $0) }.joined()
    }

    public var shortHexWithPrefix: String {
        return String(format: "0x%@", hex.trimLeft("0"))
    }

    public var hexWithPrefix: String {
        return String(format: "0x%@", hex)
    }

    public static func from(_ value: Any) -> FlowAddress? {
        do {
            switch value {
            case is String:
                return try FlowAddress(value as! String)
            case is UInt64:
                return try FlowAddress(value as! UInt64)
            case is [UInt8]:
                return try FlowAddress(value as! [UInt8])
            default:
                return nil
            }
        } catch {
            return nil
        }
    }

    public init(_ bytes: [UInt8]) throws {
        super.init()
        data = Data(bytes)
        _ = data.padLeftZero(8)
        guard data.bytes.count <= 8 else {
            throw AddressError.InvalidLength
        }
    }

    public convenience init(_ address: UInt64) throws {
        try self.init(withUnsafeBytes(of: address, Array.init))
    }

    public convenience init(_ address: String) throws {
        guard let v = UInt64(address.trimLeft("0x"), radix: 16) else {
            throw AddressError.InvalidHex
        }
        try self.init(v.bigEndian)
    }
}

public class FlowBlob: FlowEntity, DataProtocol, CustomStringConvertible {
    public subscript(position: Data.Index) -> UInt8 {
        return data[position]
    }

    public typealias Element = UInt8
    public var regions: Data.Regions

    public var startIndex: Data.Index

    public var endIndex: Data.Index

    public typealias Regions = Data.Regions

    public typealias Index = Data.Index

    public typealias SubSequence = Data.SubSequence

    public typealias Indices = Data.Indices

    public override func set(transform: @escaping ((FlowBlob) -> Void)) {
        transform(self)
    }

    public var data: Data = Data()
    public var description: String {
        return data.hexString()
    }

    public static func from(_ object: Data) -> FlowIdentifier {
        return FlowIdentifier(object)
    }

    public static func from(_ objects: [Data]) -> [FlowIdentifier] {
        return objects.map { o in FlowIdentifier(o) }
    }

    public init(_ data: Data) {
        self.data = data
        regions = self.data.regions
        startIndex = self.data.startIndex
        endIndex = self.data.endIndex
    }

    public override init() {
        regions = data.regions
        startIndex = data.startIndex
        endIndex = data.endIndex
    }
}

public class FlowIdentifier: FlowBlob {
    public convenience init(_ string: String) {
        self.init(string.data(using: .hexadecimal)!)
    }
}

public class FlowTransactionProposalKey: FlowEntity {
    public override func set(transform: @escaping ((FlowTransactionProposalKey) -> Void)) {
        transform(self)
    }

    public var address: FlowAddress = FlowAddress.from("0x0")!
    public var keyId: Int = 0
    public var sequenceNumber: Int = 0
}

public class FlowTransactionSignature: FlowEntity {
    public override func set(transform: @escaping ((FlowTransactionSignature) -> Void)) {
        transform(self)
    }

    public var signerIndex: Int = 0
    public var address: FlowAddress = FlowAddress.from("0x0")!
    public var keyId: Int = 0
    public var signature: FlowBlob = FlowBlob()

    public init(signerIndex: Int, address: FlowAddress, keyId: Int, signature: Data) {
        self.signerIndex = signerIndex
        self.address = address
        self.keyId = keyId
        self.signature = FlowBlob(signature)
    }
}

public class FlowTransaction: FlowEntity {
    public override func set(transform: @escaping ((FlowTransaction) -> Void)) {
        transform(self)
    }

    public var script: String = ""
    public var arguments: [CadenceValue] = [CadenceValue]()
    public var referenceBlockId: FlowIdentifier = FlowIdentifier()
    public var gasLimit: Int = 0
    public var proposalKey: FlowTransactionProposalKey = FlowTransactionProposalKey()
    public var payer: FlowAddress = FlowAddress.from("0x0")!
    public var authorizers: [FlowAddress] = [FlowAddress]()
    public var payloadSignatures: [FlowTransactionSignature] = [FlowTransactionSignature]()
    public var envelopeSignatures: [FlowTransactionSignature] = [FlowTransactionSignature]()
}

public enum FlowTransactionStatus: Int {
    case UNKNOWN = 0
    case PENDING = 1
    case FINALIZED = 2
    case EXECUTED = 3
    case SEALED = 4
    case EXPIRED = 5
}

public class FlowTransactionResult: FlowEntity {
    public override func set(transform: @escaping ((FlowTransactionResult) -> Void)) {
        transform(self)
    }

    public var status: FlowTransactionStatus = FlowTransactionStatus.UNKNOWN
    public var statusCode: Int = 0
    public var errorMessage: String = ""
    public var events: [FlowEvent] = [FlowEvent]()
}

public class FlowExecutionResult: FlowEntity {
    public override func set(transform: @escaping ((FlowExecutionResult) -> Void)) {
        transform(self)
    }

    public var previousResultId: FlowIdentifier = FlowIdentifier()
    public var blockId: FlowIdentifier = FlowIdentifier()
    public var chunks: [FlowChunk] = [FlowChunk]()
    public var serviceEvents: [FlowServiceEvent] = [FlowServiceEvent]()
}

public class FlowChunk: FlowEntity {
    public override func set(transform: @escaping ((FlowChunk) -> Void)) {
        transform(self)
    }

    public var startState: FlowBlob = FlowBlob()
    public var eventCollection: FlowBlob = FlowBlob()
    public var blockId: FlowIdentifier = FlowIdentifier()
    public var totalComputationUsed: Int = 0
    public var numberOfTransactions: Int = 0
    public var index: Int = 0
    public var endState: FlowBlob = FlowBlob()
}

public class FlowServiceEvent: FlowEntity {
    public override func set(transform: @escaping ((FlowServiceEvent) -> Void)) {
        transform(self)
    }

    public var type: String = ""
    public var payload: FlowBlob = FlowBlob()
}

public class FlowBlockHeader: FlowEntity {
    public override func set(transform: @escaping ((FlowBlockHeader) -> Void)) {
        transform(self)
    }

    public var id: FlowIdentifier = FlowIdentifier()
    public var parentId: FlowIdentifier = FlowIdentifier()
    public var height: Int = 0
}

public class FlowBlockSeal: FlowEntity {
    public override func set(transform: @escaping ((FlowBlockSeal) -> Void)) {
        transform(self)
    }

    public var blockId: FlowIdentifier = FlowIdentifier()
    public var executionReceiptId: FlowIdentifier = FlowIdentifier()
    public var executionReceiptSignatures: [FlowBlob] = [FlowBlob]()
    public var resultApprovalSignatures: [FlowBlob] = [FlowBlob]()
}

public class FlowBlock: FlowEntity {
    public override func set(transform: @escaping ((FlowBlock) -> Void)) {
        transform(self)
    }

    public var id: FlowIdentifier = FlowIdentifier()
    public var parentId: FlowIdentifier = FlowIdentifier()
    public var height: Int = 0
    public var timestamp: UInt64 = 0
    public var collectionGuarantees: [FlowCollectionGuarantee] = [FlowCollectionGuarantee]()
    public var blockSeals: [FlowBlockSeal] = [FlowBlockSeal]()
    public var signatures: [FlowBlob] = [FlowBlob]()
}

public class FlowCollection: FlowEntity {
    public override func set(transform: @escaping ((FlowCollection) -> Void)) {
        transform(self)
    }

    public var id: FlowIdentifier = FlowIdentifier()
    public var transactionIds: [FlowIdentifier] = [FlowIdentifier]()
}

public class FlowCollectionGuarantee: FlowEntity {
    public override func set(transform: @escaping ((FlowCollectionGuarantee) -> Void)) {
        transform(self)
    }

    public var collectionId: FlowIdentifier = FlowIdentifier()
    public var signatures: [FlowBlob] = [FlowBlob]()
}

public class FlowDeployedContract: FlowEntity {
    public override func set(transform: @escaping ((FlowDeployedContract) -> Void)) {
        transform(self)
    }

    public var name: String
    public var code: String
    public init(name: String, code: String) {
        self.name = name
        self.code = code
    }
}

public class FlowEvent: FlowEntity {
    public override func set(transform: @escaping ((FlowEvent) -> Void)) {
        transform(self)
    }

    public var type: String = ""
    public var transactionId: FlowIdentifier = FlowIdentifier()
    public var transactionIndex: Int = 0
    public var eventIndex: Int = 0
    public var payload: CadenceStruct?
}

public class FlowEventsResult: FlowEntity {
    public override func set(transform: @escaping ((FlowEventsResult) -> Void)) {
        transform(self)
    }

    public var blockId: FlowIdentifier = FlowIdentifier()
    public var blockHeight: Int = 0
    public var events: [FlowEvent] = [FlowEvent]()
    public var blockTimestamp: UInt64 = 0
}

public class FlowEventsResponse: FlowEntity {
    public override func set(transform: @escaping ((FlowEventsResponse) -> Void)) {
        transform(self)
    }

    public var results: [FlowEventsResult] = [FlowEventsResult]()
}

public enum FlowSignatureAlgorithm: Int, Codable {
    case ECDSA_P256 = 2
    case ECDSA_secp256k1 = 3
}

public enum FlowHashAlgorithm: Int, Codable {
    case SHA2_256 = 1
    case SHA3_256 = 3
}

public class FlowAccountKey: FlowEntity {
    public override func set(transform: @escaping ((FlowAccountKey) -> Void)) {
        transform(self)
    }

    public var publicKey: [UInt8]
    public var signAlgorithm: Int
    public var hashAlgorithm: Int
    public var weight: Int
    public var sequenceNumber: Int

    public init(publicKey: [UInt8], signAlgorithm: Int, hashAlgorithm: Int, weight: Int, sequenceNumber: Int) {
        self.publicKey = publicKey
        self.signAlgorithm = signAlgorithm
        self.hashAlgorithm = hashAlgorithm
        self.weight = weight
        self.sequenceNumber = sequenceNumber
    }
}

public class FlowAccount: FlowEntity {
    public override func set(transform: @escaping ((FlowAccount) -> Void)) {
        transform(self)
    }

    public var address: FlowAddress = FlowAddress.from("0x0")!
    public var balance: CadenceUInt64 = CadenceUInt64(0)
    public var keys: [FlowAccountKey] = [FlowAccountKey]()
    public var contracts: [String: FlowDeployedContract] = [String: FlowDeployedContract]()
    public override init() {}
}
