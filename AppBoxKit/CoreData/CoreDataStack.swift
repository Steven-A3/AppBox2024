//
//  CoreDataStack.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 7/7/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//

import Foundation
import CoreData

@objc(CoreDataStack)
class CoreDataStack: NSObject {
    @objc static let shared = CoreDataStack()

    @objc lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "AppBox3")
        
        // Set up the private store description
        let privateStoreDescription = NSPersistentStoreDescription(url: privateStoreURL!)
        privateStoreDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        privateStoreDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        // CloudKit integration
        let cloudKitOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.your.bundle.id")
        privateStoreDescription.cloudKitContainerOptions = cloudKitOptions
        
        // Add the description to the container
        container.persistentStoreDescriptions = [privateStoreDescription]
        
        container.loadPersistentStores { (description, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(storeRemoteChange(_:)),
                                               name: .NSPersistentStoreRemoteChange,
                                               object: container.persistentStoreCoordinator)
        
        return container
    }()
    
    var privateStoreURL: URL? {
        guard let baseStoreURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: A3AppGroupIdentifier) else {
            print("Error: Unable to get container URL")
            return nil
        }
        let storeURL = baseStoreURL.appendingPathComponent("Library/AppBox/AppBoxStore.sqlite")
        return storeURL
    }
    
    @objc
    func storeRemoteChange(_ notification: Notification) {
        // Handle remote change notifications
    }
    
    @objc
    func saveNewItem(name: String) {
        let context = persistentContainer.viewContext
        let newItem = NSEntityDescription.insertNewObject(forEntityName: "Item", into: context)
        newItem.setValue(name, forKey: "name")
        newItem.setValue(Date(), forKey: "timestamp")

        do {
            try context.save()
            print("Item saved successfully")
        } catch {
            print("Failed to save item: \(error)")
        }
    }
    
    @objc
    func fetchAllItems() -> [NSManagedObject] {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Item")

        do {
            let items = try context.fetch(fetchRequest)
            return items
        } catch {
            print("Failed to fetch items: \(error)")
            return []
        }
    }
    
    @objc
    func deleteItem(item: NSManagedObject) {
        let context = persistentContainer.viewContext
        context.delete(item)

        do {
            try context.save()
            print("Item deleted successfully")
        } catch {
            print("Failed to delete item: \(error)")
        }
    }
}
