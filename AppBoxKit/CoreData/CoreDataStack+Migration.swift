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
            try context.performAndWait {
                // Fetch all old entities on the main thread's context
                let oldEntities = try context.fetch(fetchRequest)
                let staticOldEntities = oldEntities.map { $0 }
                let entityAttributes = oldEntities.first?.entity.attributesByName.keys.map { $0 } ?? []
                
                // Prepare a set of existing IDs in the background context
                var existingIDs: Set<String> = []
                newContext.performAndWait {
                    do {
                        let existingFetchRequest = NSFetchRequest<NSManagedObject>(entityName: newEntityName)
                        let existingEntities = try newContext.fetch(existingFetchRequest)
                        existingIDs = Set(existingEntities.compactMap { $0.value(forKey: "uniqueID") as? String })
                        
                        Logger.shared.debug("Migration found \(existingIDs.count) \(newEntityName) entities")
                    } catch {
                        Logger.shared.debug("Error fetching existing entities for \(newEntityName): \(error)")
                    }
                }
                
                // Migrate entities
                newContext.performAndWait {
                    for oldEntity in staticOldEntities {
                        if let uniqueID = oldEntity.value(forKey: "uniqueID") as? String, !existingIDs.contains(uniqueID) {
                            let newEntity = NSEntityDescription.insertNewObject(forEntityName: newEntityName, into: newContext)
                            for attribute in entityAttributes {
                                newEntity.setValue(oldEntity.value(forKey: attribute), forKey: attribute)
                            }
                        }
                    }
                    
                    // Save changes in the background context
                    if newContext.hasChanges {
                        do {
                            try newContext.save()
                        } catch {
                            Logger.shared.debug("Error saving new context for \(newEntityName): \(error)")
                        }
                    }
                }
            }
        } catch {
            Logger.shared.debug("Error migrating \(entityName): \(error)")
        }
    }
    
    public func V47StoreURL() -> URL {
        appGroupContainerURL()!.appendingPathComponent("AppBoxStore.sqlite")
    }
}
