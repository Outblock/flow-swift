//
//  File.swift
//
//
//  Created by lmcmz on 27/7/21.
//

import Foundation
import NIO

extension Flow {
    public struct ID: FlowEntity, Equatable, Hashable {
        public var data: Data

        public init(hex: String) {
            data = hex.hexValue.data
        }

        init(data: Data) {
            self.data = data
        }

        init(bytes: [UInt8]) {
            data = bytes.data
        }
    }
}

extension Flow.ID {
    public func onceSealed(chainID: Flow.ChainID = flow.defaultChainID) throws -> EventLoopFuture<Flow.TransactionResult> {
        return try once(chainID: chainID, status: .sealed)
    }

    public func onceExecuted(chainID: Flow.ChainID = flow.defaultChainID) throws -> EventLoopFuture<Flow.TransactionResult> {
        return try once(chainID: chainID, status: .executed)
    }

    public func onceFinalized(chainID: Flow.ChainID = flow.defaultChainID) throws -> EventLoopFuture<Flow.TransactionResult> {
        return try once(chainID: chainID, status: .finalized)
    }

    public func once(chainID: Flow.ChainID = flow.defaultChainID,
                     status: Flow.Transaction.Status) throws -> EventLoopFuture<Flow.TransactionResult> {
        guard let api = flow.newAccessApi(chainID: chainID) else {
            throw Flow.FError.generic
        }

        var canContinue = true
        let promise = api.clientChannel.eventLoop.makePromise(of: Flow.TransactionResult.self)
        repeat {
            DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1)) {
                let call = api.getTransactionResultById(id: self)
                call.whenSuccess { value in
                    print("Status --> \(value.status)")
                    if value.status >= status {
                        promise.succeed(value)
                        canContinue = false
                    }
                }

                call.whenFailure { error in
                    promise.fail(error)
                    canContinue = false
                }
            }

        } while canContinue

        return promise.futureResult
    }
}
