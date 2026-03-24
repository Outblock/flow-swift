	//
	//  FlowConnectionState.swift
	//  Flow
	//
	//  Created by Nicholas Reich on 3/21/26.
	//  Refactored to remove Combine and rely on FlowActor isolation.
	//

import Foundation

@available(macOS 14.0, *)
@FlowActor
final class FlowConnectionState {
	var isConnected: Bool = false
	var lastError: Error?
}
