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
    private let storeFileName = "AppBoxStore2024.sqlite"
    private let localStoreFileName = "AppBoxStore2024Local.sqlite"
    
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
        let container = CKContainer(identifier: iCloudConstants.ICLOUD_CONTAINER_IDENTIFIER)
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
        var cloudKitOptions: NSPersistentCloudKitContainerOptions? = nil
        
        if isICloudAccountAvailable {
            // Use NSPersistentCloudKitContainer
            container = NSPersistentCloudKitContainer(name: modelName, managedObjectModel: managedObjectModel)
            
            cloudKitOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: iCloudConstants.ICLOUD_CONTAINER_IDENTIFIER)
        } else {
            // Use NSPersistentContainer
            container = NSPersistentContainer(name: modelName, managedObjectModel: managedObjectModel)
        }
        
        // Set up the cloud persistent store URL
        guard let cloudStoreURL = cloudStoreURL() else {
            fatalError("Failed to get persistent store URL.")
        }
        let cloudStoreDescription = NSPersistentStoreDescription(url: cloudStoreURL)
        if let options = cloudKitOptions {
            cloudStoreDescription.cloudKitContainerOptions = options
        }

        // Enable persistent history tracking
        cloudStoreDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        cloudStoreDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        cloudStoreDescription.configuration = "Cloud"
        
        guard let localStoreURL = localStoreURL() else {
            fatalError("Failed to get persistent store URL.")
        }
        let localStoreStoreDescription = NSPersistentStoreDescription(url: localStoreURL)
        localStoreStoreDescription.configuration = "Local"
        
        container.persistentStoreDescriptions = [cloudStoreDescription, localStoreStoreDescription]
        
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
    
    private func cloudStoreURL() -> URL? {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: iCloudConstants.APP_GROUP_CONTAINER_IDENTIFIER) else {
            fatalError("Unable to access app group container.")
        }
        let storeURL = containerURL.appendingPathComponent("Library/AppBox/\(storeFileName)")
        return storeURL
    }
    
    private func localStoreURL() -> URL? {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: iCloudConstants.APP_GROUP_CONTAINER_IDENTIFIER) else {
            fatalError("Unable to access app group container.")
        }
        let storeURL = containerURL.appendingPathComponent("Library/AppBox/\(localStoreFileName)")
        return storeURL
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
    
    public func deleteAllRecords(_ completion: @escaping @convention(block) (Bool, Error?) -> Void) {
        guard let context = persistentContainer?.newBackgroundContext() else {
            return
        }
        
        let entitiesToDelete = [
            "AbbreviationFavorite_", "Calculation_", "CurrencyFavorite_", "CurrencyHistory_",
            "CurrencyHistoryItem_", "DaysCounterCalendar_", "DaysCounterDate_", "DaysCounterEvent_",
            "DaysCounterEventLocation_", "DaysCounterFavorite_", "DaysCounterReminder_", "ExpenseListBudget_",
            "ExpenseListBudgetLocation_", "ExpenseListHistory_", "ExpenseListItem_", "KaomojiFavorite_",
            "LadyCalendarAccount_", "LadyCalendarPeriod_", "LoanCalcComparisonHistory_", "LoanCalcHistory_",
            "Pedometer_", "PercentCalcHistory_", "QRCodeHistory_", "SalesCalcHistory_", "TipCalcHistory_",
            "TipCalcRecent_", "TranslatorFavorite_", "TranslatorGroup_", "TranslatorHistory_", "UnitHistory_",
            "UnitHistoryItem_", "UnitPriceHistory_", "UnitPriceInfo_", "WalletCategory_", "WalletFavorite_",
            "WalletField_", "WalletFieldItem_", "WalletItem_"
        ]
        
        context.perform {
            do {
                for entityName in entitiesToDelete {
                    // Create a fetch request for the entity
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                    
                    // Execute the delete request
                    try context.execute(deleteRequest)
                    print("Deleted all records for entity: \(entityName)")
                }
                // Save changes to persist the deletions
                try context.save()
                print("All records deleted successfully for all entities.")
                
                // Call completion on success
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } catch let error as NSError {
                // Call completion with error on failure
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
    }

    public func deleteAllFilesInUbiquityContainerInBackground(
        containerID: String,
        completion: @escaping (Bool, NSError?) -> Void
    ) {
        DispatchQueue.global(qos: .background).async {
            let fileManager = FileManager.default
            
            // Check if iCloud is available with the provided container ID
            if let ubiquityURL = fileManager.url(forUbiquityContainerIdentifier: containerID) {
                // Check if the directory exists
                if fileManager.fileExists(atPath: ubiquityURL.path) {
                    do {
                        // Get contents of the directory
                        let files = try fileManager.contentsOfDirectory(at: ubiquityURL, includingPropertiesForKeys: nil, options: [])
                        
                        // Iterate and delete each item
                        for file in files {
                            try fileManager.removeItem(at: file)
                            print("Deleted file: \(file.path)")
                        }
                        // Call completion handler with success
                        DispatchQueue.main.async {
                            completion(true, nil)
                        }
                    } catch let error as NSError {
                        // Call completion handler with error
                        DispatchQueue.main.async {
                            completion(false, error)
                        }
                    }
                } else {
                    let error = NSError(domain: "iCloudContainerError", code: 404, userInfo: [NSLocalizedDescriptionKey: "The directory does not exist at path: \(ubiquityURL.path)"])
                    DispatchQueue.main.async {
                        completion(false, error)
                    }
                }
            } else {
                let error = NSError(domain: "iCloudContainerError", code: 401, userInfo: [NSLocalizedDescriptionKey: "iCloud is not available for container ID: \(containerID)."])
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
    }

    public func migrateEntity(_ context: NSManagedObjectContext, _ fetchRequest: NSFetchRequest<NSManagedObject>, _ entityName: String, _ newContext: NSManagedObjectContext, _ newEntityName: String) {
        do {
            let oldEntities = try context.fetch(fetchRequest)
            for oldEntity in oldEntities {
                if let uniqueID = oldEntity.value(forKey: "uniqueID") as? String {
                    let checkRequest = NSFetchRequest<NSManagedObject>(entityName: newEntityName)
                    checkRequest.predicate = NSPredicate(format: "uniqueID == %@", uniqueID)
                    
                    let existingEntities = try newContext.fetch(checkRequest)
                    if existingEntities.isEmpty {
                        let newEntity = NSEntityDescription.insertNewObject(forEntityName: newEntityName, into: newContext)
                        for attribute in oldEntity.entity.attributesByName {
                            newEntity.setValue(oldEntity.value(forKey: attribute.key), forKey: attribute.key)
                        }
                    }
                }
            }
            
            if newContext.hasChanges {
                try newContext.save()
            }
            context.reset()
            newContext.reset()
        } catch {
            print("Error migrating \(entityName): \(error)")
        }
    }

    public func appGroupContainerURL() -> URL {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: iCloudConstants.APP_GROUP_CONTAINER_IDENTIFIER)!
    }
    
    public func V47StoreURL() -> URL {
        appGroupContainerURL().appendingPathComponent("Library/AppBox/AppBoxStore.sqlite")
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
