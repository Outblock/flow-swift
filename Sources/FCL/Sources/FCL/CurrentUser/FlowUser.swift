//
//  File.swift
//
//
//  Created by lmcmz on 5/9/21.
//

import FlowFoundation
import Foundation

extension FCL {
    struct User: Codable {
        var fType: String = "USER"
        var fVsn: String = "1.0.0"
        let addr: Flow.Address
        var loggedIn: Bool = false
        var services: [Service]? = []
//        let cid: String
//        let expiresAt: Date
    }
}
