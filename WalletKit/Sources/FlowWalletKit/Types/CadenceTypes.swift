import Foundation

public class CadenceValue: FlowEntity, CustomStringConvertible, Codable {
    public func toJSON() -> Data? {
        let encoder = JSONEncoder()
        do {
            return try encoder.encode(self)
        } catch {
            print("Error while converting to JSON: %@", error)
            return nil
        }
    }

    public static func fromJSON(_ jsonData: Data) -> CadenceValue? {
        let decoder = JSONDecoder()
        do {
            let result = try decoder.decode(CadenceValue.self, from: jsonData)
            return result
        } catch {
            print("Error while converting from JSON: %@", error)
            return nil
        }
    }

    public var cadenceType: String {
        return innerType
    }

    var innerValue: (Any & CustomStringConvertible & Codable) = CadenceNull()
    var innerType: String = ""

    public var value: Any & CustomStringConvertible & Codable {
        return innerValue
    }

    public var description: String {
        return String(format: "%@(%@)", cadenceType, innerValue.description)
    }

    enum CodingKeys: String, CodingKey {
        case type
        case id
        case value
        case fields
    }

    public override init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if !container.allKeys.contains(.type) {
            return
        }

        innerType = try container.decode(String.self, forKey: .type)

        switch innerType {
        case "Optional":
            innerValue = try container.decode(CadenceOptional.self, forKey: .value)
        case "Struct":
            innerValue = try container.decode(CadenceStruct.self, forKey: .value)
        case "Address":
            innerValue = try container.decode(CadenceAddress.self, forKey: .value)
        case "Bool":
            innerValue = try container.decode(CadenceBool.self, forKey: .value)
        case "UFix64":
            innerValue = try container.decode(CadenceString.self, forKey: .value)
        case "UInt8":
            innerValue = try container.decode(CadenceUInt8.self, forKey: .value)
        case "Enum":
            innerValue = try container.decode(CadenceStruct.self, forKey: .value)
        case "Event":
            innerValue = try container.decode(CadenceStruct.self, forKey: .value)

        default:
            break
        }
    }

    public func encode(to _: Encoder) throws {}
}

public class CadenceValueType<T: Codable>: CadenceValue {
    public override var cadenceType: String { return "" }
    public override var description: String { return "" }

    public init(_ value: T) {
        super.init()
        innerValue = value as! (Any & CustomStringConvertible & Codable)
    }

    enum CodingKeys: String, CodingKey {
        case type
        case value
    }

    public required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        innerValue = value as (Any & CustomStringConvertible & Codable)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(cadenceType, forKey: .type)
        try container.encode(innerValue as! T, forKey: .value)
    }
}

// [U]Int, [U]Int8, [U]Int16, [U]Int32,[U]Int64,[U]Int128, [U]Int256,  Word8, Word16, Word32, or Word64

public class CadenceBool: CadenceValueType<Bool> {
    public override var cadenceType: String { return "Bool" }
    public override var description: String { return value.description }
    public required init(from decoder: Decoder) throws {
        super.init(false)
        let container = try decoder.singleValueContainer()
        let value = try container.decode(Bool.self)
        innerValue = value as (Any & CustomStringConvertible & Codable)
    }
}

public class CadenceString: CadenceValueType<String> {
    public override var cadenceType: String { return "String" }
    public override var description: String { return "\"" + value.description + "\"" }
}

public class CadenceUInt: CadenceValueType<UInt> {
    public override var cadenceType: String { return "UInt" }
    public override var description: String { return value.description }
}

public class CadenceUInt8: CadenceValueType<UInt8> {
    public override var cadenceType: String { return "UInt8" }
    public override var description: String { return value.description }
}

public class CadenceUInt16: CadenceValueType<UInt16> {
    public override var cadenceType: String { return "UInt16" }
    public override var description: String { return value.description }
}

public class CadenceUInt32: CadenceValueType<UInt32> {
    public override var cadenceType: String { return "UInt32" }
    public override var description: String { return value.description }
}

public class CadenceUInt64: CadenceValueType<UInt64> {
    public override var cadenceType: String { return "UInt64" }
    public override var description: String { return value.description }
}

public class CadenceInt: CadenceValueType<Int> {
    public override var cadenceType: String { return "Int" }
    public override var description: String { return value.description }
}

public class CadenceInt8: CadenceValueType<Int8> {
    public override var cadenceType: String { return "Int8" }
    public override var description: String { return value.description }
}

public class CadenceInt16: CadenceValueType<Int16> {
    public override var cadenceType: String { return "Int16" }
    public override var description: String { return value.description }
}

public class CadenceInt32: CadenceValueType<Int32> {
    public override var cadenceType: String { return "Int32" }
    public override var description: String { return value.description }
}

public class CadenceInt64: CadenceValueType<Int64> {
    public override var cadenceType: String { return "Int64" }
    public override var description: String { return value.description }
}

public class CadenceNull: CustomStringConvertible, Codable {
    public var description: String {
        return "nil"
    }
}

public class CadencePath: CadenceValue {
    public enum Domain: String {
        case Storage = "storage"
        case Private = "private"
        case Public = "public"
    }

    public override var cadenceType: String { return "Path" }

    enum PathError: Error {
        case InvalidIdentifier
    }

    public var domain: Domain
    public var identifier: String

    public override var description: String {
        return String(format: "%@/%@", domain.rawValue, identifier)
    }

    public static func from(_ value: String) -> CadencePath? {
        let parts = value.components(separatedBy: "/")
        if parts.count == 2 {
            let storageDomain = parts[0]
            let identifier = parts[1]
            guard let domain = Domain(rawValue: storageDomain) else {
                return nil
            }
            do {
                return try CadencePath(domain: domain, identifier: identifier)
            } catch {
                return nil
            }
        }
        return nil
    }

    public init(domain: Domain, identifier: String) throws {
        self.domain = domain
        if identifier.contains(" ") {
            throw PathError.InvalidIdentifier
        }
        self.identifier = identifier
        super.init()
    }

    enum CodingKeys: String, CodingKey {
        case type
        case value
        case domain
        case identifier
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let valueContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .value)
        let domain = try valueContainer.decode(String.self, forKey: .domain)
        let identifier = try valueContainer.decode(String.self, forKey: .identifier)
        self.domain = Domain(rawValue: domain)!
        self.identifier = identifier
        super.init()
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("Path", forKey: .type)
        var valueContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .value)
        try valueContainer.encode(domain.rawValue, forKey: .domain)
        try valueContainer.encode(identifier, forKey: .identifier)
    }
}

public class CadenceOptional: CadenceValue {
    public override var cadenceType: String { return "Optional" }

    public override var description: String {
        return String(format: "%@", innerValue.description)
    }

    public required init(value _: CadenceValue) throws {
        super.init()
    }

    enum CodingKeys: String, CodingKey {
        case type
        case value
    }

    public required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.singleValueContainer()
        innerValue = CadenceNull()
        do {
            innerValue = try container.decode(CadenceValue.self)
        } catch {}
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cadenceType, forKey: .type)
        try container.encode(innerValue as! CadenceValue, forKey: .value)
    }
}

public class CadenceArray: CadenceValue, Collection, Sequence {
    public typealias Index = Array<CadenceValue>.Index
    public typealias Element = Array<CadenceValue>.Element

    public var startIndex: Index { return (innerValue as! [CadenceValue]).startIndex }
    public var endIndex: Index { return (innerValue as! [CadenceValue]).endIndex }

    public subscript(index: Index) -> Iterator.Element { return (innerValue as! [CadenceValue])[index] }

    public func index(after i: Index) -> Index {
        return (innerValue as! [CadenceValue]).index(after: i)
    }

    public override var cadenceType: String { return "Array" }

    public override var description: String {
        return value.description
    }

    public required init(value: [CadenceValue]) throws {
        super.init()
        innerValue = value
    }

    enum CodingKeys: String, CodingKey {
        case type
        case value
    }

    public required init(from decoder: Decoder) throws {
        super.init()

        let container = try decoder.singleValueContainer()

        do {
            innerValue = try container.decode([CadenceValue].self)
        } catch {
            print(error)
            throw error
        }
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cadenceType, forKey: .type)
        try container.encode(innerValue as! [CadenceValue], forKey: .value)
    }
}

public class CadenceDictionary: CadenceValue, Collection, Sequence {
    public class InnerElement: Codable {
        public var key: CadenceValue
        public var value: CadenceValue

        enum CodingKeys: String, CodingKey {
            case key
            case value
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            key = try container.decode(CadenceValue.self, forKey: .value)
            value = try container.decode(CadenceValue.self, forKey: .value)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(key, forKey: .key)
            try container.encode(value, forKey: .value)
        }

        public init(_ key: CadenceValue, value: CadenceValue) {
            self.key = key
            self.value = value
        }
    }

    public typealias Index = Array<InnerElement>.Index
    public typealias Element = Array<InnerElement>.Element

    public var startIndex: Index { return (innerValue as! [InnerElement]).startIndex }
    public var endIndex: Index { return (innerValue as! [InnerElement]).endIndex }

    public subscript(index: Index) -> Iterator.Element { return (innerValue as! [InnerElement])[index] }

    public func index(after i: Index) -> Index {
        return (innerValue as! [InnerElement]).index(after: i)
    }

    public override var cadenceType: String { return "Dictionary" }

    public override var description: String {
        return cadenceType
    }

    public required init(value: [InnerElement]) throws {
        super.init()
        innerValue = value
    }

    enum CodingKeys: String, CodingKey {
        case type
        case value
    }

    public required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        innerValue = try container.decode([InnerElement].self, forKey: .value)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cadenceType, forKey: .type)
        try container.encode(innerValue as! [InnerElement], forKey: .value)
    }
}

public class CadenceStruct: CadenceValue, Collection, Sequence {
    public typealias Index = Array<Field>.Index
    public typealias Element = Array<Field>.Element
    public var startIndex: Index { return fields.startIndex }
    public var endIndex: Index { return fields.endIndex }

    public subscript(key: String) -> CadenceValue {
        for field in fields {
            if key == field.name {
                return field.value
            }
        }
        return CadenceString("") // TODO:
    }

    public subscript(index: Index) -> Iterator.Element {
        return (fields)[index]
    }

    public func index(after i: Index) -> Index {
        return fields.index(after: i)
    }

    public class Field: Codable, CustomStringConvertible {
        public var name: String
        public var value: CadenceValue

        enum CodingKeys: String, CodingKey {
            case name
            case value
        }

        public var description: String {
            return String(format: "%@ = %@", name, value.description)
        }

        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decode(String.self, forKey: .name)
            value = try container.decode(CadenceValue.self, forKey: .value)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(value, forKey: .value)
        }
    }

    public override var cadenceType: String { "Composite" }

    public var id: String
    public var fields: [Field]

    public override var description: String {
        return String(format: "identifier=%@(%@)", id, fields.map { $0.description }.joined(separator: ", "))
    }

    public required init(id: String, fields: [Field]) throws {
        self.id = id
        self.fields = fields
        super.init()
    }

    enum CodingKeys: String, CodingKey {
        case type
        case value
        case fields
        case id
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        fields = try container.decode([Field].self, forKey: .fields)
        super.init()
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var valueContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .value)
        try valueContainer.encode(id, forKey: .id)
        try valueContainer.encode(fields, forKey: .fields)
    }
}

public class CadenceType: CadenceValue {
    public var staticType: String
    public override var cadenceType: String { return "Type" }

    public override var description: String {
        return String(format: "Type<%@>", staticType)
    }

    public required init(staticType: String) throws {
        self.staticType = staticType
        super.init()
    }

    public static func from(_ value: String) -> CadenceType? {
        guard let result = try? self.init(staticType: value) else {
            return nil
        }
        return result
    }

    enum CodingKeys: String, CodingKey {
        case type
        case value
        case staticType
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let valueContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .value)
        let staticTypeString = try valueContainer.decode(String.self, forKey: .staticType)
        staticType = staticTypeString
        super.init()
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("Capability", forKey: .type)
        var valueContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .value)
        try valueContainer.encode(staticType, forKey: .staticType)
    }
}

public class CadenceCapability: CadenceValue {
    public var path: CadencePath
    public var address: CadenceAddress
    public var borrowType: String
    public override var cadenceType: String { return "Capability" }

    public override var description: String {
        return String(format: "Capability<path=%@, address=%@, borrowType=%@>", path.description, address.description, borrowType)
    }

    public init(address: CadenceAddress, path: CadencePath, borrowType: String) throws {
        self.path = path
        self.address = address
        self.borrowType = borrowType
        super.init()
    }

    enum CodingKeys: String, CodingKey {
        case type
        case value
        case path
        case address
        case borrowType
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let valueContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .value)
        let pathString = try valueContainer.decode(String.self, forKey: .path)
        let addressString = try valueContainer.decode(String.self, forKey: .address)
        address = CadenceAddress.from(addressString)!
        borrowType = try valueContainer.decode(String.self, forKey: .borrowType)
        path = CadencePath.from(pathString)!
        super.init()
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("Capability", forKey: .type)
        var valueContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .value)
        try valueContainer.encode(path.description, forKey: .path)
        try valueContainer.encode(address.description, forKey: .address)
        try valueContainer.encode(borrowType, forKey: .borrowType)
    }
}

public class CadenceAddress: CadenceValue {
    enum AddressError: Error {
        case InvalidHex
        case InvalidLength
        case InvalidType
    }

    public override var cadenceType: String {
        return "Address"
    }

    private static var MAX_ADDRESS_SIZE = 8

    public override var description: String {
        return shortHexWithPrefix
    }

    public var bytes: [UInt8] {
        return value as! [UInt8]
    }

    public var data: Data {
        return Data(value as! [UInt8])
    }

    public var hex: String {
        return (innerValue as! [UInt8]).map { String(format: "%02x", $0) }.joined()
    }

    public var shortHexWithPrefix: String {
        return String(format: "0x%@", hex.trimLeft("0"))
    }

    public var hexWithPrefix: String {
        return String(format: "0x%@", hex)
    }

    public var swiftValue: UInt64 {
        return UInt64(hex, radix: 16)!
    }

    public static func from(_ value: Any) -> CadenceAddress? {
        do {
            switch value {
            case is String:
                return try CadenceAddress(value as! String)
            case is UInt64:
                return try CadenceAddress(value as! UInt64)
            case is [UInt8]:
                return try CadenceAddress(value as! [UInt8])
            default:
                return nil
            }
        } catch {
            return nil
        }
    }

    public init(_ bytes: [UInt8]) throws {
        super.init()
        innerValue = bytes
        guard (innerValue as! [UInt8]).count <= CadenceAddress.MAX_ADDRESS_SIZE else {
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

    enum CodingKeys: String, CodingKey {
        case type
        case value
    }

    public required convenience init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        try self.init(value)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("Address", forKey: .type)
        try container.encode(shortHexWithPrefix, forKey: .value)
    }
}
