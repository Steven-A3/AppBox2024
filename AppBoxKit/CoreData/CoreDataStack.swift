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
    public var coreDataReady: Bool = false
    
    private let modelName = "AppBox2024"
    private let cloudStoreFileName = "AppBoxStore2024.sqlite"
    private let localStoreFileName = "AppBoxStore2024Local.sqlite"
    
    var isICloudAccountAvailable: Bool = false
    
    /// Block to execute media file cleaning
    public var mediaFileCleanerBlock: (() -> Void)?
    
    private override init() {
        super.init()
    }
    
    /// Sets up the Core Data stack.
    /// - Parameter completion: Completion handler called when setup is complete.
    public func setupStackWithCompletion(_ completionB: @escaping () -> Void) {
        checkICloudAccountStatus { [weak self] available in
            self?.isICloudAccountAvailable = available
            self?.setupPersistentContainer(completionB)
        }
    }
    
    private func checkICloudAccountStatus(_ completionA: @escaping (Bool) -> Void) {
        let container = CKContainer(identifier: iCloudConstants.ICLOUD_CONTAINER_IDENTIFIER)
        container.accountStatus { status, error in
            completionA(status == .available)
        }
    }
    
    private func setupPersistentContainer(_ completionC: @escaping () -> Void) {
        print("completion of setupPersistentContainer")
        
        // Load the model
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd"),
              let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to load model.")
        }
        
        let container: NSPersistentContainer
        var cloudKitOptions: NSPersistentCloudKitContainerOptions? = nil
        
        if isICloudAccountAvailable {
            // Use NSPersistentCloudKitContainer
            container = NSPersistentCloudKitContainer(name: modelName, managedObjectModel: managedObjectModel)
            
            cloudKitOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: iCloudConstants.ICLOUD_CONTAINER_IDENTIFIER)
        } else {
            // Use NSPersistentContainer
            container = NSPersistentContainer(name: modelName, managedObjectModel: managedObjectModel)
        }
        
        guard let cloudStoreURL = cloudStoreURL() else {
            fatalError("Failed to get persistent store URL.")
        }
        guard let localStoreURL = localStoreURL() else {
            fatalError("Failed to get persistent store URL.")
        }
        let cloudStoreDescription = createStoreDescription(for: cloudStoreURL, configuration: "Cloud", options: cloudKitOptions)
        let localStoreDescription = createStoreDescription(for: localStoreURL, configuration: "Local")
        container.persistentStoreDescriptions = [cloudStoreDescription, localStoreDescription]
        
        // Enable persistent history tracking
        cloudStoreDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        cloudStoreDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.persistentStoreDescriptions = [cloudStoreDescription, localStoreDescription]
        
        container.loadPersistentStores { [weak self] (storeDescription, error) in
            print("Completion of loadPersistentStores: \(String(describing: storeDescription.configuration))")
            
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
            self?.persistentContainer = container
            self?.persistentContainer?.viewContext.automaticallyMergesChangesFromParent = true
            
#if DEBUG
            //            if let cloudContainer = container as? NSPersistentCloudKitContainer {
            //                self?.initializeCloudKitSchema(container: cloudContainer)
            //            }
#endif
            
            if storeDescription.configuration == "Cloud" {
                self?.startObservingCloudKitEvents()
                DispatchQueue.main.async {
                    completionC()
                }
            }
        }
    }
    
    private func createStoreDescription(for url: URL, configuration: String, options: NSPersistentCloudKitContainerOptions? = nil) -> NSPersistentStoreDescription {
        let description = NSPersistentStoreDescription(url: url)
        description.configuration = configuration
        if let options = options {
            description.cloudKitContainerOptions = options
        }
        return description
    }
    
    private func cloudStoreURL() -> URL? {
        guard let containerURL = appGroupContainerURL() else {
            assertionFailure("Unable to access app group container.")
            return nil
        }
        return containerURL.appendingPathComponent(cloudStoreFileName)
    }
    
    private func localStoreURL() -> URL? {
        guard let containerURL = appGroupContainerURL() else {
            assertionFailure("Unable to access app group container.")
            return nil
        }
        return containerURL.appendingPathComponent(localStoreFileName)
    }
    
    func appGroupContainerURL() -> URL? {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: iCloudConstants.APP_GROUP_CONTAINER_IDENTIFIER) else {
            assertionFailure("Unable to access app group container.")
            return nil
        }
        let containerURLWithDirectory = containerURL.appendingPathComponent("Library/AppBox")
        if !FileManager.default.fileExists(atPath: containerURLWithDirectory.path) {
            try? FileManager.default.createDirectory(at: containerURLWithDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        return containerURLWithDirectory
    }
    
    /// Unloads the persistent container.
    @objc
    public func unloadPersistentContainer(container: NSPersistentContainer) {
        for store in container.persistentStoreCoordinator.persistentStores {
            do {
                try container.persistentStoreCoordinator.remove(store)
            } catch {
                print("Failed to remove persistent store: \(error)")
            }
        }
    }
    
    /// Deletes the Core Data store files.
    @objc
    public func deleteStoreFiles(storeURL: URL) {
        let additionalFiles = [
            storeURL.deletingPathExtension().appendingPathExtension("sqlite-shm"),
            storeURL.deletingPathExtension().appendingPathExtension("sqlite-wal")
        ]
        deleteFiles(at: [storeURL] + additionalFiles)
    }
    
    private func deleteFiles(at urls: [URL], completion: ((Error?) -> Void)? = nil) {
        let fileManager = FileManager.default
        do {
            for url in urls where fileManager.fileExists(atPath: url.path) {
                try fileManager.removeItem(at: url)
            }
            completion?(nil)
        } catch {
            completion?(error)
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
    
    public func loadPersistentContainer(modelName: String?, storeURL: URL) -> NSPersistentContainer {
        let modelName = modelName ?? self.modelName
        let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd")!
        let oldModel = NSManagedObjectModel(contentsOf: modelURL)
        let container = NSPersistentContainer(name: modelName, managedObjectModel: oldModel!)
        
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        container.persistentStoreDescriptions = [storeDescription]
        
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("Error loading old persistent store: \(error)")
            }
        }
        return container
    }
}
