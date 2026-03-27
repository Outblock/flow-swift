	// FlowAccount.swift

import BigInt
import Foundation

public extension Flow {
		/// The data structure of account in Flow blockchain
	struct Account:Sendable, Codable {
		public let address: Address
		public let balance: BigInt?
		public var keys: [AccountKey]
		public var contracts: [String: Code]?

		public init(
			address: Flow.Address,
			balance: BigInt? = nil,
			keys: [Flow.AccountKey],
			contracts: [String: Flow.Code]? = nil
		) {
			self.address = address
			self.balance = balance
			self.keys = keys
			self.contracts = contracts
		}

		private enum CodingKeys: String, CodingKey {
			case address
			case balance
			case keys
			case contracts
		}

		public init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			address = try container.decode(Flow.Address.self, forKey: .address)
			balance = try? container.decodeFlexible(
				[String.self, BigInt.self],
				as: BigInt.self,
				forKey: .balance
			)
			keys = try container.decode([Flow.AccountKey].self, forKey: .keys)
			contracts = try? container.decode([String: Flow.Code].self, forKey: .contracts)
		}
	}

		/// The data structure of account key in flow account
	struct AccountKey: Codable, Sendable {
		public var index: Int = -1
		public let publicKey: PublicKey

			/// Use Flow’s crypto enums, not NIO TLS ones.
		public let signAlgo: Flow.SignatureAlgorithm
		public let hashAlgo: Flow.HashAlgorithm

		public let weight: Int
		public var sequenceNumber: Int64 = -1
		public var revoked: Bool = false

		enum CodingKeys: String, CodingKey {
			case index
			case publicKey
			case signAlgo = "signingAlgorithm"
			case hashAlgo = "hashingAlgorithm"
			case weight
			case sequenceNumber
			case revoked
		}

		public init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			index = try container.decodeFlexible(
				[String.self, Int.self],
				as: Int.self,
				forKey: .index
			)
			publicKey = try container.decode(Flow.PublicKey.self, forKey: .publicKey)
			signAlgo = try container.decode(Flow.SignatureAlgorithm.self, forKey: .signAlgo)
			hashAlgo = try container.decode(Flow.HashAlgorithm.self, forKey: .hashAlgo)
			weight = try container.decodeFlexible(
				[String.self, Int.self],
				as: Int.self,
				forKey: .weight
			)
			sequenceNumber = try container.decodeFlexible(
				[String.self, Int64.self],
				as: Int64.self,
				forKey: .sequenceNumber
			)
			revoked = try container.decode(Bool.self, forKey: .revoked)
		}

		public init(
			index: Int = -1,
			publicKey: Flow.PublicKey,
			signAlgo: Flow.SignatureAlgorithm,
			hashAlgo: Flow.HashAlgorithm,
			weight: Int,
			sequenceNumber: Int64 = -1,
			revoked: Bool = false
		) {
			self.index = index
			self.publicKey = publicKey
			self.signAlgo = signAlgo
			self.hashAlgo = hashAlgo
			self.weight = weight
			self.sequenceNumber = sequenceNumber
			self.revoked = revoked
		}

			// Explicit Encodable conformance to silence synthesis diagnostics.
		public func encode(to encoder: Encoder) throws {
			var container = encoder.container(keyedBy: CodingKeys.self)
			try container.encode(index, forKey: .index)
			try container.encode(publicKey, forKey: .publicKey)
			try container.encode(signAlgo, forKey: .signAlgo)
			try container.encode(hashAlgo, forKey: .hashAlgo)
			try container.encode(weight, forKey: .weight)
			try container.encode(sequenceNumber, forKey: .sequenceNumber)
			try container.encode(revoked, forKey: .revoked)
		}

			/// Encode the account key with RLP encoding
		public var encoded: Data? {
			let encodeList: [Any] = [publicKey.bytes.data, signAlgo.code, hashAlgo.code, weight]
			return RLP.encode(encodeList)
		}
	}
}
