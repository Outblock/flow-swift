	//
	//  P256FlowSigner.swift
	//  Flow
	//
	//  Created by Nicholas Reich on 3/21/26.
	//

import Foundation
#if canImport(CryptoKit)
import CryptoKit
#endif







// MARK: - P256 signer

#if canImport(CryptoKit)

/// ECDSA P‑256 signer for Flow, backed by CryptoKit.
public struct P256FlowSigner: FlowSigner {

	public let algorithm: Flow.SignatureAlgorithm = .ECDSA_P256
	public let address: Flow.Address
	public let keyIndex: Int

	private let key: P256.Signing.PrivateKey

	public init(
		key: P256.Signing.PrivateKey,
		address: Flow.Address,
		keyIndex: Int
	) {
		self.key = key
		self.address = address
		self.keyIndex = keyIndex
	}

	public func sign(
		signableData: Data,
		transaction: Flow.Transaction?
	) async throws -> Data {
		let signature = try key.signature(for: signableData)
		return signature.derRepresentation
	}
}

#endif
