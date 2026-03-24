	//
	//  FlowActor.swift
	//  Flow
	//
	//  Created by Nicholas Reich on 3/22/26.
	//

import Foundation

	/// Global actor used to isolate high-level Flow façade APIs.
@globalActor
public actor FlowActor {
	public static let shared = FlowActor()

	public let flow: Flow

		/// Default to Flow.shared but allow injection for tests.
	public init(flow: Flow = .shared) {
		self.flow = flow
	}
}
