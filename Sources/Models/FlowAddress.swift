	//
	//  FlowAddress
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
	//  Edited for Swift 6 concurrency & actors by Nicholas Reich on 2026-03-19.
import SwiftUI

	/// Flow Address Model
	///
	/// Represents account addresses on the Flow blockchain.
	/// Handles address formatting, validation, and conversion.
	///
	/// Features:
	/// - Hex string parsing
	/// - Address validation
	/// - String representation
	/// - Equatable comparison
	///
	/// Example usage:
	/// ```swift
	/// let address = Flow.Address(hex: "0x1234")
	/// let account = try await flow.getAccountAtLatestBlock(address: address)
	/// ```

import Foundation

public extension Flow {

		/// Flow Address Model
		///
		/// Represents account addresses on the Flow blockchain.
		/// Handles address formatting, validation, and conversion.
	struct Address: FlowEntity, Equatable, Hashable, Codable, CustomStringConvertible {

			/// Flow address size in bytes.
		public static let byteLength = 8

			/// Raw address bytes.
		public var data: Data

			/// Hexadecimal string representation with `0x` prefix.
		public var hex: String {
			data.hexValue.addHexPrefix()
		}

			// MARK: - Initializers

		public init(hex: String) {
			self.init( data: hex.stripHexPrefix().hexValue.data)
		}

		public init(_ hex: String) {
			self.init( data: hex.stripHexPrefix().hexValue.data)
		}

		public init(data: Data) {
			if data.bytes.count == Flow.Address.byteLength {
				self.data = data
			} else {
				self.data = data
					.paddingZeroLeft(blockSize: Flow.Address.byteLength)
					.prefix(Flow.Address.byteLength)
			}
		}

		 public init(bytes: [UInt8]) {
			self.init(data: bytes.data)
		}

			// MARK: - Codable

		public init(from decoder: Decoder) throws {
			let container = try decoder.singleValueContainer()
			let string = try container.decode(String.self)
			self.init(hex: string)
		}

		public func encode(to encoder: Encoder) throws {
			var container = encoder.singleValueContainer()
			try container.encode(hex.addHexPrefix())
		}

			// MARK: - CustomStringConvertible

		public var description: String {
			hex.addHexPrefix()
		}
	}
}
