//
//  FlowScript.swift
//
//
//  Created by lmcmz on 23/7/21.
//

import Foundation

extension Flow {
    public struct Script: FlowEntity, Equatable {
        public var data: Data

        public init(script: String) {
            data = script.data(using: .utf8) ?? Data()
        }

        public init(data: Data) {
            self.data = data
        }

        init(bytes: [UInt8]) {
            data = bytes.data
        }
    }

    public struct ScriptResponse: FlowEntity, Equatable {
        public var data: Data
        var fields: Argument?

        init(data: Data) {
            self.data = data
            fields = try? JSONDecoder().decode(Flow.Argument.self, from: data)
        }
    }
}
