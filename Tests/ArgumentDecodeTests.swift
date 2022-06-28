//
//  CadenceTypeTest
//
//  Copyright 2022 Outblock Pty Ltd
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

@testable import BigInt
@testable import Flow
import XCTest

struct TestEventType: Codable {
    let wasTheCodeClean: String

    enum CodingKeys: String, CodingKey {
        case wasTheCodeClean = "wasTheCodeClean?"
    }
}

final class ArgumentDecodeTests: XCTestCase {
    private func executeOnChain<T: Decodable>(script: String) async throws -> T {
        let script = Flow.Script(text: script)
        let snapshot = try await flow.accessAPI.executeScriptAtLatestBlock(script: script)
        XCTAssertNotNil(snapshot)

        guard let result: T = try? snapshot.decode() as? T else {
            throw Flow.FError.decodeFailure
        }
        return result
    }

    private func executeOnChain<T: Decodable>(script: String, model: T.Type) async throws -> T? {
        let script = Flow.Script(text: script)
        let snapshot = try await flow.accessAPI.executeScriptAtLatestBlock(script: script)
        XCTAssertNotNil(snapshot)

        guard let result = try? snapshot.decode(model.self) else {
            throw Flow.FError.decodeFailure
        }
        return result
    }

    func testIntType() async throws {
        let cadence = """
            pub fun main(): [Int] {
              return [1, 2, 3]
            }
        """
        let result = try await executeOnChain(script: cadence, model: [Int].self)
        XCTAssertEqual(result?.count, 3)
        XCTAssertEqual(result?.first, 1)
    }

    func testUIntType() async throws {
        let cadence = """
            pub fun main(): [UInt8] {
                let fix = 1.23
                return fix.toBigEndianBytes()
            }
        """
        let result: [UInt8] = try await executeOnChain(script: cadence)
        XCTAssertEqual(result.count, 8)
        XCTAssertEqual(result.last, 192)
    }

    func testInt8Type() async throws {
        let cadence = """
            pub fun main(): Int8 {
                return 3
            }
        """
        let result = try await executeOnChain(script: cadence, model: Int8.self)
        XCTAssertEqual(result, 3)
    }

    func testUInt8Type() async throws {
        let cadence = """
            pub fun main(): UInt8 {
                return 8
            }
        """
        let result = try await executeOnChain(script: cadence, model: UInt8.self)
        XCTAssertEqual(result, 8)
    }

    func testInt16Type() async throws {
        let cadence = """
            pub fun main(): Int16 {
                return 16
            }
        """
        let result = try await executeOnChain(script: cadence, model: Int16.self)
        XCTAssertEqual(result, 16)
    }

    func testUInt16Type() async throws {
        let cadence = """
            pub fun main(): UInt16 {
                return 16
            }
        """
        let result = try await executeOnChain(script: cadence, model: UInt16.self)
        XCTAssertEqual(result, 16)
    }

    func testInt32Type() async throws {
        let cadence = """
            pub fun main(): Int32 {
                return 32
            }
        """
        let result = try await executeOnChain(script: cadence, model: Int32.self)
        XCTAssertEqual(result, 32)
    }

    func testUInt32Type() async throws {
        let cadence = """
            pub fun main(): UInt32 {
                return 32
            }
        """
        let result = try await executeOnChain(script: cadence, model: UInt32.self)
        XCTAssertEqual(result, 32)
    }

    func testInt64Type() async throws {
        let cadence = """
            pub fun main(): Int64 {
                return 64
            }
        """
        let result = try await executeOnChain(script: cadence, model: Int64.self)
        XCTAssertEqual(result, 64)
    }

    func testUInt64Type() async throws {
        let cadence = """
            pub fun main(): UInt64 {
                return 64
            }
        """
        let result = try await executeOnChain(script: cadence, model: UInt64.self)
        XCTAssertEqual(result, 64)
    }

    func testInt128Type() async throws {
        let cadence = """
            pub fun main(): Int128 {
                return 128
            }
        """
        let result = try await executeOnChain(script: cadence, model: BigInt.self)
        XCTAssertEqual(result, 128)
    }

    func testUInt128Type() async throws {
        let cadence = """
            pub fun main(): UInt128 {
                return 128
            }
        """
        let result = try await executeOnChain(script: cadence, model: BigUInt.self)
        XCTAssertEqual(result, 128)
    }

    func testInt256Type() async throws {
        let cadence = """
            pub fun main(): Int256 {
                return 256
            }
        """
        let result = try await executeOnChain(script: cadence, model: BigInt.self)
        XCTAssertEqual(result, 256)
    }

    func testUInt256Type() async throws {
        let cadence = """
            pub fun main(): UInt256 {
                return 256
            }
        """
        let result: BigUInt = try await executeOnChain(script: cadence)
        XCTAssertEqual(result, 256)
    }

    func testWord8Type() async throws {
        let cadence = """
            pub fun main(): Word8 {
                return 10
            }
        """
        let result: UInt8 = try await executeOnChain(script: cadence)
        XCTAssertEqual(result, 10)
    }

    func testWord16Type() async throws {
        let cadence = """
            pub fun main(): Word16 {
                return 10
            }
        """
        let result: UInt16 = try await executeOnChain(script: cadence)
        XCTAssertEqual(result, 10)
    }

    func testWord32Type() async throws {
        let cadence = """
            pub fun main(): Word32 {
                return 10
            }
        """
        let result: UInt32 = try await executeOnChain(script: cadence)
        XCTAssertEqual(result, 10)
    }

    func testWord64Type() async throws {
        let cadence = """
            pub fun main(): Word64 {
                return 10
            }
        """
        let result: UInt64 = try await executeOnChain(script: cadence)
        XCTAssertEqual(result, 10)
    }

    func testFix64Type() async throws {
        let cadence = """
            pub fun main(): Fix64 {
                return -0.64
            }
        """
        let result: Double = try await executeOnChain(script: cadence)
        XCTAssertEqual(result, -0.64)
    }

    func testUFix64Type() async throws {
        let cadence = """
            pub fun main(): UFix64 {
                return 0.64
            }
        """
        let result: Double = try await executeOnChain(script: cadence)
        XCTAssertEqual(result, 0.64)
    }

    func testStringType() async throws {
        let cadence = """
            pub fun main(): String {
                return "absolutely"
            }
        """
        let result: String = try await executeOnChain(script: cadence)
        XCTAssertEqual(result, "absolutely")
    }

    func testBoolType() async throws {
        let cadence = """
            pub fun main(): Bool {
                return true
            }
        """
        let result: Bool = try await executeOnChain(script: cadence)
        XCTAssertEqual(result, true)
    }

    func testVoidType() async throws {
        let jsonString = """
        {
           "type": "Void",
           "value": null
        }
        """
        let argument = Flow.Argument(jsonString: jsonString)
        XCTAssertNil(argument?.decode())
    }

    func testAddressType() throws {
        let jsonString = """
        {
           "type": "Address",
           "value": "0x4eb165aa383fd6f9"
        }
        """
        let argument = Flow.Argument(jsonString: jsonString)!
        let result: String = try argument.decode()
        XCTAssertEqual(result, "0x4eb165aa383fd6f9")
    }

    func testCharacterType() throws {
        let jsonString = """
        {
           "type": "Character",
           "value": "c"
        }
        """
        let argument = Flow.Argument(jsonString: jsonString)!
        let result: String = try argument.decode()
        XCTAssertEqual(result, "c")
    }

    func testOptionalType() throws {
        let jsonString = """
        {
           "type":"Optional",
           "value":{
              "type":"String",
              "value":"test"
           }
        }
        """
        let argument = Flow.Argument(jsonString: jsonString)!
        let result: String? = try argument.decode()
        XCTAssertEqual(result, "test")
    }

    func testReferenceType() throws {
        let jsonString = """
        {
           "type":"Reference",
           "value":{
              "address":"0x01",
              "type":"0x01.CryptoKitty"
           }
        }
        """

        let argument = Flow.Argument(jsonString: jsonString)!
        let result: Flow.Argument.Reference = try argument.decode()
        XCTAssertEqual(result.address, "0x01")
        XCTAssertEqual(result.type, "0x01.CryptoKitty")
    }

    func testDictionaryType() throws {
        let jsonString = """
        {
           "type":"Dictionary",
           "value":[
              {
                 "key":{
                    "type":"Int",
                    "value":"1"
                 },
                 "value":{
                    "type":"String",
                    "value":"one"
                 }
              },
              {
                 "key":{
                    "type":"Int",
                    "value":"2"
                 },
                 "value":{
                    "type":"String",
                    "value":"two"
                 }
              }
           ]
        }
        """
        let argument = Flow.Argument(jsonString: jsonString)!
        let result: [Int: String] = try argument.decode()
        XCTAssertEqual(result[1], "one")
        XCTAssertEqual(result[2], "two")
    }

    func testArrayType() throws {
        let jsonString = """
        {
           "type":"Array",
           "value":[
              {
                 "type":"String",
                 "value":"test1"
              },
              {
                 "type":"String",
                 "value":"test2"
              }
           ]
        }
        """

        let argument = Flow.Argument(jsonString: jsonString)!
        let result: [String] = try argument.decode()
        XCTAssertEqual(result.first, "test1")
        XCTAssertEqual(result.last, "test2")
    }

    func testStructType() throws {
        let jsonString = """
        {
           "type":"Struct",
           "value":{
              "id":"0x01.Jeffysaur",
              "fields":[
                 {
                    "name":"Jeffysaur_Name",
                    "value":{
                       "type":"String",
                       "value":"Mr Jeff The Dinosaur"
                    }
                 }
              ]
           }
        }
        """

        struct TestType: Codable {
            let Jeffysaur_Name: String
        }

        let argument = Flow.Argument(jsonString: jsonString)!
        let result: TestType = try argument.decode()
        XCTAssertEqual(result.Jeffysaur_Name, "Mr Jeff The Dinosaur")
    }

    func testEventType() throws {
        let jsonString = """
        {
           "type":"Event",
           "value":{
              "id":"0x01.JeffWroteSomeJS",
              "fields":[
                 {
                    "name":"wasTheCodeClean?",
                    "value":{
                       "type":"String",
                       "value":"absolutely"
                    }
                 }
              ]
           }
        }
        """

        let argument = Flow.Argument(jsonString: jsonString)!
        let result: TestEventType = try argument.decode()
        XCTAssertEqual(result.wasTheCodeClean, "absolutely")
    }

    func testEnumType() throws {
        let jsonString = """
        {
           "type":"Enum",
           "value":{
              "id":"0x01.JeffWroteSomeJS",
              "fields":[
                 {
                    "name":"wasTheCodeClean?",
                    "value":{
                       "type":"String",
                       "value":"absolutely"
                    }
                 }
              ]
           }
        }
        """

        let argument = Flow.Argument(jsonString: jsonString)!
        let result: TestEventType = try argument.decode()
        XCTAssertEqual(result.wasTheCodeClean, "absolutely")
    }

    func testContractType() throws {
        let jsonString = """
        {
           "type":"Contract",
           "value":{
              "id":"0x01.JeffWroteSomeJS",
              "fields":[
                 {
                    "name":"wasTheCodeClean?",
                    "value":{
                       "type":"String",
                       "value":"absolutely"
                    }
                 }
              ]
           }
        }
        """

        let argument = Flow.Argument(jsonString: jsonString)!
        let result: TestEventType = try argument.decode()
        XCTAssertEqual(result.wasTheCodeClean, "absolutely")
    }

    func testStaticType() throws {
        let jsonString = """
        {
          "type": "Type",
          "value": {
            "staticType": "Int"
          }
        }
        """

        struct TestType: Codable {
            let staticType: String
        }

        let argument = Flow.Argument(jsonString: jsonString)!
        let result: TestType = try argument.decode()
        XCTAssertEqual(result.staticType, "Int")
    }

    func testCapabilityType() throws {
        let jsonString = """
        {
          "type": "Capability",
          "value": {
            "path": "/public/someInteger",
            "address": "0x1",
            "borrowType": "Int",
          }
        }
        """

        let argument = Flow.Argument(jsonString: jsonString)!
        let result: Flow.Argument.Capability = try argument.decode()
        XCTAssertEqual(result.path, "/public/someInteger")
        XCTAssertEqual(result.address, "0x1")
        XCTAssertEqual(result.borrowType, "Int")
    }

    func testResourceType() throws {
        let jsonString = """
        {
           "type":"Resource",
           "value":{
              "id":"0x01.Jeffysaur",
              "fields":[
                 {
                    "name":"Jeffysaur_Name",
                    "value":{
                       "type":"String",
                       "value":"Mr Jeff The Dinosaur"
                    }
                 }
              ]
           }
        }
        """

        struct TestType: Codable {
            let Jeffysaur_Name: String
        }
        let argument = Flow.Argument(jsonString: jsonString)!
        let result: TestType = try argument.decode()
        XCTAssertEqual(result.Jeffysaur_Name, "Mr Jeff The Dinosaur")
    }

    func testPathType() throws {
        let jsonString = """
        {
           "type":"Path",
           "value":{
              "domain":"public",
              "identifier":"zelosAccountingTokenReceiver"
           }
        }
        """

        let argument = Flow.Argument(jsonString: jsonString)!
        let value: Flow.Argument.Path = try argument.decode()
        XCTAssertEqual(value.domain, "public")
        XCTAssertEqual(value.identifier, "zelosAccountingTokenReceiver")
    }

    func testComplicateType() throws {
        let jsonString = """
                {"type":"Array","value":[{"type":"Optional","value":{"type":"Struct","value":{"id":"s.092333c89dc53817e8aa4b1b7fc1b12cd234736b00f589aa80037d3e493724f8.NFTData","fields":[{"name":"contract","value":{"type":"Struct","value":{"id":"s.092333c89dc53817e8aa4b1b7fc1b12cd234736b00f589aa80037d3e493724f8.NFTContractData","fields":[{"name":"name","value":{"type":"String","value":"CNN_NFT"}},{"name":"address","value":{"type":"Address","value":"0x329feb3ab062d289"}},{"name":"storage_path","value":{"type":"String","value":"CNN_NFT.CollectionStoragePath"}},{"name":"public_path","value":{"type":"String","value":"CNN_NFT.CollectionPublicPath"}},{"name":"public_collection_name","value":{"type":"String","value":"CNN_NFT.CNN_NFTCollectionPublic"}},{"name":"external_domain","value":{"type":"String","value":"https://vault.cnn.com/"}}]}}},{"name":"id","value":{"type":"UInt64","value":"2278"}},{"name":"uuid","value":{"type":"Optional","value":{"type":"UInt64","value":"49236818"}}},{"name":"title","value":{"type":"Optional","value":{"type":"String","value":"CNN Projects Trump will Win"}}},{"name":"description","value":{"type":"Optional","value":{"type":"String","value":"November"}}},{"name":"external_domain_view_url","value":{"type":"Optional","value":{"type":"String","value":"https://vault.cnn.com/tokens/2278"}}},{"name":"token_uri","value":{"type":"Optional","value":null}},{"name":"media","value":{"type":"Array","value":[{"type":"Optional","value":{"type":"Struct","value":{"id":"s.092333c89dc53817e8aa4b1b7fc1b12cd234736b00f589aa80037d3e493724f8.NFTMedia","fields":[{"name":"uri","value":{"type":"Optional","value":{"type":"String","value":"https://giglabs.mypinata.cloud/ipfs/Qmcx2NZyMrQK2a2iVzFBSNZn9X1pAkrbwP4B6Dtg3TAnFK"}}},{"name":"mimetype","value":{"type":"Optional","value":{"type":"String","value":"video/mp4"}}}]}}},{"type":"Optional","value":{"type":"Struct","value":{"id":"s.092333c89dc53817e8aa4b1b7fc1b12cd234736b00f589aa80037d3e493724f8.NFTMedia","fields":[{"name":"uri","value":{"type":"Optional","value":{"type":"String","value":"https://giglabs.mypinata.cloud/ipfs/QmQTXyTiYcMaaWwb67hcPUV75onpguwSoDir5axfgexeyn"}}},{"name":"mimetype","value":{"type":"Optional","value":{"type":"String","value":"image"}}}]}}}]}},{"name":"metadata","value":{"type":"Dictionary","value":[{"key":{"type":"String","value":"editionNumber"},"value":{"type":"Optional","value":{"type":"String","value":"272"}}},{"key":{"type":"String","value":"set_id"},"value":{"type":"Optional","value":{"type":"String","value":"4"}}},{"key":{"type":"String","value":"editionCount"},"value":{"type":"Optional","value":{"type":"String","value":"1000"}}},{"key":{"type":"String","value":"series_id"},"value":{"type":"Optional","value":{"type":"String","value":"2"}}}]}}]}}}]}
        """

        let argument = Flow.Argument(jsonString: jsonString)!
        let value: Welcome = try argument.decode()

        XCTAssertEqual(value.first!.id, 2278)
        XCTAssertEqual(value.first!.media.first!.mimetype, "video/mp4")
        XCTAssertEqual(value.first!.title, "CNN Projects Trump will Win")
        XCTAssertNotNil(value)
    }

    // MARK: - Util Method

    @discardableResult
    func toArgument(_ jsonString: String) throws -> Flow.Argument {
        // Test Decode
        let jsonData = jsonString.data(using: .utf8)!
        let result = try JSONDecoder().decode(Flow.Argument.self, from: jsonData)
        return result
    }

    func formatJsonString(jsonString: String) -> Data? {
        let jsonData = jsonString.data(using: .utf8)!
        let object = try! JSONSerialization.jsonObject(with: jsonData)
        return try! JSONSerialization.data(withJSONObject: object, options: [])
    }
}

// MARK: - WelcomeElement

struct WelcomeElement: Codable {
    let contract: Contract
    let id, uuid: UInt64
    let title, welcomeDescription: String
    let externalDomainViewURL: String
    let tokenURI: JSONNull?
    let media: [Media]
    let metadata: Metadata

    enum CodingKeys: String, CodingKey {
        case contract, id, uuid, title
        case welcomeDescription = "description"
        case externalDomainViewURL = "external_domain_view_url"
        case tokenURI = "token_uri"
        case media, metadata
    }
}

// MARK: - Contract

struct Contract: Codable {
    let name, address, storagePath, publicPath: String
    let publicCollectionName: String
    let externalDomain: String

    enum CodingKeys: String, CodingKey {
        case name, address
        case storagePath = "storage_path"
        case publicPath = "public_path"
        case publicCollectionName = "public_collection_name"
        case externalDomain = "external_domain"
    }
}

// MARK: - Media

struct Media: Codable {
    let uri: String
    let mimetype: String
}

// MARK: - Metadata

struct Metadata: Codable {
    let editionNumber, setID, editionCount, seriesID: String

    enum CodingKeys: String, CodingKey {
        case editionNumber
        case setID = "set_id"
        case editionCount
        case seriesID = "series_id"
    }
}

typealias Welcome = [WelcomeElement]

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {
    public static func == (_: JSONNull, _: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public func hash(into _: inout Hasher) {
        // No-op
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
