	//
	//  Array.swift
	//
	//  Copyright 2022 Outblock Pty Ltd
	//
	//  Licensed under the Apache License, Version 2.0 (the "License");
	//  you may not use this file except in compliance with the License.
	//  You may obtain a copy of the License at
	//
	//    http://www.apache.org/licenses/LICENSE-2.0
	//
	//  Unless required by applicable law or agreed to in writing, software
	//  distributed under the License is distributed on an "AS IS" BASIS,
	//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	//  See the License for the specific language governing permissions and
	//  limitations under the License.
	//

import Foundation

extension Array where Iterator.Element: Hashable {
	func hash(into hasher: inout Hasher) {
		for obj in self {
			hasher.combine(obj)
		}
	}
}

public extension Array where Element == Flow.Cadence.FValue {
	func toArguments() -> [Flow.Argument] {
		compactMap(Flow.Argument.init)
	}
}

public extension Array where Element == Flow.Argument {
	func toValue() -> [Flow.Cadence.FValue] {
		compactMap { $0.value }
	}
}

	/// Concurrent map that preserves order of the original sequence.
	/// Safe to use from within actors as it does not share mutable state.
extension Sequence {
	func concurrentMap<Transformed: Sendable>(
		priority: TaskPriority? = nil,
		_ transform: @escaping @Sendable (Element) async throws -> Transformed
	) async rethrows -> [Transformed] where Element: Sendable {
		try await withThrowingTaskGroup(of: (Int, Transformed).self) { group in
			var index = 0
			for element in self {
				let currentIndex = index
				index += 1

				group.addTask(priority: priority) {
					(currentIndex, try await transform(element))
				}
			}

			var results: [Transformed?] = Array(repeating: nil, count: index)

			for try await (offset, value) in group {
				results[offset] = value
			}

				// All tasks completed; force unwrap is safe
			return results.map { $0! }
		}
	}
}
extension Sequence {
	func map<Transformed>(
		priority: TaskPriority? = nil,
		_ transform: @escaping @Sendable (Element) async throws -> Transformed
	) async rethrows -> [Transformed] {
		try await withThrowingTaskGroup(of: (Int, Transformed).self) { group in
			var index = 0
			for element in self {
				let currentIndex = index
				index += 1

				group.addTask(priority: priority) {
					try await (currentIndex, transform(element))
				}
			}

			var results: [Transformed?] = Array(repeating: nil, count: index)

			for try await (offset, value) in group {
				results[offset] = value
			}

				// All tasks have completed; force unwrap is safe here.
			return results.map { $0! }
		}
	}
}
