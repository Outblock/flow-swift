	//
	//  FlowAccessActor.swift
	//  Flow
	//
	//  Created by Nicholas Reich on 3/21/26.
	//

import SwiftUI

	/// Global actor that owns the FlowAccessProtocol client (HTTP/gRPC).
@globalActor
public actor FlowAccessActor {
	public static let shared = FlowAccessActor()

	private var client: FlowAccessProtocol

	public init(initialChainID: Flow.ChainID = .mainnet) {
		self.client = FlowActor.shared.flow.createHTTPAccessAPI(chainID: initialChainID)
	}

		/// Reconfigure access endpoint and chain ID in a single isolated place.
	public func configure(
		chainID: Flow.ChainID,
		accessAPI: FlowAccessProtocol? = nil
	) async {
		if let accessAPI {
			client = accessAPI
		} else {
			client = FlowActor.shared.flow.createHTTPAccessAPI(chainID: chainID)
		}

			// Optionally keep Flow.shared in sync:
		await FlowActor.shared.flow
			.configure(chainID: chainID, accessAPI: client)
	}

		/// Get the current access client.
	public func currentClient() -> FlowAccessProtocol {
		client
	}
}
