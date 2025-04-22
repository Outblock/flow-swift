//
//  File.swift
//  Flow
//
//  Created by Hao Fu on 23/4/2025.
//

import Foundation
@testable import Flow
import XCTest

/// Class

enum TestCadenceTarget: CadenceTargetType, MirrorAssociated {
    case getCOAAddr(address: Flow.Address)
    
    var cadenceBase64: String {
        switch self {
        case .getCOAAddr:
            return "aW1wb3J0IEVWTSBmcm9tIDB4RVZNCgphY2Nlc3MoYWxsKSBmdW4gbWFpbihmbG93QWRkcmVzczogQWRkcmVzcyk6IFN0cmluZz8gewogICAgaWYgbGV0IGFkZHJlc3M6IEVWTS5FVk1BZGRyZXNzID0gZ2V0QXV0aEFjY291bnQ8YXV0aChCb3Jyb3dWYWx1ZSkgJkFjY291bnQ+KGZsb3dBZGRyZXNzKQogICAgICAgIC5zdG9yYWdlLmJvcnJvdzwmRVZNLkNhZGVuY2VPd25lZEFjY291bnQ+KGZyb206IC9zdG9yYWdlL2V2bSk/LmFkZHJlc3MoKSB7CiAgICAgICAgbGV0IGJ5dGVzOiBbVUludDhdID0gW10KICAgICAgICBmb3IgYnl0ZSBpbiBhZGRyZXNzLmJ5dGVzIHsKICAgICAgICAgICAgYnl0ZXMuYXBwZW5kKGJ5dGUpCiAgICAgICAgfQogICAgICAgIHJldHVybiBTdHJpbmcuZW5jb2RlSGV4KGJ5dGVzKQogICAgfQogICAgcmV0dXJuIG5pbAp9Cg=="
        }
    }
    
    var type: CadenceType {
        switch self {
        case .getCOAAddr:
            return .query
        }
    }
    
    var arguments: [Flow.Argument] {
        associatedValues.compactMap { $0.value.toFlowValue() }.toArguments()
    }
    
    // Get return type for each case
    var returnType: Decodable.Type {
        if type == .transaction {
            return Flow.ID.self
        }
        
        switch self {
        case .getCOAAddr:
            return String?.self
        }
    }
}

final class CadenceTargetTests: XCTestCase {
    
    func testNew() async throws {
        let result: String? = try await flow.query(
            TestCadenceTarget.getCOAAddr(address: .init(hex: "0x84221fe0294044d7"))
        )
        XCTAssertNotNil(result)
    }
    
}
