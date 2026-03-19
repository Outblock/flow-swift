import Foundation

	/// Protocol for type-safe Cadence script loading
protocol CadenceLoaderProtocol {
	var directory: String { get }
	var filename: String { get }
}

extension CadenceLoaderProtocol {
	var directory: String {
		String(describing: type(of: self))
	}
}

	/// Central loader with category-based organization
public class CadenceLoader {
	public enum Category {}

	static let subdirectory = "CommonCadence"

		/// Load script from bundle with type safety
	static func load(name: String, directory: String = "") throws -> String {
		guard let url = Bundle.module.url(
			forResource: name,
			withExtension: "cdc",
			subdirectory: "\(CadenceLoader.subdirectory)/\(directory)"
		) else {
			throw Flow.FError.scriptNotFound(name: name, directory: directory)
		}
		return try String(contentsOf: url, encoding: .utf8)
	}

	static func load(_ path: CadenceLoaderProtocol) throws -> String {
		let name = path.filename
		let directory = path.directory
		return try load(name: name, directory: directory)
	}
}
