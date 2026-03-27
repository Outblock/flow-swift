	//
	//  Signer.swift
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
	//

import Foundation

public extension Flow {

		/// Public key used for Flow accounts and signers.
		/// Backed by raw 64‑byte data (uncompressed x/y concatenation for ECDSA).
	struct PublicKey: FlowEntity, Equatable, Codable, Sendable {
		public var data: Data

		public init(hex: String) {
			self.data = hex.hexValue.data
		}

		public init(data: Data) {
			self.data = data
		}

		public init(bytes: [UInt8]) {
			self.data = Data(bytes)
		}

		enum CodingKeys: CodingKey {
			case data
		}

		public init(from decoder: Decoder) throws {
			let container = try decoder.singleValueContainer()

				// Accept either raw 64‑byte Data or a hex string of length 64 bytes.
			if let decodeData = try? container.decode(Data.self), decodeData.count == 64 {
				self.data = decodeData
			} else {
				let hexString = try container.decode(String.self)
				let raw = hexString.hexValue
				guard raw.count == 64 else {
					throw DecodingError.dataCorrupted(
						DecodingError.Context(
							codingPath: decoder.codingPath,
							debugDescription: "Invalid data format for Flow.PublicKey; expected 64 bytes."
						)
					)
				}
				self.data = raw.data
			}
		}

		public func encode(to encoder: Encoder) throws {
			var container = encoder.singleValueContainer()
			try container.encode(data)
		}
	}

		/// On‑chain code blob (e.g. smart contract or script) encoded as Data.
	struct Code: FlowEntity, Equatable, Codable, Sendable {
		public var  data: Data

			/// UTF‑8 text representation of the code.
		public var text: String {
			String( data: data, encoding: .utf8) ?? ""
		}

		public init( data: Data) {
			self.data = data
		}

		public init(from decoder: Decoder) throws {
			let container = try decoder.singleValueContainer()
			let utfString = try container.decode(String.self)

				// Prefer base64 decoding; fall back to raw UTF‑8 string bytes.
			if let decoded = Data(base64Encoded: utfString) {
				self.data = decoded
			} else {
				self.data = utfString.data(using: .utf8) ?? Data()
			}
		}

		public func encode(to encoder: Encoder) throws {
			var container = encoder.singleValueContainer()
				// Encode as base64 string for compact transfer.
			let base64 = data.base64EncodedString()
			try container.encode(base64)
		}
	}
}

extension Flow.PublicKey: CustomStringConvertible {
	public var description: String { data.hexValue }
}

extension Flow.Code: CustomStringConvertible {
	public var description: String { text }
}

