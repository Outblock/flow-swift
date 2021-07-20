//
//  File.swift
//  
//
//  Created by lmcmz on 19/7/21.
//

import Foundation
import Combine

protocol FlowApi {
    func ping() -> Future<Void, Never>
    func getLatestBlockHeader() -> Future<FlowBlockHeader, Never>
}
