	//
	//  FlowLogger.swift
	//
	//  Logging utilities for Flow SDK
	//
	//  Edited for Swift 6 concurrency & actors by Nicholas Reich on 2026-03-19.
import Foundation
import SwiftUI

	// MARK: - Global logging actor

@globalActor
public actor FlowLogActor {
	public static let shared = FlowLogActor()
}

	// MARK: - Types

public enum FlowLogLevel: Int, Sendable {
	case debug = 0
	case info
	case warning
	case error

	var prefix: String {
		switch self {
			case .debug:   return "🔍 DEBUG"
			case .info:    return "ℹ️ INFO"
			case .warning: return "⚠️ WARNING"
			case .error:   return "❌ ERROR"
		}
	}
}

public protocol FlowLoggerProtocol: Sendable {
	func log(
		_ level: FlowLogLevel,
		message: String,
		function: String,
		file: String,
		line: Int
	)
}

	// MARK: - Logger

@FlowLogActor
public final class FlowLogger {

	public static let shared = FlowLogger()

	private var loggers: [FlowLoggerProtocol] = []
	public var minimumLogLevel: FlowLogLevel = .info

	private init() {
			// Default console logger
		loggers.append(ConsoleLogger())
	}

	public func addLogger(_ logger: FlowLoggerProtocol) {
		loggers.append(logger)
	}

	public func removeAllLoggers() {
		loggers.removeAll()
	}

	public func log(
		_ level: FlowLogLevel,
		message: String,
		function: String = #function,
		file: String = #fileID,
		line: Int = #line
	) {
		guard level.rawValue >= minimumLogLevel.rawValue else { return }

		for logger in loggers {
			logger.log(level, message: message, function: function, file: file, line: line)
		}
	}

		// Nonisolated convenience for sync callers – fire-and-forget
	public nonisolated func logAsync(
		_ level: FlowLogLevel,
		message: String,
		function: String = #function,
		file: String = #fileID,
		line: Int = #line
	) {
		_Concurrency.Task { @FlowLogActor in
			 FlowLogger.shared.log(
				level,
				message: message,
				function: function,
				file: file,
				line: line
			)
		}
	}
}

	// MARK: - Default console logger

public struct ConsoleLogger: FlowLoggerProtocol {
	public init() {}

	public func log(
		_ level: FlowLogLevel,
		message: String,
		function: String,
		file: String,
		line: Int
	) {
		let filename = (file as NSString).lastPathComponent
		let output = "[\(level.prefix)] [\(filename):\(line)] \(function) -> \(message)"
		print(output)
	}
}
