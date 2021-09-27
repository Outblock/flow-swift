import AuthenticationServices
import Combine
import GRPC
import NIO
import SafariServices

public let flow = Flow.shared

public final class Flow {
    public static let shared = Flow()

    internal let defaultUserAgent = "Flow SWIFT SDK"

    internal var defaultChainId = ChainId.mainnet

    // MARK: - AccessAPI

    func configureDefaults(chainId: ChainId) {
        defaultChainId = chainId
    }

    func newAccessApi(chainId: ChainId) -> FlowAccessAPI? {
        guard let networkNode = chainId.defaultNode else {
            return nil
        }
        return newAccessApi(host: networkNode.gRPCNode, port: networkNode.port)
    }

    func newAccessApi(host: String, port: Int = 9000, secure: Bool = true) -> FlowAccessAPI {
        let config = channelConfig(host: host, port: port, secure: secure, userAgent: defaultUserAgent)
        return FlowAccessAPI(config: config)
    }

    func newAccessApi(host: String, port: Int = 9000, secure: Bool = true, userAgent: String) -> FlowAccessAPI {
        let config = channelConfig(host: host, port: port, secure: secure, userAgent: userAgent)
        return FlowAccessAPI(config: config)
    }

    func channelConfig(host: String, port: Int, secure _: Bool, userAgent _: String) -> ClientConnection.Configuration {
        // TODO: add secure and userAgent
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        return ClientConnection.Configuration.default(target: ConnectionTarget.hostAndPort(host, port),
                                                      eventLoopGroup: eventLoopGroup)
    }
}
