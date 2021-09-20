//
//  File.swift
//
//
//  Created by lmcmz on 29/8/21.
//

import Foundation

extension FCL {
    public enum FError: String, Error {
        case generic
        case urlEmpty
        case urlInvaild
        case declined
        case encodeFailure
        case decodeFailure
        case unauthenticated
    }
}

extension FCL.FError: LocalizedError {
    public var errorDescription: String? {
        return rawValue
    }
}
