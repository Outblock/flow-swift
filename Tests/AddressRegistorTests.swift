//
//  AddressRegistorTests.swift
//  Flow
//
//  Created by Hao Fu on 1/4/2025.
//

import XCTest
import Flow

final class AddressRegistorTests: XCTestCase {
    
    func testContract() {
        let result = flow.addressRegister.contractExists("0xFlowToken", on: .mainnet)
        let all = flow.addressRegister.getAddresses(for: .mainnet)
        print(all)
        XCTAssertTrue(result)
    }
    
    func testImportContract() {
        flow.addressRegister.importAddresses(for: .mainnet, from: ["0xABC": "0x123"])
        let result = flow.addressRegister.contractExists("0xABC", on: .mainnet)
        XCTAssertTrue(result)
    }
    
    func testEVMAddress() async throws {
        let result = try await flow.getEVMAddress(address: .init(hex: "0x39416b4b085d94c7"))
        XCTAssertEqual(result, "0x000000000000000000000002993F5c597a37e150".lowercased().stripHexPrefix())
    }
    
    func testNoChildAddress() async throws {
        let result = try await flow.getChildAddress(address: .init(hex: "0x39416b4b085d94c7"))
        XCTAssertEqual(result.count, 0)
    }
    
    func testHasChildAddress() async throws {
        let result = try await flow.getChildAddress(address: .init(hex: "0x84221fe0294044d7"))
        print(result)
        XCTAssertTrue(result.count > 0)
    }
    
    func testChildMetadata() async throws {
        let result = try await flow.getChildMetadata(address: .init(hex: "0x84221fe0294044d7"))
        XCTAssertNotNil(result[result.keys.first!]?.name)
    }
}
