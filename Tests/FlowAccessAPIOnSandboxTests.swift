//
//  File.swift
//  
//
//  Created by Hao Fu on 22/11/2022.
//

import Foundation
import Combine
import CryptoKit
@testable import Flow
import XCTest

final class FlowAccessAPIOnSandboxTests: XCTestCase {
    var flowAPI: FlowAccessProtocol!
    
    override func setUp() {
        super.setUp()
        flowAPI = flow.createHTTPAccessAPI(chainID: .sandbox)
        flow.configure(chainID: .sandbox)
    }
    
    func testFlowPing() async throws {
        let isConnected = try await flowAPI.ping()
        XCTAssertTrue(isConnected)
    }
    
    func testFlowAccount() async throws {
        let account = try await flow.getAccountAtLatestBlock(address: "0x4e8e130b4fb9aee2")
        XCTAssertNotNil(account)
    }
}
