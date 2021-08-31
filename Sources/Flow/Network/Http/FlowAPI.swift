//
//  File.swift
//
//
//  Created by lmcmz on 29/8/21.
//

import AsyncHTTPClient
import Foundation
import NIO

public class FlowAPI {
    let client = HTTPClient(eventLoopGroupProvider: .createNew)

    func authn(url: String) -> EventLoopFuture<AuthnResponse> {
        let eventLoop = EmbeddedEventLoop()
        let promise = eventLoop.makePromise(of: AuthnResponse.self)
        guard let url = URL(string: url) else {
            promise.fail(FlowError.urlInvaild)
            return promise.futureResult
        }

        guard var request = try? HTTPClient.Request(url: url, method: .POST) else {
            promise.fail(FlowError.urlInvaild)
            return promise.futureResult
        }
        request.headers.add(name: "User-Agent", value: Flow.shared.defaultUserAgent)

        client.execute(request: request).whenComplete { result in
            switch result {
            case let .success(response):
                let decodeModel: AuthnResponse? = decodeToModel(body: response.body)
                guard let model = decodeModel else {
                    return
                }
                promise.succeed(model)
            case let .failure(error):
                promise.fail(error)
            }
        }
        return promise.futureResult
    }

    func authnPolling(url: String,
                      repeatTimeInterval: DispatchTimeInterval,
                      callback: @escaping ((AuthnResponse) -> Void)) {
        let queue = DispatchQueue.global(qos: .background)
        let timer = DispatchSource.makeTimerSource(flags: [], queue: queue)
        timer.schedule(deadline: .now(), repeating: repeatTimeInterval, leeway: .seconds(1))
        timer.setEventHandler(handler: {
            self.authn(url: url).whenSuccess { result in
                print("authnPolling -> \(result.status)")
                if result.status == .approved {
                    timer.cancel()
                    callback(result)
                }
            }
        })
        timer.resume()
    }

    //    func authn(url: String) -> Future<AuthnResponse,  Error> {
    //        return Future { promise in
    //            guard let url = URL(string: url) else {
    //                promise(.failure(FlowError.urlInvaild))
    //                return
    //            }
    //
    //            guard var request = try? HTTPClient.Request(url: url, method: .POST) else {
    //                promise(.failure(FlowError.urlInvaild))
    //                return
    //            }
    //            request.headers.add(name: "User-Agent", value: Flow.shared.defaultUserAgent)
    //
    //            let client = HTTPClient(eventLoopGroupProvider: .createNew)
    //            client.execute(request: request).whenComplete { result in
    //                switch result {
    //                case let .success(response):
    //                    let decodeModel: AuthnResponse? = decodeToModel(body: response.body)
    //                    guard let model = decodeModel else {
    //                        promise(.failure(FlowError.decodeFailure))
    //                        return
    //                    }
    //                    promise(.success(model))
    //                case let .failure(error):
    //                    promise(.failure(error))
    //                }
    //            }
    //        }
    //    }

    //    func authnPolling(url: String,
    //        repeatTimeInterval: DispatchTimeInterval,
    //                      callback: @escaping ((AuthnResponse) -> Void)) {
    //        let queue = DispatchQueue.global(qos: .background)
    //        let timer = DispatchSource.makeTimerSource(flags: [], queue: queue)
    //        timer.schedule(deadline: .now(), repeating: repeatTimeInterval, leeway: .seconds(1))
    //        timer.setEventHandler(handler: {
    //            self.authn(url: url).sink { completion in
    //                if case let .failure(error) = completion {
    //                    // TODO: Handle error
    //                    print(error)
    //                }
    //            } receiveValue: { result in
    //                if result.status == .approved {
    //                    timer.cancel()
    //                    callback(result)
    //                }
    //            }.store(in: &self.cancellables)
    //
    //        })
    //        timer.resume()
    //    }
    // }
}

func decodeToModel<T: Decodable>(body: ByteBuffer?) -> T? {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase

//    do {
//        try decoder.decode(T.self, from: body!)
//    } catch {
//        print(error)
//    }

    guard let data = body,
        let model = try? decoder.decode(T.self, from: data) else {
        return nil
    }

    return model
}
