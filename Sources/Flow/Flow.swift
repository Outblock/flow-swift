import AuthenticationServices
import Combine
import GRPC
import NIO
import SafariServices

public final class Flow {
    public static let shared = Flow()

    public var config = Flow.Config()

    @Published var currentUser: Flow.User? = nil

    private let api = API()

    internal let defaultUserAgent = "Flow SWIFT SDK"

    internal var defaultChainId = ChainId.mainnet

    private lazy var defaultAddressRegistry = AddressRegistry()

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Back Channel

    let service: [Service]? = nil

    public func config(appName: String,
                       appIcon: String,
                       walletNode: String,
                       accessNode: String,
                       scope: String,
                       authn: String) {
        _ = config.put(key: .wallet, value: walletNode)
            .put(key: .accessNode, value: accessNode)
            .put(key: .title, value: appName)
            .put(key: .icon, value: appIcon)
            .put(key: .icon, value: appIcon)
            .put(key: .scope, value: scope)
            .put(key: .authn, value: authn)
    }

    public func unauthenticate() {
        // TODO: implement this
    }

    public func reauthenticate() {
        // TODO: implement this
    }

    public func preauthz() -> Future<AuthnResponse, Error> {
        return Future { [weak self] _ in
            guard let self = self, let currentUser = self.currentUser else { return }
            guard currentUser.loggedIn else { return }

            if let service = currentUser.services?.first(where: { service in
                service.type == .preAuthz
            }) {
                self.api.execHttpPost(url: service.endpoint)
//                call.whenSuccess { model in
//                    print(model)
//                    promise(.success(model))
//                }
//
//                call.whenFailure { error in
//                    print(error)
//                    promise(.failure(error))
//                }
            }
        }
    }

    public func authz() {
        // TODO: implement this
    }

    public func authenticate() -> Future<AuthnResponse, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            guard let endpoint = self.config.get(key: .authn) else {
                return promise(.failure(FlowError.urlEmpty))
            }
            showLoading()
            self.api.execHttpPost(url: endpoint)
                .receive(on: DispatchQueue.main)
                .sink { _ in
                    SafariWebViewManager.dismiss()
                } receiveValue: { _ in
                    SafariWebViewManager.dismiss()
                }.store(in: &self.cancellables)
        }
    }

    private func buildUser(authn: AuthnResponse) -> Flow.User? {
        guard let address = authn.data?.addr else { return nil }
        return Flow.User(addr: Flow.Address(hex: address),
                         loggedIn: true,
                         services: authn.data?.services)
    }

    // MARK: - AccessAPI

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
