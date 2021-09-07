//
//  File.swift
//
//
//  Created by lmcmz on 29/8/21.
//

import Foundation

public enum FlowError: Error {
    case generic
    case urlEmpty
    case urlInvaild
    case declined
    case encodeFailure
    case decodeFailure
}
