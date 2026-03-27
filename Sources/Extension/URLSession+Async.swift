/**
 *  AsyncCompatibilityKit
 *  Copyright (c) John Sundell 2021
 *  MIT license, see LICENSE.md file for details
 */
	//  Edited for Swift 6 concurrency & actors by Nicholas Reich on 2026-03-19.

import Foundation
import SwiftUI

private final class DataTaskBox: @unchecked Sendable {
	var task: URLSessionDataTask?
	init(task: URLSessionDataTask? = nil) {
		self.task = task
	}
}

extension URLSession {
	func data(for request: URLRequest) async throws -> (Data, URLResponse) {
		let box = DataTaskBox()

		let onCancel: @Sendable () -> Void = {
			box.task?.cancel()
		}

		return try await withTaskCancellationHandler(
			operation: {
				try await withCheckedThrowingContinuation { continuation in
					box.task = self.dataTask(with: request) { data, response, error in
						if let error {
							continuation.resume(throwing: error)
						} else if let data, let response {
							continuation.resume(returning: (data, response))
						} else {
							continuation.resume(throwing: URLError(.unknown))
						}
					}
					box.task?.resume()
				}
			},
			onCancel: {
				onCancel()
			}
		)
	}
}

	// If you want the URL-based convenience as well:

	 @available(
	     iOS,
	     deprecated: 15.0,
	     message: "AsyncCompatibilityKit is only useful when targeting iOS versions earlier than 15"
	 )
	 public extension URLSession {
	     func data(from url: URL) async throws -> (Data, URLResponse) {
	         try await data(for: URLRequest(url: url))
	     }
	 }
