//
//  CloudWaitHostingViewController.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 12/21/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//

import UIKit
import SwiftUI

@objc
public class CloudWaitHostingViewController: UIViewController {
    
    private var completion: (() -> Void)?
    
    @objc public init(completion: @escaping () -> Void) {
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Create the SwiftUI view with the completion handler
        let cloudWaitView = CloudWaitView {
            self.navigationController?.popViewController(animated: true)
            guard let completion = self.completion else { return }
            completion()
//            self.dismiss(animated: true, completion: self.completion)
        }
        
        // Embed the SwiftUI view into a UIHostingController
        let hostingController = UIHostingController(rootView: cloudWaitView)
        
        // Add the hosting controller as a child view controller
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        // Set constraints to make the SwiftUI view fill the parent view
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
