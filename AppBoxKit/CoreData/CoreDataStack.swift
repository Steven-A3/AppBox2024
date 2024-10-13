//
//  AppBoxCoreDataStack.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 10/1/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

@objcMembers
public class CoreDataStack: NSObject {

    public static let shared = CoreDataStack()
    
    // Expose persistentContainer
    public var persistentContainer: NSPersistentContainer?
    
    private let modelName = "AppBox2024"
    private let appGroupID = "group.allaboutapps.appbox"
    private let cloudKitContainerID = "iCloud.net.allaboutapps.AppBox"
    private let storeFileName = "AppBoxStore2024.sqlite"
    
    private var isICloudAccountAvailable: Bool = false
    
    private override init() {
        super.init()
    }
    
    /// Sets up the Core Data stack.
    /// - Parameter completion: Completion handler called when setup is complete.
    public func setupStackWithCompletion(_ completion: @escaping @convention(block) () -> Void) {
        checkICloudAccountStatus { [weak self] available in
            self?.isICloudAccountAvailable = available
            self?.setupPersistentContainer(completion: completion)
        }
    }
    
    private func checkICloudAccountStatus(completion: @escaping (Bool) -> Void) {
        let container = CKContainer(identifier: cloudKitContainerID)
        container.accountStatus { status, error in
            DispatchQueue.main.async {
                completion(status == .available)
            }
        }
    }
    
    private func setupPersistentContainer(completion: @escaping () -> Void) {
        // Load the model
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd"),
              let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to load model.")
        }
        
        let container: NSPersistentContainer
        
        if isICloudAccountAvailable {
            // Use NSPersistentCloudKitContainer
            container = NSPersistentCloudKitContainer(name: modelName, managedObjectModel: managedObjectModel)
            
            // Configure CloudKit options
            guard let storeDescription = container.persistentStoreDescriptions.first else {
                fatalError("Failed to get store description.")
            }
            let cloudKitOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: cloudKitContainerID)
            storeDescription.cloudKitContainerOptions = cloudKitOptions
        } else {
            // Use NSPersistentContainer
            container = NSPersistentContainer(name: modelName, managedObjectModel: managedObjectModel)
        }
        
        // Set up the persistent store URL
        guard let storeDescription = container.persistentStoreDescriptions.first else {
            fatalError("Failed to get store description.")
        }
        storeDescription.url = persistentStoreURL()
        
        // Enable persistent history tracking
        storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        storeDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        storeDescription.configuration = "Cloud"
        
        container.loadPersistentStores { [weak self] (_, error) in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
            self?.persistentContainer = container
            
            #if DEBUG
            if let cloudContainer = container as? NSPersistentCloudKitContainer {
                self?.initializeCloudKitSchema(container: cloudContainer)
            }
            #endif
            
            completion()
        }
    }
    
    private func persistentStoreURL() -> URL? {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            fatalError("Unable to access app group container.")
        }
        let storeURL = containerURL.appendingPathComponent("Library/AppBox/\(storeFileName)")
        return storeURL
    }
    
    /// Unloads the persistent container.
    @objc
    public func unloadPersistentContainer() {
        if let container = persistentContainer {
            for store in container.persistentStoreCoordinator.persistentStores {
                do {
                    try container.persistentStoreCoordinator.remove(store)
                } catch {
                    print("Failed to remove persistent store: \(error)")
                }
            }
            persistentContainer = nil
        }
    }
    
    /// Deletes the Core Data store files.
    @objc
    public func deleteStoreFiles() {
        guard let storeURL = persistentStoreURL() else { return }
        let fileManager = FileManager.default
        
        let shmURL = storeURL.deletingPathExtension().appendingPathExtension("sqlite-shm")
        let walURL = storeURL.deletingPathExtension().appendingPathExtension("sqlite-wal")
        
        do {
            if fileManager.fileExists(atPath: storeURL.path) {
                try fileManager.removeItem(at: storeURL)
            }
            if fileManager.fileExists(atPath: shmURL.path) {
                try fileManager.removeItem(at: shmURL)
            }
            if fileManager.fileExists(atPath: walURL.path) {
                try fileManager.removeItem(at: walURL)
            }
        } catch {
            print("Failed to delete store files: \(error)")
        }
    }
    
    /// Initializes the CloudKit schema when in debug mode.
    /// - Parameter container: The NSPersistentCloudKitContainer instance.
    private func initializeCloudKitSchema(container: NSPersistentCloudKitContainer) {
        do {
            print("Initializing CloudKit schema...")
            try container.initializeCloudKitSchema(options: [])
            print("CloudKit schema successfully initialized.")
        } catch {
            print("Failed to initialize CloudKit schema: \(error)")
        }
    }
}
