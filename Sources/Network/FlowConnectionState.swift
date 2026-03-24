	//
	//  FlowConnectionState.swift
	//  Flow
	//
	//  Created by Nicholas Reich on 3/21/26.
	//

import SwiftUI
import Combine

@available(macOS 14.0, *)
@Observable
@MainActor
final class FlowConnectionState {
	@Published var isConnected: Bool = false
	@Published var lastError: Error?
}

@available(macOS 14.0, *)
extension FlowConnectionState {

		/// Async sequence of connection state changes.
	var isConnectedValues: some AsyncSequence {
		$isConnected.values
	}
}

