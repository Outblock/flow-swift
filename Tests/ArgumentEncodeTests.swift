	//
	//  ArgumentEncodeTests.swift
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

@Suite
struct ArgumentEncodeTests {
	@Test("Encode Int array to Cadence JSON")
	func encodeIntType() {
		let value: [Int] = [1, 2, 3]
		let argument = Flow.Argument(value)!
		let expectedJson = """
		{
		  "type": "Array",
		  "value": [
			{"type": "Int", "value": "1"},
			{"type": "Int", "value": "2"},
			{"type": "Int", "value": "3"}
		  ]
		}
		"""
		#expect(argument.jsonString == formatJsonString(jsonString: expectedJson))
	}

	@Test("Encode UInt8 array to Cadence JSON")
	func encodeUIntType() {
		let value: [UInt8] = [1, 2, 3]
		let argument = Flow.Argument(value)!
		let expectedJson = """
		{
		  "type": "Array",
		  "value": [
			{"type": "UInt8", "value": "1"},
			{"type": "UInt8", "value": "2"},
			{"type": "UInt8", "value": "3"}
		  ]
		}
		"""
		#expect(argument.jsonString == formatJsonString(jsonString: expectedJson))
	}

	@Test("Encode String to Cadence JSON")
	func encodeStringType() {
		let value = "absolutely"
		let argument = Flow.Argument(value)!
		let expectedJson = """
		{
		  "type": "String",
		  "value": "absolutely"
		}
		"""
		#expect(argument.jsonString == formatJsonString(jsonString: expectedJson))
	}

	@Test("Encode Bool to Cadence JSON")
	func encodeBoolType() {
		let value = true
		let argument = Flow.Argument(value)!
		let expectedJson = """
		{
		  "type": "Bool",
		  "value": true
		}
		"""
		#expect(argument.jsonString == formatJsonString(jsonString: expectedJson))
	}

	@Test("Encode Optional<String> to Cadence JSON")
	func encodeOptionalType() {
		let value: String? = "test"
		let argument = Flow.Argument(value)!
		let expectedJson = """
		{
		  "type": "Optional",
		  "value": {
			"type": "String",
			"value": "test"
		  }
		}
		"""
		#expect(argument.jsonString == formatJsonString(jsonString: expectedJson))
	}

	@Test("Encode nil Optional<String> to Cadence JSON")
	func encodeNilOptionalType() {
		let value: String? = nil
		let argument = Flow.Argument(value)!
		let expectedJson = """
		{
		  "type": "Optional",
		  "value": null
		}
		"""
		#expect(argument.jsonString == formatJsonString(jsonString: expectedJson))
	}

	@Test("Encode Dictionary<Int, String> to Cadence JSON")
	func encodeDictionaryType() {
		let value: [Int: String] = [1: "one"]
		let argument = Flow.Argument(value)!
		let expectedJson = """
		{
		  "type": "Dictionary",
		  "value": [
			{
			  "key": {"type": "Int", "value": "1"},
			  "value": {"type": "String", "value": "one"}
			}
		  ]
		}
		"""
		#expect(argument.jsonString == formatJsonString(jsonString: expectedJson))
	}

	@Test("Encode String array to Cadence JSON")
	func encodeArrayType() {
		let value = ["test1", "test2"]
		let argument = Flow.Argument(value)!
		let expectedJson = """
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
		#expect(argument.jsonString == formatJsonString(jsonString: expectedJson))
	}

		// MARK: - Util Method

	private func formatJsonString(jsonString: String) -> String? {
		guard
			let jsonData = jsonString.data(using: .utf8),
			let object = try? JSONSerialization.jsonObject(with: jsonData),
			let formattedData = try? JSONSerialization.data(withJSONObject: object, options: []),
			let formattedString = String( formattedData, encoding: .utf8)
		else {
			return nil
		}

		return formattedString
	}
}
