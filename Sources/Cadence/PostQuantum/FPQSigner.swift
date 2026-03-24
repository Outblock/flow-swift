//
//  FlowSigner.swift
//  Flow
//
//  Created by Nicholas Reich on 3/21/26.
//
import SwiftUI
protocol FlowQSigner: Sendable {
    var algorithm: FlowSignatureAlgorithm { get }
    func sign(message: Data) async throws -> Data
}

protocol FlowKEM: Sendable {
    func encapsulate(to publicKey: Data) async throws -> (sharedSecret: Data, ciphertext: Data)
    func decapsulate(ciphertext: Data) async throws -> Data
}
