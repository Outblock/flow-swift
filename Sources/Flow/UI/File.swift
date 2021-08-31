//
//  File.swift
//
//
//  Created by lmcmz on 31/8/21.
//

import Foundation
import UIKit

internal func showLoading() {
    let alert = UIAlertController(title: nil, message: "Loading...", preferredStyle: .alert)
    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
    loadingIndicator.hidesWhenStopped = true
    loadingIndicator.style = UIActivityIndicatorView.Style.medium
    loadingIndicator.startAnimating()
    alert.view.addSubview(loadingIndicator)
    UIApplication.shared.topMostViewController?.present(alert, animated: true, completion: nil)
}

internal func hideLoading(completion: (() -> Void)?) {
    if let vc = UIApplication.shared.topMostViewController as? UIAlertController {
        vc.dismiss(animated: true, completion: completion)
    }
}
