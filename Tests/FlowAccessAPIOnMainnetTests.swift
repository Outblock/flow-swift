//
//  File.swift
//  
//
//  Created by Selina on 19/10/2021.
//

import Foundation
@testable import Flow
import XCTest

final class FlowAccessAPIOnMainnetTests: XCTestCase {
    var flowAPI: Flow.AccessAPI!
    var mainnetAddress = "0x4eb165aa383fd6f9"
    
    override func setUp() {
        super.setUp()
        flowAPI = flow.createAccessAPI(chainID: .mainnet)
    }
    
    func testTransactionById() throws {
        let id = Flow.ID(hex: "6d6c20405f3dd2001361cd994493a56d31f4daa1c7ce420a2cd4259454b4a0da")
        let transaction = try flowAPI.getTransactionById(id: id).wait()
        XCTAssertEqual(transaction?.arguments.first?.type, .path)
        XCTAssertEqual(transaction?.arguments.first?.value, .path(.init(domain: "public", identifier: "zelosAccountingTokenReceiver")))
        XCTAssertEqual(transaction?.arguments.last?.type, .ufix64)
        XCTAssertEqual(transaction?.arguments.last?.value.toUFix64(), 99.0)
        XCTAssertEqual(transaction?.payerAddress.bytes.hexValue, "1f56a1e665826a52")
        XCTAssertNotNil(transaction)
    }
}
