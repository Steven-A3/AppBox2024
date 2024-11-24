//
//  MigrationHostingViewController.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 10/14/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//

import SwiftUI
import CoreData

@objcMembers
public class MigrationHostingViewController: UIViewController {
    
    @objc
    public var completion: (() -> Void)?
    
    // The SwiftUI view that we want to expose to Objective-C
    private var hostingController: UIHostingController<MigrationView>?
    
    // Persistent Container for the old database version
    private var oldPersistentContainer: NSPersistentContainer
    
    // Custom initializer to accept the oldPersistentContainer
    @objc
    public init(oldPersistentContainer: NSPersistentContainer, completion: (() -> Void)? = nil) {
        self.oldPersistentContainer = oldPersistentContainer
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    // Required initializer for Objective-C compatibility
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the SwiftUI view with oldPersistentContainer and completion handler
        let migrationView = MigrationView(oldPersistentContainer: oldPersistentContainer, completion: completion)
        
        // Wrap the SwiftUI view in a UIHostingController
        hostingController = UIHostingController(rootView: migrationView)
        
        // Ensure the hostingController is non-nil before unwrapping
        guard let hostingController = hostingController else {
            return
        }
        
        // Add the hostingController's view to this view controller's view hierarchy
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        
        // Set up Auto Layout constraints to make the SwiftUI view fill the entire screen
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        hostingController.didMove(toParent: self)
    }
}
