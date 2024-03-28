//
//  File.swift
//
//
//  Created by Hao Fu on 22/11/2022.
//

import Combine
import CryptoKit
@testable import Flow
import Foundation
import XCTest

final class FlowAccessAPIOnPreviewnetTests: XCTestCase {
    var flowAPI: FlowAccessProtocol!

    override func setUp() {
        super.setUp()
        flowAPI = flow.createHTTPAccessAPI(chainID: .previewnet)
        flow.configure(chainID: .previewnet)
    }

    func testFlowPing() async throws {
        let isConnected = try await flowAPI.ping()
        XCTAssertTrue(isConnected)
    }

    func testNetworkParameters() async throws {
        let chainID = try await flowAPI.getNetworkParameters()
        XCTAssertEqual(chainID, Flow.ChainID.previewnet)
    }

    func testFlowAccount() async throws {
        let account = try await flow.getAccountAtLatestBlock(address: "0x4e8e130b4fb9aee2")
        print(account)
        XCTAssertNotNil(account)
    }

    func testTransactionResult() async throws {
        let result = try await flow.getTransactionById(id: .init(hex: "db6c446d2e4caa4389aa5253b2d576efbfcbd32a56948f9daf5b40da30e17d0c"))
        XCTAssertNotNil(result)
    }

    func testTransaction() async throws {
        let result = try await flow.getTransactionResultById(id: "db6c446d2e4caa4389aa5253b2d576efbfcbd32a56948f9daf5b40da30e17d0c")
        XCTAssertNotNil(result)
    }
}
