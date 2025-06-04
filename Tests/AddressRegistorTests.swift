//
//  AddressRegistorTests.swift
//  Flow
//
//  Created by Hao Fu on 1/4/2025.
//

import XCTest
import Flow

final class AddressRegistorTests: XCTestCase {
    
    let addressA = Flow.Address(hex: "0x39416b4b085d94c7")
    let addressB = Flow.Address(hex: "0x84221fe0294044d7")
    
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
        let result = try await flow.getEVMAddress(address: addressA)
        XCTAssertEqual(result, "0x000000000000000000000002993F5c597a37e150".lowercased().stripHexPrefix())
    }
    
    func testNoChildAddress() async throws {
        let result = try await flow.getChildAddress(address: addressA)
        XCTAssertEqual(result.count, 0)
    }
    
    func testHasChildAddress() async throws {
        let result = try await flow.getChildAddress(address: addressB)
        print(result)
        XCTAssertTrue(result.count > 0)
    }
    
    func testChildMetadata() async throws {
        let result = try await flow.getChildMetadata(address: addressB)
        XCTAssertNotNil(result[result.keys.first!]?.name)
    }
    
    func testNoChildMetadata() async throws {
        let result = try await flow.getChildMetadata(address: addressA)
        XCTAssertTrue(result.isEmpty)
    }
    
    func testStake() async throws {
        let models = try await flow.getStakingInfo(address: addressB)
        XCTAssertTrue(!models.isEmpty)
    }
    
    func testTokenBalance() async throws {
        let models = try await flow.getTokenBalance(address: addressA)
        XCTAssertTrue(!models.isEmpty)
    }
}
