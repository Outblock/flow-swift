//
//  File.swift
//
//
//  Created by lmcmz on 29/8/21.
//

import AsyncHTTPClient
import Combine
import Foundation
import NIO
import NIOHTTP1

extension Flow {
    public class API {
        private var cancellables = Set<AnyCancellable>()
        let client = HTTPClient(eventLoopGroupProvider: .createNew)

        // TODO: Improve this
        private var canContinue = true

        func fetchService<T>(url: URL, method: HTTPMethod) -> EventLoopFuture<T> where T: Decodable {
            let eventLoop = EmbeddedEventLoop()
            let promise = eventLoop.makePromise(of: T.self)
            guard var request = try? HTTPClient.Request(url: url, method: method)
            else {
                promise.fail(Flow.FError.urlInvaild)
                return promise.futureResult
            }
            request.headers.add(name: "User-Agent", value: Flow.shared.defaultUserAgent)

            let call = client.execute(request: request)
            call.whenSuccess { response in
                let decodeModel: T? = decodeToModel(body: response.body)
                guard let model = decodeModel else {
                    promise.fail(Flow.FError.decodeFailure)
                    return
                }
                promise.succeed(model)
            }
            call.whenFailure { error in
                promise.fail(error)
            }
            return promise.futureResult
        }

        func fetchService<T, V>(url: URL, method: HTTPMethod, body: V? = nil) -> EventLoopFuture<T> where T: Decodable, V: Encodable {
            let eventLoop = EmbeddedEventLoop()
            let promise = eventLoop.makePromise(of: T.self)
            guard let encodeModel = body, let data = try? JSONEncoder().encode(encodeModel) else {
                promise.fail(Flow.FError.encodeFailure)
                return promise.futureResult
            }
            guard var request = try? HTTPClient.Request(url: url, method: method, body: HTTPClient.Body.data(data))
            else {
                promise.fail(Flow.FError.urlInvaild)
                return promise.futureResult
            }
            request.headers.add(name: "User-Agent", value: Flow.shared.defaultUserAgent)

            let call = client.execute(request: request)
            call.whenSuccess { response in
                let decodeModel: T? = decodeToModel(body: response.body)
                guard let model = decodeModel else {
                    promise.fail(Flow.FError.decodeFailure)
                    return
                }
                promise.succeed(model)
            }
            call.whenFailure { error in
                promise.fail(error)
            }
            return promise.futureResult
        }

        func execHttpPost(url: String, method: HTTPMethod = .POST) -> Future<AuthnResponse, Error> {
            return Future { promise in

                guard let url = URL(string: url) else {
                    promise(.failure(Flow.FError.urlInvaild))
                    return
                }

                let call: EventLoopFuture<AuthnResponse> = self.fetchService(url: url, method: method)
                call.whenSuccess { result in
                    switch result.status {
                    case .approved:
                        promise(.success(result))
                    case .declined:
                        promise(.failure(Flow.FError.declined))
                    case .pending:
                        self.canContinue = true
                        guard let local = result.local, let updates = result.updates else { return }
                        SafariWebViewManager.openSafariWebView(service: local) {
                            self.canContinue = false
                        }
                        self.poll(service: updates, canContinue: self.canContinue).sink { completion in
                            // TODO: Handle special error
                            if case let .failure(error) = completion {
                                promise(.failure(error))
                            }
                        } receiveValue: { result in
                            promise(.success(result))
                        }.store(in: &self.cancellables)
                    }
                }
            }
        }

        func poll(service: Service, canContinue _: Bool) -> Future<AuthnResponse, Error> {
            return Future { promise in

                if !self.canContinue {
                    promise(.failure(Flow.FError.declined))
                    return
                }

                guard let url = URL(string: service.endpoint) else {
                    promise(.failure(Flow.FError.urlInvaild))
                    return
                }

                guard let method = service.method.http else {
                    promise(.failure(Flow.FError.generic))
                    return
                }

                let call: EventLoopFuture<AuthnResponse> = self.fetchService(url: url, method: method)

                call.whenSuccess { result in
                    print("polling ---> \(result.status.rawValue)")
                    switch result.status {
                    case .approved:
                        promise(.success(result))
                    case .declined:
                        // TODO: Need to discuss here, whether decline is an error case or not
                        promise(.success(result))
                    case .pending:
                        // TODO: Improve this
                        DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(500)) {
                            self.poll(service: service, canContinue: self.canContinue)
                                .sink { completion in
                                    if case let .failure(error) = completion {
                                        promise(.failure(error))
                                    }
                                } receiveValue: { result in
                                    promise(.success(result))
                                }
                                .store(in: &self.cancellables)
                        }
                    }
                }

                call.whenFailure { error in
                    promise(.failure(error))
                }
            }
        }
    }
}

func decodeToModel<T: Decodable>(body: ByteBuffer?) -> T? {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase

    do {
        _ = try decoder.decode(T.self, from: body!)
    } catch {
        print(error)
    }

    guard let data = body,
        let model = try? decoder.decode(T.self, from: data) else {
        return nil
    }

    return model
}

extension Flow.Service.Method {
    var http: HTTPMethod? {
        switch self {
        case .get:
            return .GET
        case .post:
            return .POST
        default: return nil
        }
    }
}
