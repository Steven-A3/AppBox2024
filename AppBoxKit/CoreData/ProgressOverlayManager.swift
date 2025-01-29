//
//  File.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 1/14/25.
//  Copyright © 2025 ALLABOUTAPPS. All rights reserved.
//

import UIKit
import SwiftUI

public final class ProgressOverlayManager {
    public static let shared = ProgressOverlayManager()
    
    /// The data model watched by SwiftUI for updates
    private let data = ProgressOverlayData()
    
    private var hostingController: UIHostingController<ProgressOverlayView>?
    private var hostingView: UIView?

    // MARK: - Init
    
    // This init is private because we only want one shared instance.
    private init() {
        setupProgressOverlay()
    }
    
    // MARK: - Setup
    
    private func setupProgressOverlay() {
        // Must run UI code on main thread
        DispatchQueue.main.async {
            // If we already have a hostingController or hostingView, skip
            guard self.hostingController == nil, self.hostingView == nil else { return }

            let rootView = ProgressOverlayView(data: self.data)
            let hostingController = UIHostingController(rootView: rootView)
            hostingController.view.backgroundColor = .clear

            guard let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
                  let window = windowScene.windows.first(where: { $0.isKeyWindow })
            else {
                print("No active window found for the activity indicator.")
                return
            }
            
            let hostingView = hostingController.view!
            hostingView.translatesAutoresizingMaskIntoConstraints = false
            window.addSubview(hostingView)

            NSLayoutConstraint.activate([
                hostingView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                hostingView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
                hostingView.topAnchor.constraint(equalTo: window.topAnchor),
                hostingView.bottomAnchor.constraint(equalTo: window.bottomAnchor)
            ])

            self.hostingController = hostingController
            self.hostingView = hostingView
            self.hostingView?.isHidden = true // Initially hidden
        }
    }
    
    // MARK: - Public Methods
    
    public func show(_ message: String) {
        DispatchQueue.main.async {
            // If lost, re-setup
            if self.hostingController == nil || self.hostingView == nil {
                self.setupProgressOverlay()
            }

            // Update the message in the observable object
            self.data.message = message
            
            // Reveal the overlay
            self.hostingView?.isHidden = false
        }
    }
    
    public func hide() {
        DispatchQueue.main.async {
            // Clear the message
            self.data.message = ""
            
            // Hide the overlay
            self.hostingView?.isHidden = true
        }
    }
}
