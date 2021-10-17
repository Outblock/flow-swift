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
    public func onceFinalized() -> EventLoopFuture<Flow.TransactionResult> {
        return once(status: .finalized)
    }

    public func onceExecuted() -> EventLoopFuture<Flow.TransactionResult> {
        return once(status: .executed)
    }

    public func onceSealed() -> EventLoopFuture<Flow.TransactionResult> {
        return once(status: .sealed)
    }

    public func once(status: Flow.Transaction.Status,
                     delay: Int = 2000,
                     timeout: TimeInterval = 60) -> EventLoopFuture<Flow.TransactionResult> {
        let accessAPI = flow.accessAPI
        let promise = accessAPI.clientChannel.eventLoop.makePromise(of: Flow.TransactionResult.self)
        let timeoutDate = Date(timeIntervalSinceNow: timeout)

        func makeResultCall() {
            let now = Date()
            if now > timeoutDate {
                // timeout
                promise.fail(Flow.FError.timeout)
                return
            }

            let call = accessAPI.getTransactionResultById(id: self)
            call.whenSuccess { result in
                if result.status >= status {
                    // finished
                    promise.succeed(result)
                    return
                }

                // continue loop
                DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(delay)) {
                    makeResultCall()
                }
            }

            call.whenFailure { error in
                // error
                promise.fail(error)
            }
        }

        makeResultCall()
        return promise.futureResult
    }
}
