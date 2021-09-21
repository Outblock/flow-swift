//
//  File.swift
//
//
//  Created by lmcmz on 7/9/21.
//

import Foundation
import SafariServices

extension FCL {
    class SafariWebViewManager: NSObject, SFSafariViewControllerDelegate {
        static var shared = SafariWebViewManager()
        var safariVC: SFSafariViewController?
        var onClose: (() -> Void)?

        static func openSafariWebView(service: Service, dismiss: (() -> Void)?) {
            guard let url = URL(string: service.endpoint) else {
                return
            }
            SafariWebViewManager.shared.onClose = dismiss
            DispatchQueue.main.async {
                hideLoading {
                    let vc = SFSafariViewController(url: url)
                    vc.delegate = SafariWebViewManager.shared
                    vc.modalPresentationStyle = .formSheet
                    SafariWebViewManager.shared.safariVC = vc
                    UIApplication.shared.topMostViewController?.present(vc, animated: true, completion: nil)
                }
            }
        }

        static func dismiss() {
            if let vc = SafariWebViewManager.shared.safariVC {
                vc.dismiss(animated: true, completion: nil)
            }
        }

        func safariViewControllerDidFinish(_: SFSafariViewController) {
            if let block = SafariWebViewManager.shared.onClose {
                block()
            }
            SafariWebViewManager.shared.onClose = nil
        }
    }
}
