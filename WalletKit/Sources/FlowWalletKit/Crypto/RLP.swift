import BigInt
import Foundation

extension BigUInt {
    init(bigEndianBytes bytes: [UInt8]) throws {
        self.init(Data(bytes))
    }

    func asBytes() -> [UInt8] {
        return [UInt8](serialize())
    }

    func minimumRequiredBytes() -> UInt8 {
        return UInt8(asBytes().count)
    }
}

extension UInt64 {
    init(bigEndianBytes bytes: [UInt8]) throws {
        guard bytes.count <= 8 else {
            throw RLP.Error.dataSizeOverflow
        }
        var number: UInt64 = 0

        for byte in bytes {
            number = number << 8
            number += UInt64(byte)
        }

        self = number
    }

    func asBytes() -> [UInt8] {
        var number = self
        var output: [UInt8] = []
        for _ in 0 ..< minimumRequiredBytes() {
            output.insert(UInt8(number & 255), at: 0)
            number = number >> 8
        }
        return output
    }

    func minimumRequiredBytes() -> UInt8 {
        var n = self
        var bytesRequired = 0
        while n > 0 {
            n /= 256
            bytesRequired += 1
        }
        return UInt8(bytesRequired)
    }
}

extension UInt8 {
    var unicodeString: String {
        return String(UnicodeScalar(self))
    }
}

extension Array { // where Element: UInt8 {
    var unicodeString: String {
        return (self as! [UInt8]).reduce("") { $0 + $1.unicodeString }
    }
}

public struct UInt7 {
    static let max: UInt8 = 127
    let uInt8: UInt8
    init(_ value: UInt8) throws {
        guard value <= UInt7.max else { throw RLP.Error.dataSizeOverflow }
        uInt8 = value
    }
}

public struct RLP {
    // RLP doesn't specify any type encoding just bytes and lists
    public enum Value {
        case bytes([UInt8])
        case list([Value])

        // Some rough helpers for common swift types
        public var stringValue: String? {
            if case let .bytes(bytes) = self {
                return bytes.unicodeString
            }
            return nil
        }

        public var intValue: Int? {
            if case let .bytes(bytes) = self {
                return (try? UInt64(bigEndianBytes: bytes)).flatMap { Int($0) }
            }
            return nil
        }

        public var bigUIntValue: BigUInt? {
            if case let .bytes(bytes) = self {
                return try? BigUInt(bigEndianBytes: bytes)
            }
            return nil
        }

        public var listValue: [Value]? {
            if case let .list(list) = self {
                return list
            }
            return nil
        }

        public var stringList: [String]? {
            return listValue?.compactMap { $0.stringValue }
        }

        public var intList: [Int]? {
            return listValue?.compactMap { $0.intValue }
        }

        // Output the decoded bytes maintaining struture but no type information. You would need to apply your own casting on top of this.
        public var rawBytes: Any {
            switch self {
            case let .bytes(bytes):
                return bytes
            case let .list(values):
                return values.map { $0.rawBytes }
            }
        }
    }

    public enum Error: Swift.Error {
        case invalidNumberOfBytes
        case invalidEncodingFlag
        case dataSizeOverflow
        case unableToEncodeType
    }

    // Covers the encoding information, the flag bit if needed along with the length of data or value if byte is a value
    enum EncodingFlag {
        case valueByte(UInt7)
        case multipleBytes(dataLength: UInt64)
        case list(dataLength: UInt64)

        private enum Key: UInt8 {
            case singleValueBelow128 = 0x00
            case upTo55Bytes = 0x80
            case longerThan55Bytes = 0xB7
            case listUpTo55Bytes = 0xC0
            case listLongerThan55Bytes = 0xF7
        }

        // Given the full encoded data work out the encoding type
        init(encodedBytes: [UInt8]) throws {
            guard let firstByte = encodedBytes.first else {
                throw Error.invalidNumberOfBytes
            }
            switch firstByte {
            case Key.singleValueBelow128.rawValue ..< Key.upTo55Bytes.rawValue:
                self = .valueByte(try UInt7(firstByte))
            case Key.upTo55Bytes.rawValue ..< Key.longerThan55Bytes.rawValue:
                let dataLength = UInt64(firstByte - Key.upTo55Bytes.rawValue)
                guard UInt64(encodedBytes.count) >= 1 + dataLength else { throw Error.invalidNumberOfBytes }
                self = .multipleBytes(dataLength: dataLength)
            case Key.longerThan55Bytes.rawValue ..< Key.listUpTo55Bytes.rawValue:
                let numBytesForLength = Int(firstByte - Key.longerThan55Bytes.rawValue)
                let dataLength = try UInt64(bigEndianBytes: Array(encodedBytes[1 ..< 1.advanced(by: numBytesForLength)]))
                guard UInt64(encodedBytes.count) >= 1 + UInt64(numBytesForLength) + dataLength else { throw Error.invalidNumberOfBytes }
                self = .multipleBytes(dataLength: dataLength)
            case Key.listUpTo55Bytes.rawValue ..< Key.listLongerThan55Bytes.rawValue:
                let dataLength = UInt64(firstByte - Key.listUpTo55Bytes.rawValue)
                guard UInt64(encodedBytes.count) >= 1 + dataLength else { throw Error.invalidNumberOfBytes }
                self = .list(dataLength: dataLength)
            case Key.listLongerThan55Bytes.rawValue ..< UInt8.max:
                let numBytesForLength = Int(firstByte - Key.listLongerThan55Bytes.rawValue)
                let dataLength = try UInt64(bigEndianBytes: Array(encodedBytes[1 ..< 1.advanced(by: numBytesForLength)]))
                guard UInt64(encodedBytes.count) >= 1 + UInt64(numBytesForLength) + dataLength else { throw Error.invalidNumberOfBytes }
                self = .list(dataLength: dataLength)
            default:
                fatalError()
            }
        }

        // The endcoding information. This would usually be followed with the data bytes(if not a value byte)
        func composedValue() -> [UInt8] {
            switch self {
            case let .valueByte(value):
                return [Key.singleValueBelow128.rawValue + value.uInt8]
            case let .multipleBytes(dataLength):
                if dataLength <= UInt64(RLP.shortEncodingLimit) {
                    return [Key.upTo55Bytes.rawValue + UInt8(dataLength)]
                } else {
                    return [Key.longerThan55Bytes.rawValue + dataLength.minimumRequiredBytes()] + dataLength.asBytes()
                }
            case let .list(dataLength):
                if dataLength <= UInt64(RLP.shortEncodingLimit) {
                    return [Key.listUpTo55Bytes.rawValue + UInt8(dataLength)]
                } else {
                    return [Key.listLongerThan55Bytes.rawValue + dataLength.minimumRequiredBytes()] + dataLength.asBytes()
                }
            }
        }

        // How many bytes are needed to describe the encoding of the data
        func numberOfEncodingBytes() -> Int {
            return composedValue().count
        }

        func dataLength() -> Int {
            switch self {
            case .valueByte:
                return 0
            case let .multipleBytes(dataLength):
                return Int(dataLength)
            case let .list(dataLength):
                return Int(dataLength)
            }
        }

        func totalByteLength() -> Int {
            return numberOfEncodingBytes() + dataLength()
        }
    }

    public static let shortEncodingLimit = 55

    // Encode a value using RLP
    public static func encode(_ value: Value) -> [UInt8] {
        switch value {
        case let .bytes(bytes) where bytes.count == 0:
            return [0x80]
        case let .bytes(bytes) where bytes.count == 1 && bytes[0] <= UInt7.max:
            return EncodingFlag.valueByte(try! UInt7(bytes[0])).composedValue()
        case let .bytes(bytes):
            return EncodingFlag.multipleBytes(dataLength: UInt64(bytes.count)).composedValue() + bytes
        case let .list(list):
            let encodedList = list.flatMap { encode($0) }
            return EncodingFlag.list(dataLength: UInt64(encodedList.count)).composedValue() + encodedList
        }
    }

    // Helper func to encode common types Int, String, BigUInt, and any amount of nesting of these within arrays
    public static func encode(_ any: Any) throws -> [UInt8] {
        return try encode(values(any))
    }

    // Decode RLP encoded data in to values(with no associated type information)
    public static func decode(_ bytes: [UInt8]) throws -> Value {
        let encodingFlag = try EncodingFlag(encodedBytes: bytes)
        // Check initial size is correct.
        guard encodingFlag.totalByteLength() == bytes.count else { throw Error.invalidNumberOfBytes }
        var mutableBytes = bytes
        return try _decode(&mutableBytes)
    }

    // Recursively decode remaining bytes
    private static func _decode(_ bytes: inout [UInt8]) throws -> Value {
        let encodingFlag = try EncodingFlag(encodedBytes: bytes)
        let numberOfEncodingBytes = encodingFlag.numberOfEncodingBytes()
        let dataBytes = bytes.dropFirst(numberOfEncodingBytes)
        switch encodingFlag {
        case let .valueByte(value):
            bytes = Array(bytes.dropFirst(1))
            return .bytes([value.uInt8])
        case let .multipleBytes(dataLength):
            let result = Array(dataBytes.prefix(Int(dataLength)))
            bytes = Array(dataBytes.dropFirst(Int(dataLength)))
            return .bytes(result)
        case let .list(dataLength):
            var listBytes = Array(dataBytes.prefix(Int(dataLength)))
            bytes = Array(dataBytes.dropFirst(Int(dataLength)))
            var list: [Value] = []
            while listBytes.count > 0 {
                list.append(try _decode(&listBytes))
            }
            return .list(list)
        }
    }

    // Wrap known types as their bytes in values
    private static func values(_ any: Any) throws -> Value {
        if let int = any as? Int {
            return .bytes(UInt64(int).asBytes())
        } else if let int = any as? UInt64 {
            return .bytes(UInt64(int).asBytes())
        } else if let int = any as? UInt32 {
            return .bytes(UInt64(int).asBytes())
        } else if let bigInt = any as? BigUInt {
            return .bytes(bigInt.asBytes())
        } else if let string = any as? String {
            return .bytes(Array(string.utf8))
        } else if let data = any as? Data {
            return .bytes(data.bytes)
        } else if let array = any as? [Any] {
            return .list(try array.map { try values($0) })

        } else {
            throw Error.unableToEncodeType
        }
    }
}
