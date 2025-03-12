//
//  ArgumentEncodeTests.swift
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

final class ArgumentEncodeTests: XCTestCase {
    
    func testEncodeIntType() throws {
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
        XCTAssertEqual(argument.jsonString, formatJsonString(jsonString: expectedJson))
    }
    
    func testEncodeUIntType() throws {
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
        XCTAssertEqual(argument.jsonString, formatJsonString(jsonString: expectedJson))
    }
    
    func testEncodeStringType() throws {
        let value = "absolutely"
        let argument = Flow.Argument(value)!
        let expectedJson = """
        {
           "type": "String",
           "value": "absolutely"
        }
        """
        XCTAssertEqual(argument.jsonString, formatJsonString(jsonString: expectedJson))
    }
    
    func testEncodeBoolType() throws {
        let value = true
        let argument = Flow.Argument(value)!
        let expectedJson = """
        {
           "type": "Bool",
           "value": true
        }
        """
        XCTAssertEqual(argument.jsonString, formatJsonString(jsonString: expectedJson))
    }
    
    func testEncodeOptionalType() throws {
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
        XCTAssertEqual(argument.jsonString, formatJsonString(jsonString: expectedJson))
    }
    
    func testEncodeNilOptionalType() throws {
        let value: String? = nil
        let argument = Flow.Argument(value)!
        let expectedJson = """
        {
           "type": "Optional",
           "value": null
        }
        """
        XCTAssertEqual(argument.jsonString, formatJsonString(jsonString: expectedJson))
    }
    
    func testEncodeDictionaryType() throws {
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
        XCTAssertEqual(argument.jsonString, formatJsonString(jsonString: expectedJson))
    }
    
    func testEncodeArrayType() throws {
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
        XCTAssertEqual(argument.jsonString, formatJsonString(jsonString: expectedJson))
    }

    // MARK: - Util Method

    func formatJsonString(jsonString: String) -> String? {
        guard let jsonData = jsonString.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: jsonData),
              let formattedData = try? JSONSerialization.data(withJSONObject: object, options: []),
              let formattedString = String(data: formattedData, encoding: .utf8) else {
            return nil
        }
        return formattedString
    }
} 
