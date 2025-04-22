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
    case logTx(test: String)
    
    var cadenceBase64: String {
        return switch self {
        case .getCOAAddr:
            "aW1wb3J0IEVWTSBmcm9tIDB4RVZNCgphY2Nlc3MoYWxsKSBmdW4gbWFpbihmbG93QWRkcmVzczogQWRkcmVzcyk6IFN0cmluZz8gewogICAgaWYgbGV0IGFkZHJlc3M6IEVWTS5FVk1BZGRyZXNzID0gZ2V0QXV0aEFjY291bnQ8YXV0aChCb3Jyb3dWYWx1ZSkgJkFjY291bnQ+KGZsb3dBZGRyZXNzKQogICAgICAgIC5zdG9yYWdlLmJvcnJvdzwmRVZNLkNhZGVuY2VPd25lZEFjY291bnQ+KGZyb206IC9zdG9yYWdlL2V2bSk/LmFkZHJlc3MoKSB7CiAgICAgICAgbGV0IGJ5dGVzOiBbVUludDhdID0gW10KICAgICAgICBmb3IgYnl0ZSBpbiBhZGRyZXNzLmJ5dGVzIHsKICAgICAgICAgICAgYnl0ZXMuYXBwZW5kKGJ5dGUpCiAgICAgICAgfQogICAgICAgIHJldHVybiBTdHJpbmcuZW5jb2RlSGV4KGJ5dGVzKQogICAgfQogICAgcmV0dXJuIG5pbAp9Cg=="
        case .logTx:
            "dHJhbnNhY3Rpb24odGVzdDogU3RyaW5nKSB7CiAgICBwcmVwYXJlKHNpZ25lcjE6ICZBY2NvdW50LCBzaWduZXIyOiAmQWNjb3VudCwgc2lnbmVyMzogJkFjY291bnQpIHsKICAgICAgICBsb2coc2lnbmVyMS5hZGRyZXNzKQogICAgICAgIGxvZyhzaWduZXIyLmFkZHJlc3MpCiAgICAgICAgbG9nKHNpZ25lcjMuYWRkcmVzcykKICAgICAgICBsb2codGVzdCkKICAgIH0KfQ=="
        }
    }
    
    var type: CadenceType {
        switch self {
        case .getCOAAddr:
            return .query
        case .logTx:
            return .transaction
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
        
        return switch self {
        case .getCOAAddr:
            String?.self
        default:
            Flow.ID.self
        }
    }
}

final class CadenceTargetTests: XCTestCase {
    
    override class func setUp() {
        flow.configure(chainID: .testnet)
    }
    
    func testQuery() async throws {
        let result: String? = try await flow.query(
            TestCadenceTarget.getCOAAddr(address: .init(hex: "0x84221fe0294044d7")),
            chainID: .mainnet
        )
        XCTAssertNotNil(result)
    }
    
    func testTransaction() async throws {
        let data = FlowAccessAPIOnTestnetTests()
        let id = try await flow.sendTransaction(
            TestCadenceTarget.logTx(test: "Hi!"),
            singers: data.signers,
            network: .testnet) {
                proposer {
                    data.addressA
                }
                
                authorizers {
                    [data.addressA, data.addressB, data.addressC]
                }
                
                payer {
                    data.addressC
                }
            }
        
        print(id.hex)
        XCTAssertNotNil(id)
    }
    
}
