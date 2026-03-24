	//
	//  FlowWebSocketFrameHandler.swift
	//  Flow
	//
	//  Created by Nicholas Reich on 3/21/26.
	//

import Foundation
import NIOCore
import NIOWebSocket

	/// Handles inbound websocket frames and routes decoded messages into FlowWebSocketCenter.
final class FlowWebSocketFrameHandler: ChannelInboundHandler,Sendable {
	typealias InboundIn = WebSocketFrame
	typealias OutboundOut = WebSocketFrame

	private let decoder: JSONDecoder = {
		let d = JSONDecoder()
		d.keyDecodingStrategy = .convertFromSnakeCase
		return d
	}()

	func channelRead(context: ChannelHandlerContext,  data: NIOAny) {
		let frame = unwrapInboundIn(data)

		switch frame.opcode {
			case .text:
				handleTextFrame(frame)
			case .binary:
				handleBinaryFrame(frame)
			case .connectionClose:
				context.close(promise: nil)
			case .ping:
				var buffer = context.channel.allocator.buffer(capacity: 0)
				let pongFrame = WebSocketFrame(fin: true, opcode: .pong, data: buffer)
				context.writeAndFlush(wrapOutboundOut(pongFrame), promise: nil)
			default:
				break
		}
	}

	private func handleTextFrame(_ frame: WebSocketFrame) {
		var buffer = frame.unmaskedData
		if let string = buffer.readString(length: buffer.readableBytes),
		   let bytes = string.data(using: .utf8) {
			handleJSONData(bytes)
		}
	}

	private func handleBinaryFrame(_ frame: WebSocketFrame) {
		var buffer = frame.unmaskedData
		let bytes = buffer.readBytes(length: buffer.readableBytes) ?? []
		handleJSONData(Data(bytes))
	}

	private func handleJSONData(_ data:  Data) {
			// Transaction status topic
		if let response = try? decoder.decode(
			Flow.WebSocketTopicResponse<Flow.WSTransactionResponse>.self,
			from: data
		) {
			_Concurrency.Task {
				await FlowWebSocketCenter.shared.handleTransactionStatusMessage(response)
			}
			return
		}

			// Additional topic types can be added here by decoding with other payload types
			// and routing into dedicated handlers on FlowWebSocketCenter as needed.
	}

	func errorCaught(context: ChannelHandlerContext, error: Error) {
		context.close(promise: nil)
	}
}
