//
//  File.swift
//
//
//  Created by lmcmz on 28/8/21.
//

import Foundation

public struct AuthnRequest: Codable {
    let fType: String
    let fVsn: String
    let type: String?
    let endpoint: String
    let method: String
//    var data: Dictionary<String, String>?
//    var parameter: Dictionary<String, String>?
}
