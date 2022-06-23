//
//  File.swift
//  
//
//  Created by Hao Fu on 23/6/2022.
//

import Foundation


internal enum Method: String {
    case GET
    case POST
}

internal protocol TargetType {
    /// The target's base `URL`.
    var baseURL: URL { get }

    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String { get }

    /// The HTTP method used in the request.
    var method: Method { get }

    /// The type of HTTP task to be performed.
    var task: Task { get }

    /// The headers to be used in the request.
    var headers: [String: String]? { get }
}

internal enum Task {
    /// A requests body set with encoded parameters.
    case requestParameters(_ parameters: [String: String]? = nil, body: Encodable? = nil)
}

internal struct AnyEncodable: Encodable {
    private let encodable: Encodable

    public init(_ encodable: Encodable) {
        self.encodable = encodable
    }

    func encode(to encoder: Encoder) throws {
        try encodable.encode(to: encoder)
    }
}
