	//
	//  UserAgent.swift
	//
	//  Created by Hao Fu on 13/2/2023.
	//  Edited for Swift 6 concurrency & actors by Nicholas Reich on 2026-03-19.
	//

import Foundation
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

	/// Unified, safe user agent generator for the Flow SDK.
	/// Designed to be safe in tests, CLIs, and app contexts (no force unwraps).
public enum UserAgent {
		// MARK: - High-level SDK identity

	static let sdkName = "flow-swift"

		/// SDK / app version, preferring bundle info but falling back to "dev".
	static let sdkVersion: String = {
		let versionFromBundle = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
		let trimmed = versionFromBundle?.trimmingCharacters(in: .whitespacesAndNewlines)
		return (trimmed?.isEmpty == false) ? trimmed! : "dev"
	}()

		// MARK: - Platform info

	static let osName: String = {
#if os(macOS)
		return "macOS"
#elseif os(iOS)
		return "iOS"
#elseif os(tvOS)
		return "tvOS"
#elseif os(watchOS)
		return "watchOS"
#else
		return "unknownOS"
#endif
	}()

	static let osVersion: String = {
		ProcessInfo.processInfo.operatingSystemVersionString
	}()

		/// Executable / test bundle name, safe for CLI and test targets.
	static let executableName: String = {
		if let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleExecutable") as? String,
		   !name.isEmpty {
			return name
		}
		return "UnknownExecutable"
	}()

		// MARK: - Low-level system tokens

		/// eg. Darwin/16.3.0
	static let darwinVersion: String = {
		var sysinfo = utsname()
		uname(&sysinfo)
		let data = Data(bytes: &sysinfo.release, count: Int(_SYS_NAMELEN))
		let dv = String(data: data, encoding: .ascii)?
			.trimmingCharacters(in: .controlCharacters)
			.trimmingCharacters(in: .whitespacesAndNewlines)

		return "Darwin/\((dv?.isEmpty == false) ? dv! : "unknown")"
	}()

		/// eg. CFNetwork/808.3
	static let cfNetworkVersion: String = {
		let dictionary = Bundle(identifier: "com.apple.CFNetwork")?.infoDictionary
		let version = (dictionary?["CFBundleShortVersionString"] as? String)?
			.trimmingCharacters(in: .whitespacesAndNewlines)

		return "CFNetwork/\((version?.isEmpty == false) ? version! : "unknown")"
	}()

		/// eg. iOS/10.1 or macOS/14.2.1
	static let deviceVersion: String = {
#if os(iOS)
		let currentDevice = UIDevice.current
		let name = currentDevice.systemName.isEmpty ? "iOS" : currentDevice.systemName
		let version = currentDevice.systemVersion.isEmpty ? "0.0" : currentDevice.systemVersion
		return "\(name)/\(version)"
#elseif os(macOS)
		let info = ProcessInfo.processInfo
		let major = info.operatingSystemVersion.majorVersion
		let minor = info.operatingSystemVersion.minorVersion
		let patch = info.operatingSystemVersion.patchVersion
		return "macOS/\(major).\(minor).\(patch)"
#else
		return "unknownOS/0.0"
#endif
	}()

		/// eg. iPhone5,2 or Mac model identifier
	static let deviceName: String = {
		var sysinfo = utsname()
		uname(&sysinfo)
		let data = Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN))
		let name = String(data: data, encoding: .ascii)?
			.trimmingCharacters(in: .controlCharacters)
			.trimmingCharacters(in: .whitespacesAndNewlines)

		return (name?.isEmpty == false) ? name! : "UnknownDevice"
	}()

		/// eg. MyApp/1 – safe default for tests/CLI is "UnknownApp/0"
	static let appNameAndVersion: String = {
		guard let dictionary = Bundle.main.infoDictionary else {
			return "UnknownApp/0"
		}

		let version = (dictionary["CFBundleShortVersionString"] as? String)?
			.trimmingCharacters(in: .whitespacesAndNewlines)
		let name = (dictionary["CFBundleName"] as? String)?
			.trimmingCharacters(in: .whitespacesAndNewlines)

		let safeName = (name?.isEmpty == false) ? name! : "UnknownApp"
		let safeVersion = (version?.isEmpty == false) ? version! : "0"

		return "\(safeName)/\(safeVersion)"
	}()

		// MARK: - Final assembled UA strings

		/// Short SDK‑centric UA, e.g. "flow-swift/1.0.0 (macOS 14.4) FlowTests"
	public static let value: String = {
		"\(sdkName)/\(sdkVersion) (\(osName) \(osVersion)) \(executableName)"
	}()

		/// Extended UA including device and CFNetwork/Darwin tokens, e.g.:
		/// "MyApp/1.0 MacBookPro18,3 macOS/14.4 CFNetwork/1490.0.3 Darwin/23.4.0"
	public static let extended: String = {
		"\(appNameAndVersion) \(deviceName) \(deviceVersion) \(cfNetworkVersion) \(darwinVersion)"
	}()
}

/// Backwards-compatible global used by older parts of the SDK.
/// Prefer `UserAgent.value` or `UserAgent.extended` in new code.
let userAgent: String = UserAgent.extended
