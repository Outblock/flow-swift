//
//  FlowError
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

import Foundation

public extension Flow {
    /// List of common error in Flow Swift SDK
    enum FError: Error {
        case generic
        case urlEmpty
        case urlInvaild
        case declined
        case encodeFailure
        case decodeFailure
        case unauthenticated
        case emptyProposer
        case invaildPlayload
        case invaildEnvelope
        case invaildAccountInfo
        case missingSigner
        case preparingTransactionFailed
        case timeout
        case invaildResponse
        case customError(msg: String)

        var rawValue: String {
            switch self {
            case .generic:
                return "generic"
            case .urlEmpty:
                return "urlEmpty"
            case .urlInvaild:
                return "urlInvaild"
            case .declined:
                return "declined"
            case .encodeFailure:
                return "encodeFailure"
            case .decodeFailure:
                return "decodeFailure"
            case .unauthenticated:
                return "unauthenticated"
            case .emptyProposer:
                return "emptyProposer"
            case .invaildPlayload:
                return "invaildPlayload"
            case .invaildEnvelope:
                return "invaildEnvelope"
            case .invaildAccountInfo:
                return "invaildAccountInfo"
            case .missingSigner:
                return "missingSigner"
            case .preparingTransactionFailed:
                return "preparingTransactionFailed"
            case .timeout:
                return "timeout"
            case .invaildResponse:
                return "invaildResponse"
            case let .customError(msg):
                return msg
            }
        }
    }
}

extension Flow.FError: LocalizedError {
    public var errorDescription: String? {
        return rawValue
    }
}
