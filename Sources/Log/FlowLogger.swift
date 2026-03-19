	//
	//  FlowLogger.swift
	//
	//  Logging utilities for Flow SDK
	//

import Foundation
import SwiftUI

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
	func log(_ level: FlowLogLevel, message: String, function: String, file: String, line: Int)
}

public actor FlowLogger {
	public static let shared = FlowLogger()

	private var loggers: [FlowLoggerProtocol] = []
	public var minimumLogLevel: FlowLogLevel = .info

	private init() {}

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
}

// Default console logger implementation
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
