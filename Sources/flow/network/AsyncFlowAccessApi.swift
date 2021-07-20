//
//  File.swift
//  
//
//  Created by lmcmz on 19/7/21.
//

import Foundation
import Combine

protocol AsyncFlowAccessApi {
    func ping() -> Promise<Void>
    func getLatestBlockHeader() -> Promise<FlowBlockHeader>
}
