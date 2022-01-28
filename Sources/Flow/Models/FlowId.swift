//
//  FlowId
//
//  Copyright 2021 Zed Labs Pty Ltd
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import NIO

public extension Flow {
    /// The ID in Flow chain, which can represent as transaction id, block id and collection id etc.
    struct ID: FlowEntity, Equatable, Hashable {
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

extension Flow.ID: Codable {
    enum CodingKeys: String, CodingKey {
        case data
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(hex)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let scriptString = try container.decode(String.self, forKey: .data)
        data = scriptString.hexValue.data
    }
}

extension Flow.ID: CustomStringConvertible {
    public var description: String { data.hexValue }
}

public extension Flow.ID {
    /// Get notified when transaction's status change to `.finalized`.
    /// - returns: A future that will receive the `Flow.TransactionResult` value.
    func onceFinalized() -> EventLoopFuture<Flow.TransactionResult> {
        return once(status: .finalized)
    }

    /// Get notified when transaction's status change to `.executed`.
    /// - returns: A future that will receive the `Flow.TransactionResult` value.
    func onceExecuted() -> EventLoopFuture<Flow.TransactionResult> {
        return once(status: .executed)
    }

    /// Get notified when transaction's status change to `.sealed`.
    /// - returns: A future that will receive the `Flow.TransactionResult` value.
    func onceSealed() -> EventLoopFuture<Flow.TransactionResult> {
        return once(status: .sealed)
    }

    /// Get notified when transaction's status changed.
    /// - parameters:
    ///     - status: The status you want to monitor.
    ///     - delay: Interval between two queries. Default is 2000 milliseconds.
    ///     - timeout: Timeout for this request. Default is 60 seconds.
    /// - returns: A future that will receive the `Flow.TransactionResult` value.
    func once(status: Flow.Transaction.Status,
              delay: DispatchTimeInterval = .milliseconds(2000),
              timeout: TimeInterval = 60) -> EventLoopFuture<Flow.TransactionResult>
    {
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
