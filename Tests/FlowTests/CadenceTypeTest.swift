	//
	//  CadenceTypeTests.swift
	//  FlowTests
	//
	//  Copyright 2022 Outblock Pty Ltd
	//
	//  Licensed under the Apache License, Version 2.0 (the "License");
	//  you may not use this file except in compliance with the License.
	//  You may obtain a copy of the License at
	//
	//  http://www.apache.org/licenses/LICENSE-2.0
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
import Foundation
import Testing

@Suite
struct CadenceTypeTests {

		// MARK: - Integer & word types

	@Test("Cadence Int encodes/decodes correctly")
	func intType() throws {
		let jsonString = """
		{
		  "type": "Int",
		  "value": "1"
		}
		"""
		let argument = Flow.Argument(value: .int(1))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toInt() == 1)
	}

	@Test("Cadence UInt encodes/decodes correctly")
	func uIntType() throws {
		let jsonString = """
		{
		  "type": "UInt",
		  "value": "1"
		}
		"""
		let argument = Flow.Argument(value: .uint(1))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toUInt() == 1)
	}

	@Test("Cadence Int8 encodes/decodes correctly")
	func int8Type() throws {
		let jsonString = """
		{
		  "type": "Int8",
		  "value": "8"
		}
		"""
		let argument = Flow.Argument(value: .int8(8))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toInt8() == 8)
	}

	@Test("Cadence UInt8 encodes/decodes correctly")
	func uInt8Type() throws {
		let jsonString = """
		{
		  "type": "UInt8",
		  "value": "8"
		}
		"""
		let argument = Flow.Argument(value: .uint8(8))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toUInt8() == 8)
	}

	@Test("Cadence Int16 encodes/decodes correctly")
	func int16Type() throws {
		let jsonString = """
		{
		  "type": "Int16",
		  "value": "16"
		}
		"""
		let argument = Flow.Argument(value: .int16(16))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toInt16() == 16)
	}

	@Test("Cadence UInt16 encodes/decodes correctly")
	func uInt16Type() throws {
		let jsonString = """
		{
		  "type": "UInt16",
		  "value": "16"
		}
		"""
		let argument = Flow.Argument(value: .uint16(16))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toUInt16() == 16)
	}

	@Test("Cadence Int32 encodes/decodes correctly")
	func int32Type() throws {
		let jsonString = """
		{
		  "type": "Int32",
		  "value": "32"
		}
		"""
		let argument = Flow.Argument(value: .int32(32))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toInt32() == 32)
	}

	@Test("Cadence UInt32 encodes/decodes correctly")
	func uInt32Type() throws {
		let jsonString = """
		{
		  "type": "UInt32",
		  "value": "32"
		}
		"""
		let argument = Flow.Argument(value: .uint32(32))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toUInt32() == 32)
	}

	@Test("Cadence Int64 encodes/decodes correctly")
	func int64Type() throws {
		let jsonString = """
		{
		  "type": "Int64",
		  "value": "64"
		}
		"""
		let argument = Flow.Argument(value: .int64(64))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toInt64() == 64)
	}

	@Test("Cadence UInt64 encodes/decodes correctly")
	func uInt64Type() throws {
		let jsonString = """
		{
		  "type": "UInt64",
		  "value": "64"
		}
		"""
		let argument = Flow.Argument(value: .uint64(64))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toUInt64() == 64)
	}

	@Test("Cadence Int128 encodes/decodes correctly")
	func int128Type() throws {
		let jsonString = """
		{
		  "type": "Int128",
		  "value": "128"
		}
		"""
		let argument = Flow.Argument(value: .int128(128))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toInt128() == BigInt(128))
	}

	@Test("Cadence UInt128 encodes/decodes correctly")
	func uInt128Type() throws {
		let jsonString = """
		{
		  "type": "UInt128",
		  "value": "128"
		}
		"""
		let argument = Flow.Argument(value: .uint128(128))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toUInt128() == BigUInt(128))
	}

	@Test("Cadence Int256 encodes/decodes correctly")
	func int256Type() throws {
		let jsonString = """
		{
		  "type": "Int256",
		  "value": "256"
		}
		"""
		let argument = Flow.Argument(value: .int256(256))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toInt256() == BigInt(256))
	}

	@Test("Cadence UInt256 encodes/decodes correctly")
	func uInt256Type() throws {
		let jsonString = """
		{
		  "type": "UInt256",
		  "value": "256"
		}
		"""
		let argument = Flow.Argument(value: .uint256(256))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toUInt256() == BigUInt(256))
	}

	@Test("Cadence Word8 encodes/decodes correctly")
	func word8Type() throws {
		let jsonString = """
		{
		  "type": "Word8",
		  "value": "8"
		}
		"""
		let argument = Flow.Argument(value: .word8(8))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toWord8() == 8)
	}

	@Test("Cadence Word16 encodes/decodes correctly")
	func word16Type() throws {
		let jsonString = """
		{
		  "type": "Word16",
		  "value": "16"
		}
		"""
		let argument = Flow.Argument(value: .word16(16))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toWord16() == 16)
	}

	@Test("Cadence Word32 encodes/decodes correctly")
	func word32Type() throws {
		let jsonString = """
		{
		  "type": "Word32",
		  "value": "32"
		}
		"""
		let argument = Flow.Argument(value: .word32(32))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toWord32() == 32)
	}

	@Test("Cadence Word64 encodes/decodes correctly")
	func word64Type() throws {
		let jsonString = """
		{
		  "type": "Word64",
		  "value": "64"
		}
		"""
		let argument = Flow.Argument(value: .word64(64))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toWord64() == 64)
	}

		// MARK: - Fixed-point types

	@Test("Cadence Fix64 encodes/decodes correctly")
	func fix64Type() throws {
		let jsonString = """
		{
		  "type": "Fix64",
		  "value": "-0.64000000"
		}
		"""
		let argument = Flow.Argument(value: .fix64(-0.64))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toFix64() == -0.64)
	}

	@Test("Cadence UFix64 encodes/decodes correctly")
	func uFix64Type() throws {
		let jsonString = """
		{
		  "type": "UFix64",
		  "value": "0.64000000"
		}
		"""
		let argument = Flow.Argument(value: .ufix64(0.64))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toUFix64() == 0.64)
	}

	@Test("Cadence UFix64 encodes 1.0 correctly")
	func uFix64Type2() throws {
		let jsonString = """
		{
		  "type": "UFix64",
		  "value": "1.00000000"
		}
		"""
		let argument = Flow.Argument(value: .ufix64(1.0))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toUFix64() == 1.0)
	}

		// MARK: - Simple & undefined types

	@Test("Cadence unsupported type decodes to .unsupported")
	func undfinedType() throws {
		let jsonString = """
		{
		  "type": "Test",
		  "value": "1"
		}
		"""
		let argument = Flow.Argument(value: .unsupported)
		let jsonData = jsonString.data(using: .utf8)!
		let result = try JSONDecoder().decode(Flow.Argument.self, from: jsonData)
		#expect(result == argument)
	}

	@Test("Cadence String encodes/decodes correctly")
	func stringType() throws {
		let jsonString = """
		{
		  "type": "String",
		  "value": "absolutely"
		}
		"""
		let argument = Flow.Argument(value: .string("absolutely"))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toString() == "absolutely")
	}

	@Test("Cadence Bool encodes/decodes correctly")
	func boolType() throws {
		let jsonString = """
		{
		  "type": "Bool",
		  "value": true
		}
		"""
		let argument = Flow.Argument(value: .bool(true))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toBool() == true)
	}

	@Test("Cadence Void encodes/decodes correctly")
	func voidType() throws {
		let jsonString = """
		{
		  "type": "Void",
		  "value": null
		}
		"""
		let argument = Flow.Argument(value: .void)
		_ = try verifyJson(jsonString: jsonString, argument: argument)
	}

	@Test("Cadence Address encodes/decodes correctly")
	func addressType() throws {
		let jsonString = """
		{
		  "type": "Address",
		  "value": "0x4eb165aa383fd6f9"
		}
		"""
		let argument = Flow.Argument(value: .address(.init(hex: "0x4eb165aa383fd6f9")))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toAddress() == Flow.Address(hex: "0x4eb165aa383fd6f9"))
	}

	@Test("Cadence Character encodes/decodes correctly")
	func characterType() throws {
		let jsonString = """
		{
		  "type": "Character",
		  "value": "c"
		}
		"""
		let argument = Flow.Argument(value: .character("c"))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toCharacter() == "c")
	}

		// MARK: - Optional, reference, collection & composite types

	@Test("Cadence Optional encodes/decodes correctly")
	func optionalType() throws {
		let jsonString = """
		{
		  "type": "Optional",
		  "value": {
			"type": "String",
			"value": "test"
		  }
		}
		"""
		let argument = Flow.Argument(value: .optional(.string("test")))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toArgument() == argument)
	}

	@Test("Cadence Optional<nil> encodes/decodes correctly")
	func optionalType2() throws {
		let jsonString = """
		{
		  "type": "Optional",
		  "value": null
		}
		"""
		let argument = Flow.Argument(value: .optional(nil))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toArgument() == argument)
	}

	@Test("Cadence Reference encodes/decodes correctly")
	func referenceType() throws {
		let jsonString = """
		{
		  "type": "Reference",
		  "value": {
			"address": "0x01",
			"type": "0x01.CryptoKitty"
		  }
		}
		"""
		let value = Flow.Argument.Reference(address: "0x01", type: "0x01.CryptoKitty")
		let argument = Flow.Argument(value: .reference(value))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toReference() == value)
	}

	@Test("Cadence Dictionary encodes/decodes correctly")
	func dictionaryType() throws {
		let jsonString = """
		{
		  "type": "Dictionary",
		  "value": [
			{
			  "key": {
				"type": "Int",
				"value": "1"
			  },
			  "value": {
				"type": "String",
				"value": "one"
			  }
			},
			{
			  "key": {
				"type": "Int",
				"value": "2"
			  },
			  "value": {
				"type": "String",
				"value": "two"
			  }
			}
		  ]
		}
		"""
		let value: [Flow.Argument.Dictionary] = [
			.init(key: .int(1), value: .string("one")),
			.init(key: .int(2), value: .string("two")),
		]

		let argument = Flow.Argument(value: .dictionary(value))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toDictionary() == value)
	}

	@Test("Cadence Array encodes/decodes correctly")
	func arrayType() throws {
		let jsonString = """
		{
		  "type": "Array",
		  "value": [
			{
			  "type": "String",
			  "value": "test1"
			},
			{
			  "type": "String",
			  "value": "test2"
			}
		  ]
		}
		"""
		let value: [Flow.Cadence.FValue] = [.string("test1"), .string("test2")]
		let argument = Flow.Argument(value: .array(value))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toArgument() == argument)
	}

	@Test("Cadence Struct encodes/decodes correctly")
	func structType() throws {
		let jsonString = """
		{
		  "type": "Struct",
		  "value": {
			"id": "0x01.Jeffysaur",
			"fields": [
			  {
				"name": "Jeffysaur_Name",
				"value": {
				  "type": "String",
				  "value": "Mr Jeff The Dinosaur"
				}
			  }
			]
		  }
		}
		"""
		let value: Flow.Argument.Event = .init(
			id: "0x01.Jeffysaur",
			fields: [
				.init(
					name: "Jeffysaur_Name",
					value: .init(value: .string("Mr Jeff The Dinosaur"))
				),
			]
		)

		let argument = Flow.Argument(value: .struct(value))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toStruct() == value)
	}

	@Test("Cadence Event encodes/decodes correctly")
	func eventType() throws {
		let jsonString = """
		{
		  "type": "Event",
		  "value": {
			"id": "0x01.JeffWroteSomeJS",
			"fields": [
			  {
				"name": "wasTheCodeClean?",
				"value": {
				  "type": "String",
				  "value": "absolutely"
				}
			  }
			]
		  }
		}
		"""
		let value: Flow.Argument.Event = .init(
			id: "0x01.JeffWroteSomeJS",
			fields: [
				.init(
					name: "wasTheCodeClean?",
					value: .init(value: .string("absolutely"))
				),
			]
		)

		let argument = Flow.Argument(value: .event(value))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toEvent() == value)
	}

	@Test("Cadence Enum encodes/decodes correctly")
	func enumType() throws {
		let jsonString = """
		{
		  "type": "Enum",
		  "value": {
			"id": "0x01.JeffWroteSomeJS",
			"fields": [
			  {
				"name": "wasTheCodeClean?",
				"value": {
				  "type": "String",
				  "value": "absolutely"
				}
			  }
			]
		  }
		}
		"""
		let value: Flow.Argument.Event = .init(
			id: "0x01.JeffWroteSomeJS",
			fields: [
				.init(
					name: "wasTheCodeClean?",
					value: .init(value: .string("absolutely"))
				),
			]
		)

		let argument = Flow.Argument(value: .enum(value))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toEnum() == value)
	}

	@Test("Cadence Contract encodes/decodes correctly")
	func contractType() throws {
		let jsonString = """
		{
		  "type": "Contract",
		  "value": {
			"id": "0x01.JeffWroteSomeJS",
			"fields": [
			  {
				"name": "wasTheCodeClean?",
				"value": {
				  "type": "String",
				  "value": "absolutely"
				}
			  }
			]
		  }
		}
		"""
		let value: Flow.Argument.Event = .init(
			id: "0x01.JeffWroteSomeJS",
			fields: [
				.init(
					name: "wasTheCodeClean?",
					value: .init(value: .string("absolutely"))
				),
			]
		)

		let argument = Flow.Argument(value: .contract(value))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toContract() == value)
	}

	@Test("Cadence Static Type encodes/decodes correctly")
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
		let value: Flow.Argument.StaticType = .init(
			staticType: .init(kind: .int, typeID: nil, fields: nil)
		)

		let argument = Flow.Argument(value: .type(value))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toType() == value)
	}

	@Test("Cadence Capability encodes/decodes correctly")
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
		let value: Flow.Argument.Capability = .init(
			path: "/public/someInteger",
			address: "0x1",
			borrowType: "Int"
		)

		let argument = Flow.Argument(value: .capability(value))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toCapability() == value)
	}

	@Test("Cadence Resource encodes/decodes correctly")
	func resourceType() throws {
		let jsonString = """
		{
		  "type": "Resource",
		  "value": {
			"id": "0x01.Jeffysaur",
			"fields": [
			  {
				"name": "Jeffysaur_Name",
				"value": {
				  "type": "String",
				  "value": "Mr Jeff The Dinosaur"
				}
			  }
			]
		  }
		}
		"""
		let value: Flow.Argument.Event = .init(
			id: "0x01.Jeffysaur",
			fields: [
				.init(
					name: "Jeffysaur_Name",
					value: .init(value: .string("Mr Jeff The Dinosaur"))
				),
			]
		)

		let argument = Flow.Argument(value: .resource(value))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toResource() == value)
	}

	@Test("Cadence Path encodes/decodes correctly")
	func pathType() throws {
		let jsonString = """
		{
		  "type": "Path",
		  "value": {
			"domain": "public",
			"identifier": "zelosAccountingTokenReceiver"
		  }
		}
		"""
		let value: Flow.Argument.Path = .init(
			domain: "public",
			identifier: "zelosAccountingTokenReceiver"
		)

		let argument = Flow.Argument(value: .path(value))
		let result = try verifyJson(jsonString: jsonString, argument: argument)
		#expect(result.value.toPath() == value)
	}

		// MARK: - Util

	@discardableResult
	private func verifyJson(
		jsonString: String,
		argument: Flow.Argument
	) throws -> Flow.Argument {
		let jsonData = jsonString.data(using: .utf8)!
		let result = try JSONDecoder().decode(Flow.Argument.self, from: jsonData)
		#expect(result == argument)

		let encoder = JSONEncoder()
		encoder.outputFormatting = [.sortedKeys]

		let encoded = try encoder.encode(argument)
		assertJSONEqual(lhsData: encoded, rhsJsonString: jsonString)

		return result
	}

	private func assertJSONEqual(
		lhsData: Data,
		rhsJsonString: String,
		file: StaticString = #filePath,
		line: UInt = #line
	) {
		let lhsObject = try? JSONSerialization.jsonObject(with: lhsData)
		let rhsData = rhsJsonString.data(using: .utf8) ?? Data()
		let rhsObject = try? JSONSerialization.jsonObject(with: rhsData)

		let lhsDescription = lhsObject.map { String(describing: $0) } ?? ""
		let rhsDescription = rhsObject.map { String(describing: $0) } ?? ""

		#expect(
			lhsDescription == rhsDescription,
			sourceLocation: .init(
				fileID: String(describing: file),
				filePath: String(describing: file),
				line: Int(line),
				column: 0
			)
		)
	}

}
