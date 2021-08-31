import Combine
import GRPC
import NIO
import SafariServices

public class Flow {
    public static let shared = Flow()

    public var config = Flow.Config()

    let api = FlowAPI()

    let defaultUserAgent = "Flow SWIFT SDK"

    var defaultChainId = ChainId.mainnet

    lazy var defaultAddressRegistry = AddressRegistry()

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Back Channel

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

    public func authn() -> Future<AuthnResponse, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            guard let endpoint = self.config.get(key: .authn) else {
                return promise(.failure(FlowError.urlEmpty))
            }
            showLoading()
            let call = self.api.authn(url: endpoint)
            call.whenSuccess { model in
                guard let pollingEndpoint = model.updates?.endpoint else {
                    promise(.failure(FlowError.urlEmpty))
                    return
                }
                self.authnPolling(url: pollingEndpoint).sink { response in
                    promise(.success(response))
                }.store(in: &self.cancellables)

                DispatchQueue.main.async {
                    hideLoading {
                        let safariVC = SFSafariViewController(url: URL(string: model.local!.endpoint)!)
                        safariVC.modalPresentationStyle = .formSheet
                        UIApplication.shared.topMostViewController?.present(safariVC, animated: true, completion: nil)
                    }
                }
            }

            call.whenFailure { error in
                print(error)
                promise(.failure(error))
            }
        }
    }

    public func authnPolling(url: String) -> Future<AuthnResponse, Never> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            self.api.authnPolling(url: url, repeatTimeInterval: .seconds(2)) { result in
                DispatchQueue.main.async {
                    UIApplication.shared.topMostViewController?.dismiss(animated: true, completion: nil)
                    promise(.success(result))
                }
            }
        }
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
