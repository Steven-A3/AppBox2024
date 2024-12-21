//
//  CoreDataStack+Migration.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 12/20/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//

import Foundation
import CloudKit

extension CoreDataStack {
    public func migrateEntity(_ context: NSManagedObjectContext,
                              _ fetchRequest: NSFetchRequest<NSManagedObject>,
                              _ entityName: String,
                              _ newContext: NSManagedObjectContext,
                              _ newEntityName: String) {
        context.performAndWait {
            do {
                // Fetch all old entities
                let oldEntities = try context.fetch(fetchRequest)
                let entityAttributes = oldEntities.first?.entity.attributesByName.keys.map { $0 } ?? []
                
                // Get unique IDs from old entities
                let oldEntityIDs = oldEntities.compactMap { $0.value(forKey: "uniqueID") as? String }

                // Fetch existing entities in the new context
                newContext.performAndWait {
                    do {
                        let existingFetchRequest = NSFetchRequest<NSManagedObject>(entityName: newEntityName)
                        let existingEntities = try newContext.fetch(existingFetchRequest)
                        let existingIDs = Set(existingEntities.compactMap { $0.value(forKey: "uniqueID") as? String })
                        
                        // Migrate entities
                        for oldEntity in oldEntities {
                            if let uniqueID = oldEntity.value(forKey: "uniqueID") as? String, !existingIDs.contains(uniqueID) {
                                let newEntity = NSEntityDescription.insertNewObject(forEntityName: newEntityName, into: newContext)
                                for attribute in entityAttributes {
                                    newEntity.setValue(oldEntity.value(forKey: attribute), forKey: attribute)
                                }
                            }
                        }
                        
                        // Save changes in the new context
                        if newContext.hasChanges {
                            try newContext.save()
                        }
                    } catch {
                        print("Error fetching or saving new context for \(newEntityName): \(error)")
                    }
                }
            } catch {
                print("Error fetching old entities for \(entityName): \(error)")
            }
        }
    }
    
    public func migrateEntity(
        _ context: NSManagedObjectContext,
        _ fetchRequest: NSFetchRequest<NSManagedObject>,
        _ entityName: String,
        _ newContext: NSManagedObjectContext,
        _ newEntityName: String,
        iCloudAvailable: Bool
    ) {
        do {
            // Fetch all old entities
            let oldEntities = try context.fetch(fetchRequest)
            let staticOldEntities = oldEntities.map { $0 }
            let entityAttributes = oldEntities.first?.entity.attributesByName.keys.map { $0 } ?? []
            
            var existingIDs: Set<String> = []

            if iCloudAvailable {
                // Query existing entities via CKRecord
                let container = CKContainer.default()
                let privateDatabase = container.privateCloudDatabase
                let query = CKQuery(recordType: "CD_" + entityName, predicate: NSPredicate(value: true))
                
                let semaphore = DispatchSemaphore(value: 0)
                var fetchedIDs: Set<String> = []
                
                privateDatabase.fetch(withQuery: query, inZoneWith: nil, desiredKeys: ["CD_uniqueID"], resultsLimit: CKQueryOperation.maximumResults) { result in
                    switch result {
                    case .success(let (matchResults, _)): // Destructure the tuple
                        for (recordID, recordResult) in matchResults {
                            switch recordResult {
                            case .success(let ckRecord):
                                if let uniqueID = ckRecord["CD_uniqueID"] as? String {
                                    fetchedIDs.insert(uniqueID)
                                }
                            case .failure(let error):
                                print("Error fetching CKRecord with ID \(recordID): \(error)")
                            }
                        }
                    case .failure(let error):
                        print("Error performing query: \(error)")
                    }
                    existingIDs = fetchedIDs
                    semaphore.signal()
                }
                semaphore.wait()
            } else {
                // Pre-fetch existing entities in the new context
                let existingFetchRequest = NSFetchRequest<NSManagedObject>(entityName: newEntityName)
                let existingEntities = try newContext.fetch(existingFetchRequest)
                existingIDs = Set(existingEntities.compactMap { $0.value(forKey: "uniqueID") as? String })
            }

            // Migrate entities
            for oldEntity in staticOldEntities {
                if let uniqueID = oldEntity.value(forKey: "uniqueID") as? String, !existingIDs.contains(uniqueID) {
                    let newEntity = NSEntityDescription.insertNewObject(forEntityName: newEntityName, into: newContext)
                    for attribute in entityAttributes {
                        newEntity.setValue(oldEntity.value(forKey: attribute), forKey: attribute)
                    }
                }
            }

            // Save changes in the new context
            if newContext.hasChanges {
                try newContext.save()
            }
        } catch {
            print("Error migrating \(entityName): \(error)")
        }
    }
    
    public func V47StoreURL() -> URL {
        appGroupContainerURL()!.appendingPathComponent("Library/AppBox/AppBoxStore.sqlite")
    }
}
