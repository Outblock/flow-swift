import GRPC
import NIO

public class Flow {
    static let shared = Flow()

    let defaultUserAgent = "Flow SWIFT SDK"

    var defaultChainId = ChainId.mainnet

    lazy var defaultAddressRegistry = AddressRegistry()

    func configureDefaults(chainId: ChainId, addressRegistry: AddressRegistry) {
        defaultChainId = chainId
        defaultAddressRegistry = addressRegistry
    }

    func newAccessApi(chainId: ChainId) -> FlowAccessAPI? {
        guard let networkNode = chainId.defaultNode else {
            return nil
        }
        return newAccessApi(host: networkNode.gRPCNode, port: networkNode.port)
    }

    func newAccessApi(host: String, port: Int = 9000, secure: Bool = false) -> FlowAccessAPI {
        let config = channelConfig(host: host, port: port, secure: secure, userAgent: defaultUserAgent)
        return FlowAccessAPI(config: config)
    }

    func newAccessApi(host: String, port: Int = 9000, secure: Bool = false, userAgent: String) -> FlowAccessAPI {
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
