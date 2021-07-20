//
//  File.swift
//
//
//  Created by lmcmz on 19/7/21.
//

import Combine
import Foundation

protocol FlowApi {
    func ping() -> Future<Void, Never>

    func getLatestBlockHeader() -> Future<FlowBlockHeader, Never>

    func getBlockHeaderById(id: FlowId) -> Future<FlowBlockHeader?, Never>

    func getBlockHeaderByHeight(height: UInt64) -> Future<FlowBlockHeader?, Never>

    func getLatestBlock(sealed: Bool) -> Future<FlowBlock, Never>

    func getBlockById(id: FlowId) -> Future<FlowBlock?, Never>

    func getBlockByHeight(height: UInt64) -> Future<FlowBlock?, Never>
}
