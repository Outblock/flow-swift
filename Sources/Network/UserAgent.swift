//
//  File.swift
//
//
//  Created by Hao Fu on 13/2/2023.
//

import Foundation
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
// eg. Darwin/16.3.0
var darwinVersion: String {
    var sysinfo = utsname()
    uname(&sysinfo)
    let dv = String(bytes: Data(bytes: &sysinfo.release, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    return "Darwin/\(dv)"
}

// eg. CFNetwork/808.3
var CFNetworkVersion: String {
    let dictionary = Bundle(identifier: "com.apple.CFNetwork")?.infoDictionary!
    let version = dictionary?["CFBundleShortVersionString"] as! String
    return "CFNetwork/\(version)"
}

// eg. iOS/10_1
var deviceVersion: String {
#if os(iOS)
    let currentDevice = UIDevice.current
    return "\(currentDevice.systemName)/\(currentDevice.systemVersion)"
#elseif os(macOS)
    let info = ProcessInfo.processInfo
    return "macOS/\(info.operatingSystemVersion.majorVersion).\(info.operatingSystemVersion.minorVersion).\(info.operatingSystemVersion.patchVersion)"
#endif
    
}

// eg. iPhone5,2
var deviceName: String {
    var sysinfo = utsname()
    uname(&sysinfo)
    return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
}

// eg. MyApp/1
var appNameAndVersion: String {
    guard let dictionary = Bundle.main.infoDictionary else {
        return ""
    }
    let version = dictionary["CFBundleShortVersionString"] as! String
    let name = dictionary["CFBundleName"] as! String
    return "\(name)/\(version)"
}

let userAgent = "\(appNameAndVersion) \(deviceName) \(deviceVersion) \(CFNetworkVersion) \(darwinVersion)"
