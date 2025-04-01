//
//  File.swift
//
//
//  Created by Hao Fu on 27/9/2022.
//

import Foundation

@testable import BigInt
import CryptoKit
@testable import Flow
import XCTest

final class FlowAddressTest: XCTestCase {
    func testAddressHexType() async throws {
        let hex = "0xc7efa8c33fceee03"
        let address = Flow.Address(hex: hex)
        XCTAssertEqual(address.hex, hex)
        XCTAssertEqual(address.bytes.count, 8)
        XCTAssertEqual(address.description, hex)

        let isVaild = await flow.isAddressVaildate(address: address, network: .mainnet)
        XCTAssertEqual(true, isVaild)
    }

    func testAddressHexTypeTestnet() async throws {
        let hex = "0xc6de0d94160377cd"
        let address = Flow.Address(hex: hex)
        let isVaild = await flow.isAddressVaildate(address: address, network: .testnet)
        XCTAssertEqual(true, isVaild)
    }

    func testAddressType() async throws {
        let hex = "c7efa8c33fceee03"
        let address = Flow.Address(hex: hex)
        XCTAssertEqual(address.hex, hex.addHexPrefix())
        XCTAssertEqual(address.bytes.count, 8)
        XCTAssertEqual(address.description, hex.addHexPrefix())

        let isVaild = await flow.isAddressVaildate(address: address)
        XCTAssertEqual(true, isVaild)
    }

    func testInvaildAddressType() async throws {
        let hex = "0x03"
        let address = Flow.Address(hex: hex)
        XCTAssertNotEqual(address.hex, hex)
        XCTAssertEqual(address.bytes.count, 8)
        XCTAssertNotEqual(address.description, hex)

        let isVaild = await flow.isAddressVaildate(address: address)
        XCTAssertEqual(false, isVaild)
    }

    func testInvaildLongAddressType() async throws {
        let hex = "0x56519083C3cfeAE833B93a93c843C993bE1D74EA"
        let address = Flow.Address(hex: hex)
        XCTAssertEqual(address.hex, "0x56519083C3cfeAE8".lowercased())
        XCTAssertNotEqual(address.hex, hex)
        XCTAssertEqual(address.bytes.count, 8)
        XCTAssertNotEqual(address.description, hex)

        let isVaild = await flow.isAddressVaildate(address: address)
        XCTAssertEqual(false, isVaild)
    }
}
