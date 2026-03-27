	//  Edited for Swift 6 concurrency & actors by Nicholas Reich on 2026-03-19.

import Foundation

public extension Flow {
	struct Script: FlowEntity, Equatable, Sendable {
		public var data: Data

		public var text: String {
			String(data: data, encoding: .utf8) ?? ""
		}

		public init(text: String) {
			data = text.data(using: .utf8) ?? Data()
		}

		public init(data: Data) {
			self.data = data
		}

		public init(bytes: [UInt8]) {
			data = Data(bytes)
		}
	}

	struct ScriptResponse: FlowEntity, Equatable, Codable, Sendable {
		public var data: Data
		public var fields: Argument?

		public init(data: Data) {
			self.data = data
			fields = try? JSONDecoder().decode(Flow.Argument.self, from: data)
		}

		public init(from decoder: Decoder) throws {
			let container = try decoder.singleValueContainer()
			let string = try container.decode(String.self)
			data = Data(base64Encoded: string) ?? string.data(using: .utf8) ?? Data()
			fields = try? JSONDecoder().decode(Flow.Argument.self, from: data)
		}
	}
}

extension Flow.ScriptResponse: FlowDecodable {
	public func decode() -> Any? {
		fields?.decode()
	}

	public func decode<T>(_ decodable: T.Type) throws -> T where T: Decodable {
		guard let result: T = try? fields?.decode(decodable) else {
			throw Flow.FError.decodeFailure
		}
		return result
	}

	public func decode<T>() throws -> T where T: Decodable {
		guard let result: T = try? fields?.decode() else {
			throw Flow.FError.decodeFailure
		}
		return result
	}
}

extension Flow.Script: CustomStringConvertible {
	public var description: String { text }
}

extension Flow.Script: Codable {
	enum CodingKeys: String, CodingKey {
		case data
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(text)
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let scriptString = try container.decode(String.self)
		data = Data(base64Encoded: scriptString) ?? scriptString.data(using: .utf8) ?? Data()
	}
}

extension Flow.ScriptResponse: CustomStringConvertible {
	public var description: String {
		guard let object = try? JSONSerialization.jsonObject(with: data),
				let jsonData = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted),
				let jsonString = String(data: jsonData, encoding: .utf8)
		else {
			return ""
		}
		return jsonString
	}
}
