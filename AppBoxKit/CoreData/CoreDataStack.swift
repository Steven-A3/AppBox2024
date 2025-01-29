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
public class iCloudConstants: NSObject {
    public static let OLD_ICLOUD_CONTAINER_IDENTIFIER: String = "84XB754BWU.com.e2ndesign.TPremium2"
    public static let ICLOUD_CONTAINER_IDENTIFIER: String = "iCloud.net.allaboutapps.AppBox"
    public static let APP_GROUP_CONTAINER_IDENTIFIER: String = "group.allaboutapps.appbox"
    public static let MEDIA_FILES_PATH: String = "Library/AppBox/MediaFiles"
    public static let COREDATA_READY_TO_USE_NOTIFICATION: String = "CoreDataReadyToUseNotification"
}

@objcMembers
public class CoreDataStack: NSObject {
    
    public static let shared = CoreDataStack()
    
    // Expose persistentContainer
    public var persistentContainer: NSPersistentContainer?
    public var coreDataReady: Bool = false
    
    private let modelName = "AppBox2024"
    public let cloudStoreFileName = "AppBoxStore2024.sqlite"
    public let localStoreFileName = "AppBoxStore2024Local.sqlite"
    
    public var isICloudAccountAvailable: Bool = false
    
    let cloudContainer = CKContainer(identifier: iCloudConstants.ICLOUD_CONTAINER_IDENTIFIER)
    let cloudDatabase: CKDatabase
    let deduplicationRecordID = CKRecord.ID(recordName: "DeduplicationTimestamp")
    let minimumInterval: TimeInterval = 60 * 10
    
    /// Block to execute media file cleaning
    public var mediaFileCleanerBlock: (() -> Void)?
    
    private override init() {
        self.cloudDatabase = cloudContainer.privateCloudDatabase
        
        super.init()
    }
    
    /// Sets up the Core Data stack.
    /// - Parameter completionB: Completion handler called when setup is complete.
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
        let modelName = self.modelName
        
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

    // 이 함수는 백업 데이터에서 복원하기 위해서 사용하는 함수이다.
    public func loadPersistentContainer(modelName: String?, baseURL: URL, completion: @escaping (NSPersistentContainer?, NSPersistentStoreDescription?, Error?) -> Void) {
        let modelName = modelName ?? self.modelName
        let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd")!
        let oldModel = NSManagedObjectModel(contentsOf: modelURL)
        let container = NSPersistentContainer(name: modelName, managedObjectModel: oldModel!)

        if modelName == "AppBox3" {
            let storeDescription = NSPersistentStoreDescription(url: baseURL.appendingPathComponent("AppBoxStore.sqlite"))
            container.persistentStoreDescriptions = [storeDescription]
        } else {
            let cloudStoreURL = cloudStoreURL(baseURL: baseURL)
            let localStoreURL = localStoreURL(baseURL: baseURL)
            let cloudStoreDescription = createStoreDescription(for: cloudStoreURL!, configuration: "Cloud")
            let localStoreDescription = createStoreDescription(for: localStoreURL!, configuration: "Local")
            container.persistentStoreDescriptions = [cloudStoreDescription, localStoreDescription]
        }

        container.loadPersistentStores { (description, error) in
            // 모델명이 AppBox3인 경우에는 description이 한번 호출되고, configuration은 "Default"로 호출된다.
            // 모델명이 AppBox20245인 경우에는 description이 두번 호출되고, configuration은 "Cloud"와 "Local"로 호출된다.
            if let error = error {
                Logger.shared.error("Error loading old persistent store: \(error)")
                completion(nil, nil, error)
            } else {
                completion(container, description, nil)
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
    
    public func cloudStoreURL(baseURL: URL? = nil) -> URL? {
        guard let containerURL = baseURL ?? appGroupContainerURL() else {
            assertionFailure("Unable to access app group container.")
            return nil
        }
        return containerURL.appendingPathComponent(cloudStoreFileName)
    }
    
    public func localStoreURL(baseURL: URL? = nil) -> URL? {
        guard let containerURL = baseURL ?? appGroupContainerURL() else {
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
        let coordinator = container.persistentStoreCoordinator
        container.viewContext.reset()
        
        for store in container.persistentStoreCoordinator.persistentStores {
            do {
                try coordinator.remove(store)
                try coordinator.destroyPersistentStore(at: store.url!, ofType: store.type, options: nil)
            } catch {
                Logger.shared.error("Failed to remove persistent store: \(error)")
            }
        }
        self.persistentContainer = nil
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
                Logger.shared.debug("Deleted file: \(url.path)")
            }
            completion?(nil)
        } catch {
            Logger.shared.error("Failed to delete files: \(error)")
            completion?(error)
        }
    }
    
    /// Initializes the CloudKit schema when in debug mode.
    /// - Parameter container: The NSPersistentCloudKitContainer instance.
    private func initializeCloudKitSchema(container: NSPersistentCloudKitContainer) {
        do {
            try container.initializeCloudKitSchema(options: [])
            Logger.shared.debug("CloudKit schema successfully initialized.")
        } catch {
            Logger.shared.error("Failed to initialize CloudKit schema: \(error)")
        }
    }
   
    /**
     Resets the Core Data stack by unloading the current persistent container,
     deleting the associated store files, and resetting the state if iCloud is available.
     
     - Parameters:
     - completion: A closure that is called when the reset operation is complete.
     The closure has a single parameter, an `Error?`, which will be `nil`
     if the operation was successful or contain an error if it failed.
     
     This method performs the following steps:
     1. Checks if iCloud is available. If not, it does nothing and calls the completion handler with `nil`.
     2. Checks if the `persistentContainer` is initialized. If not, it immediately calls the
     completion handler with an error indicating the container is not set up.
     3. Unloads the current persistent container to release any held resources and prepare for reset.
     4. Deletes the store files associated with both the cloud and local Core Data stores.
     5. Resets CloudKit sync if iCloud is available.
     6. Calls the completion handler to signal that the reset process is complete.
     
     Usage:
     */
    @objc
    public func resetContainer(completion: @escaping (Error?) -> Void) {
        guard persistentContainer != nil else {
            completion(NSError(domain: "CoreDataStack", code: 1, userInfo: [NSLocalizedDescriptionKey: "Persistent container is not initialized."]))
            return
        }

        resetLocalContainer()
        
        // Step 5: Reset CloudKit sync
        if isICloudAccountAvailable {
            resetCloudKitSync { success, error in
                if let error = error {
                    completion(error)
                    return
                }
                
                if success {
                    print("CloudKit sync successfully reset.")
                }
                
                // Step 6: Reinitialize the Core Data stack
                self.setupStackWithCompletion {
                    completion(nil) // Indicate successful reset
                }
            }
        } else {
            // Step 6: Reinitialize the Core Data stack
            setupStackWithCompletion {
                completion(nil) // Indicate successful reset
            }
        }
    }
    
    public func resetLocalContainer() {
        guard let container = persistentContainer else {
            return
        }
        
        // Step 3: Unload the persistent container
        unloadPersistentContainer(container: container)
        persistentContainer = nil
        
        // Step 4: Delete store files
        if let cloudStoreURL = cloudStoreURL() {
            deleteStoreFiles(storeURL: cloudStoreURL)
        }
        if let localStoreURL = localStoreURL() {
            deleteStoreFiles(storeURL: localStoreURL)
        }
        deleteAllLocalMediaFiles()
    }
    
    func deleteAllLocalMediaFiles() {
        guard let appGroupContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: iCloudConstants.APP_GROUP_CONTAINER_IDENTIFIER) else {
            print("Failed to retrieve app group container URL.")
            return
        }
        
        // Base path
        let basePath = appGroupContainerURL.appendingPathComponent(iCloudConstants.MEDIA_FILES_PATH)
        
        // Directories to delete files from
        let directories = ["DaysCounterImages", "WalletImages", "WalletVideos"]
        
        for directory in directories {
            let directoryPath = basePath.appendingPathComponent(directory)
            
            do {
                // Retrieve the contents of the directory
                let files = try FileManager.default.contentsOfDirectory(at: directoryPath, includingPropertiesForKeys: nil, options: [])
                
                // Iterate through files and delete each one
                for file in files {
                    try FileManager.default.removeItem(at: file)
                    Logger.shared.debug("Deleted file: \(file.path)")
                }
                
                Logger.shared.debug("Successfully cleared all files in directory: \(directoryPath.path)")
                
            } catch {
                Logger.shared.error("Failed to delete files in directory: \(directoryPath.path), Error: \(error.localizedDescription)")
            }
        }
    }
}
