//
//  NFTCatalogTests.swift
//
//
//  Created by Hao Fu on 20/8/2022.
//

import Flow
import XCTest

final class NFTCatalogTests: XCTestCase {
    struct NFTCatalog: Codable {
        let contractAddress: String
        let contractName: String
        let collectionDisplay: CollectionDislay

        struct CollectionDislay: Codable {
            let name, collectionDisplayDescription: String
            let externalURL: ExternalURL
            let squareImage, bannerImage: Image
            let socials: SocialLinks?

            enum CodingKeys: String, CodingKey {
                case name
                case collectionDisplayDescription = "description"
                case externalURL, squareImage, bannerImage, socials
            }

            struct SocialLinks: Codable {
                let twitter, discord, instagram: ExternalURL?
                let mastodon: ExternalURL?
            }

            // MARK: - Image

            struct Image: Codable {
                let file: ExternalURL
                let mediaType: String
            }

            // MARK: - ExternalURL

            struct ExternalURL: Codable {
                let url: String
            }
        }
    }

    func testNFTCatalogAA() async throws {
        flow.configure(chainID: .testnet)
        let response = try await flow.accessAPI.executeScriptAtLatestBlock(
            script: .init(text: """
            import NFTCatalog from 0x324c34e1c517e4db

            pub fun main(): {String : NFTCatalog.NFTCatalogMetadata} {
                return NFTCatalog.getCatalog()
            }

            """)
        )
        let dict = try! response.decode()
        print(dict)
    }

    func testIn2tType() async throws {
        flow.configure(chainID: .mainnet)
        let cadence = """
        import NFTCatalog from 0x49a7cda3a1eecc29

        pub fun main(): NFTCatalog.NFTCatalogMetadata? {
            return NFTCatalog.getCatalog()["Flunks"]
        }
        """
        let script = Flow.Script(text: cadence)
        let result = try await flow.accessAPI.executeScriptAtLatestBlock(script: script).decode()
//        XCTAssertEqual(result?.count, 3)
//        XCTAssertEqual(result?.first, 1)
        print(result)
    }

    func testNFTCatalog() async throws {
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
                let count = NFTRetrieval.getNFTCountFromCap(collectionIdentifier : key, collectionCap : collectionCap)
                if count != 0 {
                    items[key] = count
                }
            }

            return items
        }
        """
        let script = Flow.Script(text: cadence)
        let result = try await flow.accessAPI.executeScriptAtLatestBlock(script: script, arguments: [.address(.init(hex: "0xfd182fc965709394"))]).decode()
//        XCTAssertEqual(result?.count, 3)
//        XCTAssertEqual(result?.first, 1)
        print(result)
    }

//    func testNFTCatalog2() async throws {
//        flow.configure(chainID: .mainnet)
//        let cadence = """
//        import MetadataViews from 0x1d7e57aa55817448
//        import NFTCatalog from 0x49a7cda3a1eecc29
//        import NFTRetrieval from 0x49a7cda3a1eecc29
//
//        pub fun main(ownerAddress: Address) : [MetadataViews.NFTView] {
//            let catalog = NFTCatalog.getCatalog()
//            let account = getAuthAccount(ownerAddress)
//            let data : {String : [MetadataViews.NFTView] } = {}
//
//            for key in catalog.keys {
//                let value = catalog[key]!
//                let tempPathStr = "catalog".concat(key)
//                let tempPublicPath = PublicPath(identifier: tempPathStr)!
//                account.link<&{MetadataViews.ResolverCollection}>(
//                    tempPublicPath,
//                    target: value.collectionData.storagePath
//                )
//                let collectionCap = account.getCapability<&AnyResource{MetadataViews.ResolverCollection}>(tempPublicPath)
//                if !collectionCap.check() {
//                    continue
//                }
//                let views = NFTRetrieval.getNFTViewsFromCap(collectionIdentifier : key, collectionCap : collectionCap)
//
//                return views
//            }
//        }
//        """
//        let script = Flow.Script(text: cadence)
//        let result = try await flow.accessAPI.executeScriptAtLatestBlock(script: script, arguments: [.address(.init(hex: "0x01d63aa89238a559"))]).decode()
    ////        XCTAssertEqual(result?.count, 3)
    ////        XCTAssertEqual(result?.first, 1)
//        print(result)
//    }

    func testNFTCatalogIDs() async throws {
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

                let ids = NFTRetrieval.getNFTIDsFromCap(collectionIdentifier : key, collectionCap : collectionCap)

                if ids.length > 0 {
                    items[key] = ids
                }
            }
            return items

        }
        """
        let script = Flow.Script(text: cadence)
        let result: [String: [Int]] = try await flow.accessAPI.executeScriptAtLatestBlock(script: script, arguments: [.address(.init(hex: "0x01d63aa89238a559"))]).decode()
//        XCTAssertEqual(result?.count, 3)
//        XCTAssertEqual(result?.first, 1)
        print(result)
    }
}
