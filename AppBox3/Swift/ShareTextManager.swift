//
//  ShareTextManager.swift
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 12/13/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//

import UIKit

@objc class ShareTextManager: NSObject {
    
    @objc static let shared = ShareTextManager()
    
    private override init() {
        super.init()
    }
    
    /// Function to present the sharing activity view controller
    /// - Parameters:
    ///   - text: The text to share
    ///   - viewController: The presenting view controller
    ///   - sourceView: The view from which the popover should originate (for iPad)
    @objc func shareText(_ text: String, from viewController: UIViewController, sourceView: UIView? = nil, barButtonItem: UIBarButtonItem? = nil) {
        let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        // Exclude certain activity types if desired
        activityViewController.excludedActivityTypes = [
            .addToReadingList,
            .print
        ]
        
        // Handle popover presentation for iPad
        if let popoverController = activityViewController.popoverPresentationController {
            if let barButtonItem = barButtonItem {
                popoverController.barButtonItem = barButtonItem
            } else if let sourceView = sourceView {
                popoverController.sourceView = sourceView
                popoverController.sourceRect = sourceView.bounds
            } else {
                // Default to center if no sourceView is provided
                popoverController.sourceView = viewController.view
                popoverController.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
        }
        
        // Present the activity view controller
        viewController.present(activityViewController, animated: true, completion: nil)
    }
}
