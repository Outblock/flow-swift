	//
	//  ArgumentDecodeTests.swift
	//  FlowTests
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
	//  Migrated from XCTest to Swift Testing by Nicholas Reich on 2026-03-19.
	//

@testable import BigInt
@testable import Flow
import Testing

struct TestEventType: Codable, Sendable {
	let wasTheCodeClean: String

	enum CodingKeys: String, CodingKey {
		case wasTheCodeClean = "wasTheCodeClean?"
	}
}

@Suite
struct ArgumentDecodeTests {
	// MARK: - On-chain helpers

	private func executeOnChain<T: Decodable & Sendable>(
		script: String
	) async throws -> T {
		let script = Flow.Script(text: script)
		let snapshot = try await flow.accessAPI.executeScriptAtLatestBlock(script: script)
		#expect(snapshot != nil)

		guard let result: T = try? snapshot.decode() as? T else {
			throw Flow.FError.decodeFailure
		}
		return result
	}

	private func executeOnChain<T: Decodable & Sendable>(
		script: String,
		model: T.Type
	) async throws -> T? {
		let script = Flow.Script(text: script)
		let snapshot = try await flow.accessAPI.executeScriptAtLatestBlock(script: script)
		#expect(snapshot != nil)

		guard let result = try? snapshot.decode(model.self) else {
			throw Flow.FError.decodeFailure
		}
		return result
	}

		// MARK: - Numeric types

	@Test("Decode [Int] from Cadence")
	func intType() async throws {
		let cadence = """
		pub fun main(): [Int] {
			return [1, 2, 3]
		}
		"""
		let result = try await executeOnChain(script: cadence, model: [Int].self)
		#expect(result?.count == 3)
		#expect(result?.first == 1)
	}

	@Test("Decode [UInt8] from Cadence")
	func uIntType() async throws {
		let cadence = """
		pub fun main(): [UInt8] {
			let fix = 1.23
			return fix.toBigEndianBytes()
		}
		"""
		let result: [UInt8] = try await executeOnChain(script: cadence)
		#expect(result.count == 8)
		#expect(result.last == 192)
	}

	@Test("Decode Int8 from Cadence")
	func int8Type() async throws {
		let cadence = """
		pub fun main(): Int8 {
			return 3
		}
		"""
		let result = try await executeOnChain(script: cadence, model: Int8.self)
		#expect(result == 3)
	}

	@Test("Decode UInt8 from Cadence")
	func uInt8Type() async throws {
		let cadence = """
		pub fun main(): UInt8 {
			return 8
		}
		"""
		let result = try await executeOnChain(script: cadence, model: UInt8.self)
		#expect(result == 8)
	}

	@Test("Decode Int16 from Cadence")
	func int16Type() async throws {
		let cadence = """
		pub fun main(): Int16 {
			return 16
		}
		"""
		let result = try await executeOnChain(script: cadence, model: Int16.self)
		#expect(result == 16)
	}

	@Test("Decode UInt16 from Cadence")
	func uInt16Type() async throws {
		let cadence = """
		pub fun main(): UInt16 {
			return 16
		}
		"""
		let result = try await executeOnChain(script: cadence, model: UInt16.self)
		#expect(result == 16)
	}

	@Test("Decode Int32 from Cadence")
	func int32Type() async throws {
		let cadence = """
		pub fun main(): Int32 {
			return 32
		}
		"""
		let result = try await executeOnChain(script: cadence, model: Int32.self)
		#expect(result == 32)
	}

	@Test("Decode UInt32 from Cadence")
	func uInt32Type() async throws {
		let cadence = """
		pub fun main(): UInt32 {
			return 32
		}
		"""
		let result = try await executeOnChain(script: cadence, model: UInt32.self)
		#expect(result == 32)
	}

	@Test("Decode Int64 from Cadence")
	func int64Type() async throws {
		let cadence = """
		pub fun main(): Int64 {
			return 64
		}
		"""
		let result = try await executeOnChain(script: cadence, model: Int64.self)
		#expect(result == 64)
	}

	@Test("Decode UInt64 from Cadence")
	func uInt64Type() async throws {
		let cadence = """
		pub fun main(): UInt64 {
			return 64
		}
		"""
		let result = try await executeOnChain(script: cadence, model: UInt64.self)
		#expect(result == 64)
	}

	@Test("Decode Int128 as BigInt")
	func int128Type() async throws {
		let cadence = """
		pub fun main(): Int128 {
			return 128
		}
		"""
		let result = try await executeOnChain(script: cadence, model: BigInt.self)
		#expect(result == 128)
	}

	@Test("Decode UInt128 as BigUInt")
	func uInt128Type() async throws {
		let cadence = """
		pub fun main(): UInt128 {
			return 128
		}
		"""
		let result = try await executeOnChain(script: cadence, model: BigUInt.self)
		#expect(result == 128)
	}

	@Test("Decode Int256 as BigInt")
	func int256Type() async throws {
		let cadence = """
		pub fun main(): Int256 {
			return 256
		}
		"""
		let result = try await executeOnChain(script: cadence, model: BigInt.self)
		#expect(result == 256)
	}

	@Test("Decode UInt256 as BigUInt")
	func uInt256Type() async throws {
		let cadence = """
		pub fun main(): UInt256 {
			return 256
		}
		"""
		let result: BigUInt = try await executeOnChain(script: cadence)
		#expect(result == 256)
	}

	@Test("Decode Word8")
	func word8Type() async throws {
		let cadence = """
		pub fun main(): Word8 {
			return 10
		}
		"""
		let result: UInt8 = try await executeOnChain(script: cadence)
		#expect(result == 10)
	}

	@Test("Decode Word16")
	func word16Type() async throws {
		let cadence = """
		pub fun main(): Word16 {
			return 10
		}
		"""
		let result: UInt16 = try await executeOnChain(script: cadence)
		#expect(result == 10)
	}

	@Test("Decode Word32")
	func word32Type() async throws {
		let cadence = """
		pub fun main(): Word32 {
			return 10
		}
		"""
		let result: UInt32 = try await executeOnChain(script: cadence)
		#expect(result == 10)
	}

	@Test("Decode Word64")
	func word64Type() async throws {
		let cadence = """
		pub fun main(): Word64 {
			return 10
		}
		"""
		let result: UInt64 = try await executeOnChain(script: cadence)
		#expect(result == 10)
	}

	@Test("Decode Fix64 as Decimal")
	func fix64Type() async throws {
		let cadence = """
		pub fun main(): Fix64 {
			return -0.64
		}
		"""
		let result: Decimal = try await executeOnChain(script: cadence)
		#expect(result == -0.64)
	}

	@Test("Decode UFix64 as Decimal")
	func uFix64Type() async throws {
		let cadence = """
		pub fun main(): UFix64 {
			return 0.64
		}
		"""
		let result: Decimal = try await executeOnChain(script: cadence)
		#expect(result == 0.64)
	}

		// MARK: - Basic types

	@Test("Decode String from Cadence")
	func stringType() async throws {
		let cadence = """
		pub fun main(): String {
			return "absolutely"
		}
		"""
		let result: String = try await executeOnChain(script: cadence)
		#expect(result == "absolutely")
	}

	@Test("Decode Bool from Cadence")
	func boolType() async throws {
		let cadence = """
		pub fun main(): Bool {
			return true
		}
		"""
		let result: Bool = try await executeOnChain(script: cadence)
		#expect(result == true)
	}

		// MARK: - JSON-based decoding

	@Test("Decode Void")
	func voidType() {
		let jsonString = """
		{
		  "type": "Void",
		  "value": null
		}
		"""
		let argument = Flow.Argument(jsonString: jsonString)
		#expect(argument?.decode() == nil)
	}

	@Test("Decode Address")
	func addressType() throws {
		let jsonString = """
		{
		  "type": "Address",
		  "value": "0x4eb165aa383fd6f9"
		}
		"""
		let argument = Flow.Argument(jsonString: jsonString)!
		let result: String = try argument.decode()
		#expect(result == "0x4eb165aa383fd6f9")
	}

	@Test("Decode Character")
	func characterType() throws {
		let jsonString = """
		{
		  "type": "Character",
		  "value": "c"
		}
		"""
		let argument = Flow.Argument(jsonString: jsonString)!
		let result: String = try argument.decode()
		#expect(result == "c")
	}

	@Test("Decode Optional<String>")
	func optionalType() throws {
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
		#expect(result == "test")
	}

	@Test("Decode Reference")
	func referenceType() throws {
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
		#expect(result.address == "0x01")
		#expect(result.type == "0x01.CryptoKitty")
	}

	@Test("Decode Dictionary<Int, String>")
	func dictionaryType() throws {
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
		#expect(result[1] == "one")
		#expect(result[2] == "two")
	}

	@Test("Decode [String]")
	func arrayType() throws {
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
		#expect(result.first == "test1")
		#expect(result.last == "test2")
	}

	@Test("Decode Struct")
	func structType() throws {
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
		#expect(result.Jeffysaur_Name == "Mr Jeff The Dinosaur")
	}

	@Test("Decode Event")
	func eventType() throws {
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
		#expect(result.wasTheCodeClean == "absolutely")
	}

	@Test("Decode Enum")
	func enumType() throws {
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
		#expect(result.wasTheCodeClean == "absolutely")
	}

	@Test("Decode Contract")
	func contractType() throws {
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
		#expect(result.wasTheCodeClean == "absolutely")
	}

	@Test("Decode Static Type")
	func staticType() throws {
		let jsonString = """
		{
		  "type": "Type",
		  "value": {
			"staticType": {
			  "kind": "Int"
			}
		  }
		}
		"""
		let argument = Flow.Argument(jsonString: jsonString)!
		let result: Flow.Argument.StaticType = try argument.decode()
		#expect(result.staticType.kind == .int)
	}

	@Test("Decode Capability")
	func capabilityType() throws {
		let jsonString = """
		{
		  "type": "Capability",
		  "value": {
			"path": "/public/someInteger",
			"address": "0x1",
			"borrowType": "Int"
		  }
		}
		"""
		let argument = Flow.Argument(jsonString: jsonString)!
		let result: Flow.Argument.Capability = try argument.decode()
		#expect(result.path == "/public/someInteger")
		#expect(result.address == "0x1")
		#expect(result.borrowType == "Int")
	}

	@Test("Decode Resource")
	func resourceType() throws {
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
		#expect(result.Jeffysaur_Name == "Mr Jeff The Dinosaur")
	}

	@Test("Decode Path")
	func pathType() throws {
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
		#expect(value.domain == "public")
		#expect(value.identifier == "zelosAccountingTokenReceiver")
	}

	@Test("Decode complex NFT type")
	func complicateType() throws {
		let jsonString = """
		{"type":"Array","value":[{"type":"Optional","value":{"type":"Struct","value":{"id":"s.092333c89dc53817e8aa4b1b7fc1b12cd234736b00f589aa80037d3e493724f8.NFTData","fields":[{"name":"contract","value":{"type":"Struct","value":{"id":"s.092333c89dc53817e8aa4b1b7fc1b12cd234736b00f589aa80037d3e493724f8.NFTContractData","fields":[{"name":"name","value":{"type":"String","value":"CNN_NFT"}},{"name":"address","value":{"type":"Address","value":"0x329feb3ab062d289"}},{"name":"storage_path","value":{"type":"String","value":"CNN_NFT.CollectionStoragePath"}},{"name":"public_path","value":{"type":"String","value":"CNN_NFT.CollectionPublicPath"}},{"name":"public_collection_name","value":{"type":"String","value":"CNN_NFT.CNN_NFTCollectionPublic"}},{"name":"external_domain","value":{"type":"String","value":"https://vault.cnn.com/"}}]}}},{"name":"id","value":{"type":"UInt64","value":"2278"}},{"name":"uuid","value":{"type":"Optional","value":{"type":"UInt64","value":"49236818"}}},{"name":"title","value":{"type":"Optional","value":{"type":"String","value":"CNN Projects Trump will Win"}}},{"name":"description","value":{"type":"Optional","value":{"type":"String","value":"November"}}},{"name":"external_domain_view_url","value":{"type":"Optional","value":{"type":"String","value":"https://vault.cnn.com/tokens/2278"}}},{"name":"token_uri","value":{"type":"Optional","value":null}},{"name":"media","value":{"type":"Array","value":[{"type":"Optional","value":{"type":"Struct","value":{"id":"s.092333c89dc53817e8aa4b1b7fc1b12cd234736b00f589aa80037d3e493724f8.NFTMedia","fields":[{"name":"uri","value":{"type":"Optional","value":{"type":"String","value":"https://giglabs.mypinata.cloud/ipfs/Qmcx2NZyMrQK2a2iVzFBSNZn9X1pAkrbwP4B6Dtg3TAnFK"}}},{"name":"mimetype","value":{"type":"Optional","value":{"type":"String","value":"video/mp4"}}}]}}},{"type":"Optional","value":{"type":"Struct","value":{"id":"s.092333c89dc53817e8aa4b1b7fc1b12cd234736b00f589aa80037d3e493724f8.NFTMedia","fields":[{"name":"uri","value":{"type":"Optional","value":{"type":"String","value":"https://giglabs.mypinata.cloud/ipfs/QmQTXyTiYcMaaWwb67hcPUV75onpguwSoDir5axfgexeyn"}}},{"name":"mimetype","value":{"type":"Optional","value":{"type":"String","value":"image"}}}]}}}]}},{"name":"metadata","value":{"type":"Dictionary","value":[{"key":{"type":"String","value":"editionNumber"},"value":{"type":"Optional","value":{"type":"String","value":"272"}}},{"key":{"type":"String","value":"set_id"},"value":{"type":"Optional","value":{"type":"String","value":"4"}}},{"key":{"type":"String","value":"editionCount"},"value":{"type":"Optional","value":{"type":"String","value":"1000"}}},{"key":{"type":"String","value":"series_id"},"value":{"type":"Optional","value":{"type":"String","value":"2"}}}]}}]}}}]}
		"""

		let argument = Flow.Argument(jsonString: jsonString)!
		let value: Welcome = try argument.decode()

		#expect(value.first!.id == 2278)
		#expect(value.first!.media.first!.mimetype == "video/mp4")
		#expect(value.first!.title == "CNN Projects Trump will Win")
		#expect(value.isEmpty == false)
	}

		// MARK: - Util helpers

	@discardableResult
	private func toArgument(_ jsonString: String) throws -> Flow.Argument {
		let jsonData = jsonString.data(using: .utf8)!
		let result = try JSONDecoder().decode(Flow.Argument.self, from: jsonData)
		return result
	}

	private func formatJsonString(jsonString: String) -> Data? {
		let jsonData = jsonString.data(using: .utf8)!
		let object = try! JSONSerialization.jsonObject(with: jsonData)
		return try! JSONSerialization.data(withJSONObject: object, options: [])
	}
}

// MARK: - Complex NFT models

struct WelcomeElement: Codable {
	let contract: Contract
	let id, uuid: UInt64
	let title, welcomeDescription: String
	let externalDomainViewURL: String
	let tokenURI: JSONNull?
	let media: [Media]
	let meta Metadata

	enum CodingKeys: String, CodingKey {
		case contract, id, uuid, title
		case welcomeDescription = "description"
		case externalDomainViewURL = "external_domain_view_url"
		case tokenURI = "token_uri"
		case media, metadata
	}
}

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

struct Media: Codable {
	let uri: String
	let mimetype: String
}

struct Meta Codable {
	let editionNumber, setID, editionCount, seriesID: String

	enum CodingKeys: String, CodingKey {
		case editionNumber
		case setID = "set_id"
		case editionCount
		case seriesID = "series_id"
	}
}

typealias Welcome = [WelcomeElement]

// Minimal JSONNull type for compatibility
final class JSONNull: Codable, Hashable {
	static func == (lhs: JSONNull, rhs: JSONNull) -> Bool { true }
	func hash(into hasher: inout Hasher) { }
	init() {}
	init(from decoder: Decoder) throws { _ = try decoder.singleValueContainer().decodeNil() }
	func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encodeNil()
	}
}
