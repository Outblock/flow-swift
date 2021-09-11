@testable import Flow
import XCTest

final class CadenceTypeTests: XCTestCase {
    func testIntType() throws {
        let jsonString = """
        {
           "type": "Int",
           "value": "1"
        }
        """
        let argument = Flow.Argument(value: .int(value: 1))
        _ = try! verifyJson(jsonString: jsonString, argument: argument)
    }

    func testStringType() throws {
        let jsonString = """
        {
           "type": "String",
           "value": "absolutely"
        }
        """
        let argument = Flow.Argument(value: .string(value: "absolutely"))
        _ = try! verifyJson(jsonString: jsonString, argument: argument)
    }

    func testBoolType() throws {
        let jsonString = """
        {
           "type": "Bool",
           "value": true
        }
        """
        let argument = Flow.Argument(value: .bool(value: true))
        _ = try! verifyJson(jsonString: jsonString, argument: argument)
    }

    func testVoidType() throws {
        let jsonString = """
        {
           "type": "Void",
           "value": null
        }
        """
        let argument = Flow.Argument(value: .void)
        _ = try! verifyJson(jsonString: jsonString, argument: argument)
    }

    func testAddressType() throws {
        let jsonString = """
        {
           "type": "Address",
           "value": "0x1"
        }
        """
        let argument = Flow.Argument(value: .address(value: .init(hex: "0x1")))
        _ = try! verifyJson(jsonString: jsonString, argument: argument)
    }

    func testCharacterType() throws {
        let jsonString = """
        {
           "type": "Character",
           "value": "c"
        }
        """
        let argument = Flow.Argument(value: .character(value: "c"))
        _ = try! verifyJson(jsonString: jsonString, argument: argument)
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
        let argument = Flow.Argument(value: .optional(value: .init(value: .string(value: "test"))))
        _ = try! verifyJson(jsonString: jsonString, argument: argument)
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

        let argument = Flow.Argument(value: .reference(value: .init(address: "0x01", type: "0x01.CryptoKitty")))
        _ = try! verifyJson(jsonString: jsonString, argument: argument)
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

        let argument = Flow.Argument(value: .dictionary(value: [.init(key: .init(value: .int(value: 1)), value: .init(value: .string(value: "one"))),
                                                                .init(key: .init(value: .int(value: 2)), value: .init(value: .string(value: "two")))]))
        let result = try! verifyJson(jsonString: jsonString, argument: argument)
        guard case let .dictionary(value) = result.value else {
            XCTFail()
            return
        }
        XCTAssertEqual(value.first?.key.value, .int(value: 1))
        XCTAssertEqual(value.first?.value.value, .string(value: "one"))
        XCTAssertEqual(value.last?.key.value, .int(value: 2))
        XCTAssertEqual(value.last?.value.value, .string(value: "two"))
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
        let argument = Flow.Argument(value: .array(value: [.init(value: .string(value: "test1")), .init(value: .string(value: "test2"))]))
        let result = try! verifyJson(jsonString: jsonString, argument: argument)
        guard case let .array(value) = result.value else {
            XCTFail()
            return
        }

        XCTAssertEqual(value.first?.value, .string(value: "test1"))
        XCTAssertEqual(value.last?.value, .string(value: "test2"))
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
        let argument = Flow.Argument(value: .struct(value: .init(id: "0x01.Jeffysaur",
                                                                 fields: [.init(name: "Jeffysaur_Name",
                                                                                value: .init(value: .string(value: "Mr Jeff The Dinosaur")))])))
        let result = try! verifyJson(jsonString: jsonString, argument: argument)
        guard case let .struct(value) = result.value else {
            XCTFail()
            return
        }
        XCTAssertNotNil(value)
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
        let argument = Flow.Argument(value: .event(value: .init(id: "0x01.JeffWroteSomeJS",
                                                                fields: [.init(name: "wasTheCodeClean?",
                                                                               value: .init(value: .string(value: "absolutely")))])))
        let result = try! verifyJson(jsonString: jsonString, argument: argument)
        guard case let .event(value) = result.value else {
            XCTFail()
            return
        }
        XCTAssertNotNil(value)
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
        let argument = Flow.Argument(value: .resource(value: .init(id: "0x01.Jeffysaur",
                                                                   fields: [.init(name: "Jeffysaur_Name",
                                                                                  value: .init(value: .string(value: "Mr Jeff The Dinosaur")))])))
        let result = try! verifyJson(jsonString: jsonString, argument: argument)
        guard case let .resource(value) = result.value else {
            XCTFail()
            return
        }
        XCTAssertNotNil(value)
    }

    // MARK: - Util Method

    func verifyJson(jsonString: String, argument: Flow.Argument) throws -> Flow.Argument {
        // Test Decode
        let jsonData = jsonString.data(using: .utf8)!
        let result = try! JSONDecoder().decode(Flow.Argument.self, from: jsonData)
        XCTAssertEqual(result, argument)

        // Test Encode
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(argument)
        XCTAssertEqual(encoded, formatJsonString(jsonString: jsonString))
        return result
    }

    func formatJsonString(jsonString: String) -> Data {
        let jsonData = jsonString.data(using: .utf8)!
        let object = try! JSONSerialization.jsonObject(with: jsonData)
        return try! JSONSerialization.data(withJSONObject: object, options: [])
    }
}
