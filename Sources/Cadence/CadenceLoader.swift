import Foundation

protocol CadenceLoaderProtocol {
    var directory: String { get }
    var filename: String { get }
}

/// Utility class for loading Cadence scripts from files
public class CadenceLoader {
    
    public enum Category {}
    
    static let subdirectory = "CommonCadence"
    
    /// Load a Cadence script from the bundle
    /// - Parameter name: Name of the Cadence file without extension
    /// - Parameter directory: Directory containing the Cadence file
    /// - Returns: Content of the Cadence file
    /// - Throws: Error if file cannot be found or read
    static func load(name: String, directory: String = "") throws -> String {
        guard let url = Bundle.module.url(forResource: name, withExtension: "cdc", subdirectory: "\(CadenceLoader.subdirectory)/\(directory)") else {
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

extension CadenceLoader.Category {
    
    enum EVM: String, CaseIterable, CadenceLoaderProtocol {
        case getAddress = "get_addr"
        
        var directory: String {
            "EVM"
        }
        
        var filename: String {
            rawValue
        }
    }
    
    public enum Child: String, CaseIterable, CadenceLoaderProtocol {
        case getChildAddress = "get_child_addresses"
        case getChildAccountMeta = "get_child_account_meta"
        
        var directory: String {
            "Child"
        }
        
        var filename: String {
            rawValue
        }
    }
}
