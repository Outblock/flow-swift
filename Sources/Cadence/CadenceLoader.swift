	//
	//  CadenceLoader.swift
	//  Flow
	//
	//  Created by Nicholas Reich on 3/21/26.
	//

import Foundation

	// Global actor for Cadence loading
@globalActor
public actor CadenceLoaderActor {
	public static let shared = CadenceLoaderActor()
}

	// MARK: - Protocol

public protocol CadenceLoaderProtocol: Sendable {
	var directory: String { get }
	var filename: String { get }
}

public extension CadenceLoaderProtocol {
	var directory: String {
		String(describing: type(of: self))
	}
}

	// MARK: - Loader

	/// Utility type for loading Cadence scripts from resources
@CadenceLoaderActor
public final class CadenceLoader: @unchecked Sendable {

	public enum Category: Sendable {}

	public static let subdirectory = "CommonCadence"

		/// Load a Cadence script from the module bundle.
		/// - Parameters:
		///   - name: Name of the Cadence file without extension.
		///   - directory: Directory under `CommonCadence`.
		/// - Returns: Cadence source.
	public static func load(
		name: String,
		directory: String = ""
	) throws -> String {
		let subdirPath = directory.isEmpty
		? CadenceLoader.subdirectory
		: "\(CadenceLoader.subdirectory)/\(directory)"

		guard let url = Bundle.module.url(
			forResource: name,
			withExtension: "cdc",
			subdirectory: subdirPath
		) else {
			throw Flow.FError.scriptNotFound(name: name, directory: directory)
		}

		return try String(contentsOf: url, encoding: .utf8)
	}

	public static func load(_ path: CadenceLoaderProtocol) throws -> String {
		try load(name: path.filename, directory: path.directory)
	}
}

