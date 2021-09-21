//
//  File.swift
//
//
//  Created by lmcmz on 31/8/21.
//

import Foundation
import UIKit

extension UIApplication {
    var currentKeyWindow: UIWindow? {
//        UIApplication.shared.connectedScenes
//            .filter { $0.activationState == .foregroundActive }
//            .map { $0 as? UIWindowScene }
//            .compactMap { $0 }
//            .first?.windows
//            .filter { $0.isKeyWindow }
//            .first
        nil
    }

    var rootViewController: UIViewController? {
        currentKeyWindow?.rootViewController
    }

    var topMostViewController: UIViewController? {
        guard let rootVC = rootViewController else {
            return nil
        }
        var topController = rootVC
        while let newTopController = topController.presentedViewController {
            topController = newTopController
        }

        return topController
    }
}
