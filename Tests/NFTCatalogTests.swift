	//
	//  NFTCatalogTests.swift
	//  FlowTests
	//
	//  Created by Hao Fu on 20/8/2022.
	//  Migrated to Swift Testing by Nicholas Reich on 2026-03-19.
	//

import Flow
import Foundation
import Testing

@Suite
struct NFTCatalogTests {
	struct NFTCatalog: Codable {
		let contractAddress: String
		let contractName: String
		let collectionDisplay: CollectionDisplay
	}

	struct CollectionDisplay: Codable {
		let name: String
		let collectionDisplayDescription: String
		let externalURL: ExternalURL
		let squareImage: Image
		let bannerImage: Image
		let socials: SocialLinks?

		enum CodingKeys: String, CodingKey {
			case name
			case collectionDisplayDescription = "description"
			case externalURL
			case squareImage
			case bannerImage
			case socials
		}
	}

	struct SocialLinks: Codable {
		let twitter: ExternalURL?
		let discord: ExternalURL?
		let instagram: ExternalURL?
		let mastodon: ExternalURL?
	}

	struct Image: Codable {
		let file: ExternalURL
		let mediaType: String
	}

	struct ExternalURL: Codable {
		let url: String
	}

	@Test(
		"NFTCatalog getCatalog on testnet returns metadata dictionary",
		.timeLimit(.seconds(60))
	)
	func nftCatalogTestnet() async throws {
		flow.configure(chainID: .testnet)
		let response = try await flow.accessAPI.executeScriptAtLatestBlock(
			script: .init(
				text: """
				import NFTCatalog from 0x324c34e1c517e4db
				
				pub fun main(): {String : NFTCatalog.NFTCatalogMetadata} {
					return NFTCatalog.getCatalog()
				}
				"""
			)
		)

		let dict: [String: NFTCatalog] = try response.decode()
		print(dict.keys.prefix(5))
		#expect(dict.isEmpty == false)
	}

	@Test(
		"NFTCatalog single collection metadata on mainnet",
		.timeLimit(.seconds(60))
	)
	func nftCatalogSingleCollection() async throws {
		flow.configure(chainID: .mainnet)
		let cadence = """
		import NFTCatalog from 0x49a7cda3a1eecc29
		
		pub fun main(): NFTCatalog.NFTCatalogMetadata? {
			return NFTCatalog.getCatalog()["Flunks"]
		}
		"""
		let script = Flow.Script(text: cadence)
		let result: NFTCatalog? = try await flow.accessAPI
			.executeScriptAtLatestBlock(script: script)
			.decode()
		print(result as Any)
		#expect(result != nil)
	}

	@Test(
		"NFTCatalog per-collection NFT counts",
		.timeLimit(.seconds(120))
	)
	func nftCatalogCounts() async throws {
		flow.configure(chainID: .mainnet)
		let cadence = """
		import MetadataViews from 0x1d7e57aa55817448
		import NFTCatalog from 0x49a7cda3a1eecc29
		import NFTRetrieval from 0x49a7cda3a1eecc29
		
		pub fun main(ownerAddress: Address) : {String : Number} {
			let catalog = NFTCatalog.getCatalog()
			let account = getAuthAccount(ownerAddress)
			let items : {String : Number} = {}
		
			for key in catalog.keys {
				let value = catalog[key]!
				let tempPathStr = "catalog".concat(key)
				let tempPublicPath = PublicPath(identifier: tempPathStr)!
				account.link<&{MetadataViews.ResolverCollection}>(
					tempPublicPath,
					target: value.collectionData.storagePath
				)
		
				let collectionCap = account.getCapability<&AnyResource{MetadataViews.ResolverCollection}>(tempPublicPath)
				if !collectionCap.check() {
					continue
				}
		
				let count = NFTRetrieval.getNFTCountFromCap(
					collectionIdentifier : key,
					collectionCap : collectionCap
				)
				if count != 0 {
					items[key] = count
				}
			}
		
			return items
		}
		"""
		let script = Flow.Script(text: cadence)
		let result: [String: Int] = try await flow.accessAPI
			.executeScriptAtLatestBlock(
				script: script,
				arguments: [.address(.init(hex: "0xfd182fc965709394"))]
			)
			.decode()

		print(result)
		#expect(result.isEmpty == false)
	}

	@Test(
		"NFTCatalog per-collection NFT IDs",
		.timeLimit(.seconds(120))
	)
	func nftCatalogIDs() async throws {
		flow.configure(chainID: .mainnet)
		let cadence = """
		import MetadataViews from 0x1d7e57aa55817448
		import NFTCatalog from 0x49a7cda3a1eecc29
		import NFTRetrieval from 0x49a7cda3a1eecc29
		
		pub fun main(ownerAddress: Address) : {String : [UInt64]} {
			let catalog = NFTCatalog.getCatalog()
			let account = getAuthAccount(ownerAddress)
		
			let items : {String : [UInt64]} = {}
		
			for key in catalog.keys {
				let value = catalog[key]!
				let tempPathStr = "catalogIDs".concat(key)
				let tempPublicPath = PublicPath(identifier: tempPathStr)!
				account.link<&{MetadataViews.ResolverCollection}>(
					tempPublicPath,
					target: value.collectionData.storagePath
				)
		
				let collectionCap = account.getCapability<&AnyResource{MetadataViews.ResolverCollection}>(tempPublicPath)
				if !collectionCap.check() {
					continue
				}
		
				let ids = NFTRetrieval.getNFTIDsFromCap(
					collectionIdentifier : key,
					collectionCap : collectionCap
				)
		
				if ids.length > 0 {
					items[key] = ids
				}
			}
		
			return items
		}
		"""
		let script = Flow.Script(text: cadence)
		let result: [String: [UInt64]] = try await flow.accessAPI
			.executeScriptAtLatestBlock(
				script: script,
				arguments: [.address(.init(hex: "0x01d63aa89238a559"))]
			)
			.decode()

		print(result)
		#expect(result.isEmpty == false)
	}
}
