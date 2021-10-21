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

    /// Get notified when transaction's status change to `.finalized`.
    /// - returns: A future that will receive the `Flow.TransactionResult` value.
    public func onceFinalized() -> EventLoopFuture<Flow.TransactionResult> {
        return once(status: .finalized)
    }

    /// Get notified when transaction's status change to `.executed`.
    /// - returns: A future that will receive the `Flow.TransactionResult` value.
    public func onceExecuted() -> EventLoopFuture<Flow.TransactionResult> {
        return once(status: .executed)
    }

    /// Get notified when transaction's status change to `.sealed`.
    /// - returns: A future that will receive the `Flow.TransactionResult` value.
    public func onceSealed() -> EventLoopFuture<Flow.TransactionResult> {
        return once(status: .sealed)
    }

    /// Get notified when transaction's status changed.
    /// - parameters:
    ///     - status: The status you want to monitor.
    ///     - delay: Interval between two queries. Default is 2000 milliseconds.
    ///     - timeout: Timeout for this request. Default is 60 seconds.
    /// - returns: A future that will receive the `Flow.TransactionResult` value.
    public func once(status: Flow.Transaction.Status,
                     delay: DispatchTimeInterval = .milliseconds(2000),
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
                DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
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
