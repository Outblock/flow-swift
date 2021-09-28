//
//  File.swift
//
//
//  Created by lmcmz on 29/8/21.
//

import Foundation

extension Flow {
    public enum FError: String, Error {
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
        case missingSigner
        case preparingTransactionFailed
    }
}

extension Flow.FError: LocalizedError {
    public var errorDescription: String? {
        return rawValue
    }
}
