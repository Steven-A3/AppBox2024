//
//  MigrationView.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 10/14/24.
//

import SwiftUI
import DotLottie
import CoreData

struct MigrationView: View {
    var completion: (() -> Void)?
    
    // Persistent Containers as parameters
    var oldPersistentContainer: NSPersistentContainer
    var newPersistentContainer: NSPersistentContainer

    @State private var publisher = NotificationCenter.default.publisher(for: NSPersistentCloudKitContainer.eventChangedNotification)

    // Initialize MigrationManager with the containers
    @StateObject private var migrationManager: DataMigrationManager
    
    init(oldPersistentContainer: NSPersistentContainer,
         newPersistentContainer: NSPersistentContainer = CoreDataStack.shared.persistentContainer!,
         completion: (() -> Void)? = nil) {
        
        // Initialize the StateObject with the containers
        _migrationManager = StateObject(wrappedValue: DataMigrationManager(
            oldPersistentContainer: oldPersistentContainer,
            newPersistentContainer: newPersistentContainer as! NSPersistentCloudKitContainer
        ))
        
        self.completion = completion
        self.oldPersistentContainer = oldPersistentContainer
        self.newPersistentContainer = newPersistentContainer
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    Spacer()

                    // Progress View with padding
                    ProgressView(migrationManager.isMigrating ? "Optimizing Data" : "Optimization Complete",
                                 value: migrationManager.progress,
                                 total: 1.0)
                        .padding()
                        .padding(.horizontal, 30)
                    
                    // Animation view
                    DotLottieAnimation(fileName: "animation", config: AnimationConfig(autoplay: true, loop: true))
                        .view()
                        .frame(width: 300, height: 300)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                if migrationManager.isMigrationComplete {
                    VStack {
                        Spacer()
                        
                        let availableSpace = geometry.size.height - 300 - geometry.safeAreaInsets.bottom
                        
                        // Button
                        Button(action: {
                            guard let completion = self.completion else { return }
                            completion()
                        }) {
                            Text("Start AppBox Pro")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal, 30)
                        
                        Spacer().frame(height: availableSpace / 4)
                    }
                }
            }
        }
        .onReceive(publisher) { notification in
            if let userInfo = notification.userInfo {
                if let event = userInfo["event"] as? NSPersistentCloudKitContainer.Event {
                    if event.type == .export {
                        if !migrationManager.isMigrating {
                            migrationManager.migrateDataAfterUIChange() {
                                
                            }
                        }
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    // Provide mock containers for preview purposes
    let storeURL = CoreDataStack.shared.V47StoreURL()
    let oldContainer = CoreDataStack.shared.loadPersistentContainer(modelName: "AppBox3", storeURL: storeURL)
    
    MigrationView(oldPersistentContainer: oldContainer) {
        // Completion action
    }
}
