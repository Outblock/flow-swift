	//
	//  FlowBlockStatus.swift
	//  Flow
	//
	//  Created by Hao Fu on 7/5/2025.
	//  Edited for Swift 6 concurrency & actors by Nicholas Reich on 2026-03-19.
	//

import Foundation

extension Flow {
	public enum BlockStatus: String, Codable, Sendable {
		case sealed
		case final
	}
}
