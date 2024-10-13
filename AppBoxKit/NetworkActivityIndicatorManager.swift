//
//  NetworkActivityIndicatorManager.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 10/12/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//

import UIKit

@objcMembers
public class NetworkActivityIndicatorManager:NSObject {
    
    public static let shared = NetworkActivityIndicatorManager()
    
    private var activityIndicatorCount = 0
    private var activityIndicatorView: UIActivityIndicatorView?
    
    private override init() {
        super.init()
        setupActivityIndicator()
    }
    
    private func setupActivityIndicator() {
        // Create and configure the activity indicator
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        // Find the active window scene
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) {
            
            // Add the activity indicator to the key window
            if let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                window.addSubview(indicator)
                NSLayoutConstraint.activate([
                    indicator.centerXAnchor.constraint(equalTo: window.centerXAnchor),
                    indicator.centerYAnchor.constraint(equalTo: window.centerYAnchor)
                ])
            }
        }
        
        activityIndicatorView = indicator
    }
    
    // Show network activity indicator
    public func show() {
        UIApplication.printCallStackIfDebug()
        
        DispatchQueue.main.async {
            self.activityIndicatorCount += 1
            self.updateIndicatorVisibility()
        }
    }
    
    // Hide network activity indicator
    public func hide() {
        UIApplication.printCallStackIfDebug()
        DispatchQueue.main.async {
            self.activityIndicatorCount = max(self.activityIndicatorCount - 1, 0)
            self.updateIndicatorVisibility()
        }
    }
    
    private func updateIndicatorVisibility() {
        if activityIndicatorCount > 0 {
            activityIndicatorView?.startAnimating()
        } else {
            activityIndicatorView?.stopAnimating()
        }
    }
}
