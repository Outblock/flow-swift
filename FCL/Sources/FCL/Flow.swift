import AuthenticationServices
import Combine
import FlowFoundation
import SafariServices

public final class FCL {
    public static let shared = FCL()

    public var config = FCL.Config()

    @Published var currentUser: User? = nil

    private let api = API()

    internal let defaultUserAgent = "Flow SWIFT SDK"

    internal var defaultChainId = Flow.ChainId.mainnet

    private lazy var defaultAddressRegistry = AddressRegistry()

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

    public func unauthenticate() {
        // TODO: implement this
        currentUser = nil
    }

    public func reauthenticate() -> Future<AuthnResponse, Error> {
        // TODO: implement this
        unauthenticate()
        return authenticate()
    }

    public func preauthz() -> Future<AuthnResponse, Error> {
        return Future { [weak self] promise in
            guard let self = self, let currentUser = self.currentUser, currentUser.loggedIn else {
                promise(.failure(Flow.FError.unauthenticated))
                return
            }

            guard let service = self.serviceOfType(services: currentUser.services, type: .preAuthz) else {
                return
            }

            self.api.execHttpPost(url: service.endpoint)
                .sink { completion in
                    if case let .failure(error) = completion {
                        promise(.failure(error))
                    }
                } receiveValue: { model in
                    promise(.success(model))
                }
                .store(in: &self.cancellables)
        }
    }

    public func resolvePreAuthz(reponse: AuthnResponse) -> Future<AuthnResponse, Error> {
        return Future { [weak self] _ in
            guard let self = self else { return }

            var axs: [(role: String, az: Service)] = []
            if let proposer = reponse.data?.proposer {
                axs.append(("PROPOSER", proposer))
            }

            if let payers = reponse.data?.payer {
                payers.forEach { payer in
                    axs.append(("PAYER", payer))
                }
            }

            if let authorizations = reponse.data?.authorization {
                authorizations.forEach { authorization in
                    axs.append(("AUTHORIZER", authorization))
                }
            }

            axs.map { _, az in
                let tempId = ([az.identity?.address, "\(az.identity?.keyId)"] as [String?]).compactMap { $0 }.joined(separator: "|")
                let addr = az.identity?.address
                let keyId = az.identity?.keyId
            }
        }
    }

    public func authorization() -> Future<AuthnResponse, Error> {
        return Future { [weak self] promise in
            guard let self = self, let currentUser = self.currentUser, currentUser.loggedIn else {
                promise(.failure(Flow.FError.unauthenticated))
                return
            }

            guard let service = self.serviceOfType(services: currentUser.services, type: .authz) else {
                return
            }

            self.api.execHttpPost(url: service.endpoint)
                .sink { completion in
                    if case let .failure(error) = completion {
                        promise(.failure(error))
                    }
                } receiveValue: { model in
                    promise(.success(model))
                }
                .store(in: &self.cancellables)
        }
    }

    public func authenticate() -> Future<AuthnResponse, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            guard let endpoint = self.config.get(key: .authn) else {
                return promise(.failure(Flow.FError.urlEmpty))
            }
            showLoading()
            self.api.execHttpPost(url: endpoint)
                .receive(on: DispatchQueue.main)
                .sink { _ in
                    SafariWebViewManager.dismiss()
                } receiveValue: { model in
                    self.currentUser = self.buildUser(authn: model)
                    promise(.success(model))
                    SafariWebViewManager.dismiss()
                }.store(in: &self.cancellables)
        }
    }

    // MARK: - Util

    private func buildUser(authn: AuthnResponse) -> User? {
        guard let address = authn.data?.addr else { return nil }
        return User(addr: Flow.Address(hex: address),
                    loggedIn: true,
                    services: authn.data?.services)
    }

    private func serviceOfType(services: [Service]?, type: Service.Name) -> Service? {
        return services?.first(where: { service in
            service.type == type
        })
    }
}
