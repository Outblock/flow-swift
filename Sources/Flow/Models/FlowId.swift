//
//  FlowId
//
//  Copyright 2022 Outblock Pty Ltd
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

import Combine
import Foundation

public extension Flow {
    /// The ID in Flow chain, which can represent as transaction id, block id and collection id etc.
    struct ID: FlowEntity, Equatable, Hashable {
        public var data: Data

        public init(hex: String) {
            data = hex.hexValue.data
        }

        public init(data: Data) {
            self.data = data
        }

        public init(bytes: [UInt8]) {
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
        let container = try decoder.singleValueContainer()
        let scriptString = try container.decode(String.self)
        data = scriptString.hexValue.data
    }
}

extension Flow.ID: CustomStringConvertible {
    public var description: String { data.hexValue }
}

 public extension Flow.ID {
    /// Get notified when transaction's status change to `.finalized`.
    /// - returns: A future that will receive the `Flow.TransactionResult` value.
    func onceFinalized() async throws -> Flow.TransactionResult {
        return try await once(status: .finalized)
    }

    /// Get notified when transaction's status change to `.executed`.
    /// - returns: A future that will receive the `Flow.TransactionResult` value.
    func onceExecuted() async throws -> Flow.TransactionResult {
        return try await once(status: .executed)
    }

    /// Get notified when transaction's status change to `.sealed`.
    /// - returns: A future that will receive the `Flow.TransactionResult` value.
    func onceSealed() async throws -> Flow.TransactionResult {
        return try await once(status: .sealed)
    }

    /// Get notified when transaction's status changed.
    /// - parameters:
    ///     - status: The status you want to monitor.
    ///     - delay: Interval between two queries. Default is 2000 milliseconds.
    ///     - timeout: Timeout for this request. Default is 60 seconds.
    /// - returns: A future that will receive the `Flow.TransactionResult` value.
    func once(status: Flow.Transaction.Status,
              delayInNanoSec: UInt64 = 2_000_000_000,
              timeout: TimeInterval = 60) async throws -> Flow.TransactionResult
    {
        let accessAPI = flow.accessAPI
        let timeoutDate = Date(timeIntervalSinceNow: timeout)

        @Sendable
        func makeResultCall() async throws -> Flow.TransactionResult {
            let now = Date()
            if now > timeoutDate {
                // timeout
                throw Flow.FError.timeout
            }

            let result = try await accessAPI.getTransactionResultById(id: self)
            if result.status >= status {
                // finished
                return result
            }

            // continue loop
            try await _Concurrency.Task.sleep(nanoseconds: delayInNanoSec)
            return try await makeResultCall()
        }

        return try await makeResultCall()
    }
 }
