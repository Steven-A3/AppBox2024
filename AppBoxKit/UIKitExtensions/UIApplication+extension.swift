//
//  UIApplication+extension.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 10/26/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//

import UIKit

extension UIApplication {

    @objc public func showAlert(withTitle title: String?, message: String) {
        guard let rootViewController = self.getRootViewController() else {
            return
        }
        
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            rootViewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc public func openURL2(_ url: URL) {
        guard UIApplication.shared.canOpenURL(url) else { return }
        
        UIApplication.shared.open(url) { success in
            if !success {
                self.showAlert(withTitle: "Error", message: "Failed to open \(url)")
            }
        }
    }
    
    /// Objective-C compatible method to return the root view controller of the application's key window
    @objc public func getRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return nil
        }
        return rootViewController
    }
}
