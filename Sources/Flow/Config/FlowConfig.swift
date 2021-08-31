//
//  File.swift
//
//
//  Created by lmcmz on 29/8/21.
//

import Foundation

extension Flow {
    public class Config {
        var dict = [String: String]()

        enum Key: String, CaseIterable {
            case accessNode = "accessNode.api"
            case icon = "app.detail.icon"
            case title = "app.detail.title"
            case handshake = "challenge.handshake"
            case scope = "challenge.scope"
            case wallet = "discovery.wallet"
            case authn
            case env
            case openIDScope = "service.OpenID.scopes"
        }

        func get(key: Key) -> String? {
            return dict[key.rawValue] ?? nil
        }

        func put(key: Key, value: String?) -> Self {
            if let valueString = value {
                dict[key.rawValue] = valueString
            }
            return self
        }

        func remove(key: Key) -> Config {
            dict.removeValue(forKey: key.rawValue)
            return self
        }

        func get(key: String) -> String? {
            return dict[key] ?? nil
        }

        func put(key: String, value: String?) -> Self {
            if let valueString = value {
                dict[key] = valueString
            }
            return self
        }

        func remove(key: String) -> Config {
            dict.removeValue(forKey: key)
            return self
        }

        func clear() -> Config {
            dict.removeAll()
            return self
        }
    }
}
