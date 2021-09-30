import AuthenticationServices
import Combine
import GRPC
import NIO
import SafariServices

public let flow = Flow.shared

public final class Flow {
    public static let shared = Flow()

    internal let defaultUserAgent = "Flow SWIFT SDK"

    public private(set) var defaultChainID = ChainID.mainnet
    public private(set) var accessAPI: AccessAPI

    init() {
        accessAPI = AccessAPI(chainID: defaultChainID)
    }

    // MARK: - AccessAPI

    public func configure(chainID: ChainID) {
        defaultChainID = chainID
        accessAPI = createAccessAPI(chainID: defaultChainID)
    }

    public func createAccessAPI(chainID: ChainID) -> AccessAPI {
        return AccessAPI(chainID: chainID)
    }
}
