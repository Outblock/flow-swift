	//
	//  FlowNIOWebSocketClient.swift
	//  Flow
	//

import Foundation
import NIOCore
import NIOPosix
import NIOHTTP1
import NIOWebSocket
@preconcurrency import NIOSSL

public enum FlowWebSocketUpgradeEvent {
	case upgraded
}
	/// NIO-based websocket client for Flow transaction status and topics.
public final class FlowNIOWebSocketClient: @unchecked Sendable {

		// MARK: - State

	private let group: EventLoopGroup
	private var channel: Channel?
	private let configActor: FlowConfigActor

	public init(
		group: EventLoopGroup? = nil,
		configActor: FlowConfigActor = .shared
	) {
		self.group = group ?? MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
		self.configActor = configActor
	}

	deinit {
		try? group.syncShutdownGracefully()
	}

		// MARK: - Connection

	public func connectIfNeeded() async throws {
		if let channel = channel, channel.isActive {
			return
		}

		let chainID =  await configActor.chainID
		guard let endpoint = chainID.defaultWebSocketNode, let url = endpoint.url else {
			throw Flow.FError.customError(msg: "No websocket endpoint for chainID \(chainID)")
		}

		channel = try await connectWebSocket(to: url)
	}

	public func disconnect() async {
		if let c = channel {
			_ = try? await c.close()
			channel = nil
		}
	}

		// MARK: - Subscription helpers

	public func sendTransactionStatusSubscribe(id: Flow.ID) async {
		let args = Flow.WebSocketTransactionStatusRequest(txId: id.hex)
		do {
			try await sendSubscribeMessage(
				subscriptionId: "tx:\(id.hex)",
				topic: .transactionStatuses,
				arguments: args
			)
		} catch {
				// Higher layers can add logging if needed.
		}
	}

		// MARK: - Subscription frames

	public func sendSubscribeMessage<Arguments: Encodable & Sendable>(
		subscriptionId: String,
		topic: Flow.WebSocketTopic,
		arguments: Arguments
	) async throws {
		guard let channel = channel else { return }

		let request = Flow.WebSocketSubscribeRequest(
			id: subscriptionId,
			action: .subscribe,
			topic: topic,
			arguments: arguments
		)

		let data = try JSONEncoder().encode(request)
		var buffer = channel.allocator.buffer(capacity: data.count)
		buffer.writeBytes(data)

		let frame = WebSocketFrame(fin: true, opcode: .text,  data: buffer)
		try await channel.writeAndFlush(frame)
	}

		// MARK: - Internal connection helper

	private func connectWebSocket(to url: URL) async throws -> Channel {
		let scheme = url.scheme?.lowercased()
		let isTLS = (scheme == "wss")
		let host = url.host ?? "localhost"
		let port = url.port ?? (isTLS ? 443 : 80)

		let sslContext: NIOSSLContext?
		if isTLS {
			var tlsConfig = TLSConfiguration.makeClientConfiguration()
			tlsConfig.minimumTLSVersion = .tlsv12
			tlsConfig.certificateVerification = .fullVerification
			sslContext = try NIOSSLContext(configuration: tlsConfig)
		} else {
			sslContext = nil
		}

		let promise = group.next().makePromise(of: Channel.self)

		let bootstrap = ClientBootstrap(group: group)
			.channelInitializer { channel in
					// This closure runs on the channel's EventLoop.
				if let context = sslContext {
					do {
						let sslHandler = try NIOSSLClientHandler(
							context: context,
							serverHostname: host
						)

							// IMPORTANT: use syncOperations so NIOSSLHandler does NOT
							// have to be Sendable.
						try channel.pipeline.syncOperations.addHandler(sslHandler)
					} catch {
						return channel.eventLoop.makeFailedFuture(error)
					}
				}

					// Everything after this can be Sendable-safe (HTTP + WebSocket).
				return Self.addHTTPAndWebSocketHandlers(to: channel)
			}

		bootstrap.connect(host: host, port: port).whenComplete { result in
			switch result {
				case .success(let channel):
					var headers = HTTPHeaders()
					headers.add(name: "Host", value: host)
					headers.add(name: "Connection", value: "Upgrade")
					headers.add(name: "Upgrade", value: "websocket")
					headers.add(name: "Sec-WebSocket-Version", value: "13")
					headers.add(name: "Sec-WebSocket-Key", value: UUID().uuidString)

					var path = url.path
					if path.isEmpty { path = "/" }
					if let query = url.query, !query.isEmpty {
						path += "?" + query
					}

					let requestHead = HTTPRequestHead(
						version: .http1_1,
						method: .GET,
						uri: path,
						headers: headers
					)

					channel.write(HTTPClientRequestPart.head(requestHead), promise: nil)
					channel.writeAndFlush(HTTPClientRequestPart.end(nil), promise: nil)

					promise.succeed(channel)

				case .failure(let error):
					promise.fail(error)
			}
		}

		return try await promise.futureResult.get()
	}




	private static func addHTTPAndWebSocketHandlers(to channel: Channel) -> EventLoopFuture<Void> {
		let websocketUpgrader = NIOWebSocketClientUpgrader(
			maxFrameSize: 1 << 24,
			automaticErrorHandling: true
		) { channel, _ in
			channel.pipeline.addHandler(FlowWebSocketFrameHandler())
		}

			// Sendable-friendly upgrade configuration: (upgraders, completionHandler)
		let upgradeConfig: NIOHTTPClientUpgradeSendableConfiguration = (
			upgraders: [websocketUpgrader],
			completionHandler: { context in
					// Notify the rest of the pipeline / your app that the WebSocket is ready
				context.fireUserInboundEventTriggered(FlowWebSocketUpgradeEvent.upgraded)

					// Ensure reading continues even if autoRead was turned off
				context.channel.read()
			}
		)

		return channel.pipeline.addHTTPClientHandlers(
			position: .last,
			leftOverBytesStrategy: .dropBytes,
			withClientUpgrade: upgradeConfig
		)
	}
}
