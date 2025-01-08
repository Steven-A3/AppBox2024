//
//  CoreDataStack+Delete.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 12/20/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//

import Foundation
import CloudKit

extension CoreDataStack {
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
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                    deleteRequest.resultType = .resultTypeObjectIDs
                    let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
                    if let objectIDs = result?.result as? [NSManagedObjectID] {
                        let changes = [NSDeletedObjectsKey: objectIDs]
                        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
                    }
                }
                try context.save()
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
    }
    
    public func resetCloudKitSync(_ completion: @escaping @convention(block) (Bool, Error?) -> Void) {
        let container = CKContainer(identifier: iCloudConstants.ICLOUD_CONTAINER_IDENTIFIER)
        deleteAllCustomZones(from: container
        ) { result in
            switch result {
            case .success:
                print("Successfully reset CloudKit sync.")
                completion(true, nil)
            case .failure(let error):
                print("Failed to reset CloudKit sync: \(error.localizedDescription)")
                completion(false, error)
            }
        }
    }
    
    public func deleteAllCustomZones(from container: CKContainer, completion: @escaping (Result<Void, Error>) -> Void) {
        let database = container.privateCloudDatabase
        
        // Fetch all record zones
        database.fetchAllRecordZones { zones, error in
            if let error = error {
                print("Failed to fetch zones: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let zones = zones else {
                print("No zones found.")
                completion(.success(()))
                return
            }
            
            // Extract the zone IDs from the zones
            let customZoneIDs = zones.map { $0.zoneID }
            
            if customZoneIDs.isEmpty {
                print("No custom zones to delete.")
                completion(.success(()))
                return
            }
            
            // Create an operation to delete the custom zones
            let modifyZonesOperation = CKModifyRecordZonesOperation(recordZonesToSave: nil, recordZoneIDsToDelete: customZoneIDs)
            
            modifyZonesOperation.modifyRecordZonesResultBlock = { result in
                switch result {
                case .success:
                    print("Successfully deleted all custom zones.")
                    completion(.success(()))
                case .failure(let error):
                    print("Failed to delete custom zones: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            
            // Add the operation to the database
            database.add(modifyZonesOperation)
        }
    }
    
    func performDeduplicationIfNeeded(forceDeduplication: Bool = false) {
        Logger.shared.debug("Performing deduplication...")
        fetchLastDeduplicationTimestamp { [weak self] lastTimestamp in
            guard let self = self else { return }
            
            let now = Date()
            if !forceDeduplication {
                if let lastTimestamp = lastTimestamp, now.timeIntervalSince(lastTimestamp) < self.minimumInterval {
                    Logger.shared.debug("Deduplication skipped: Last performed less than \(self.minimumInterval / 60) minutes ago.")
                    return
                }
            }

            // Update timestamp in CloudKit
            self.updateDeduplicationTimestamp(date: now)
            
            guard let context = self.persistentContainer?.viewContext else {
                Logger.shared.error("No persistent container available.")
                return
            }

            // Perform deduplication in a thread-safe manner
            context.perform {
                do {
                    try self.deduplicateAllEntities(context: context)
                    Logger.shared.debug("Deduplication completed successfully.")
                } catch {
                    Logger.shared.error("Error deduplicating entities: \(error)")
                }
            }
        }
    }

    private func fetchLastDeduplicationTimestamp(completion: @escaping (Date?) -> Void) {
        let container = CKContainer(identifier: iCloudConstants.ICLOUD_CONTAINER_IDENTIFIER)
        let database = container.privateCloudDatabase
        database.fetch(withRecordID: deduplicationRecordID) { record, error in
            if let error = error as? CKError, error.code == .unknownItem {
                // No existing deduplication record found
                completion(nil)
            } else if let error = error {
                Logger.shared.error("Error fetching deduplication record: \(error.localizedDescription)")
                completion(nil)
            } else if let record = record {
                let lastTimestamp = record["lastDeduplicationDate"] as? Date
                completion(lastTimestamp)
            }
        }
    }

    public func updateDeduplicationTimestamp(date: Date) {
        cloudDatabase.fetch(withRecordID: deduplicationRecordID) { [weak self] record, error in
            guard let self = self else { return }
            
            let recordToSave: CKRecord
            if let record = record {
                record["lastDeduplicationDate"] = date as CKRecordValue
                recordToSave = record
            } else {
                let newRecord = CKRecord(recordType: "DeduplicationTimestamp", recordID: self.deduplicationRecordID)
                newRecord["lastDeduplicationDate"] = date as CKRecordValue
                recordToSave = newRecord
            }

            self.cloudDatabase.save(recordToSave) { _, error in
                if let error = error {
                    Logger.shared.error("Error updating deduplication timestamp: \(error.localizedDescription)")
                } else {
                    Logger.shared.debug("Deduplication timestamp updated successfully.")
                }
            }
        }
    }

    public func deduplicateAllEntities(context: NSManagedObjectContext) throws {
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
            throw NSError(domain: "CoreData", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to retrieve Core Data model"])
        }
        
        // Iterate over all entities in the model
        for entity in model.entities {
            guard let entityName = entity.name else {
                Logger.shared.warning("Entity without a name found. Skipping...")
                continue
            }
            
            Logger.shared.debug("Processing entity: \(entityName)")
            
            // Deduplicate the current entity
            try deduplicateEntities(entityName: entityName, context: context)
        }
    }

    public func deduplicateEntities(entityName: String, context: NSManagedObjectContext) throws {
        try context.performAndWait {
            // Fetch all objects for the entity
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
            
            do {
                let allEntities = try context.fetch(fetchRequest)
                
                // Group entities by "uniqueID"
                let groupedEntities = Dictionary(grouping: allEntities) { entity in
                    entity.value(forKey: "uniqueID") as? String ?? ""
                }
                
                // Deduplicate by keeping only one object for each "uniqueID"
                for (_, duplicates) in groupedEntities {
                    if duplicates.count > 1 {
                        Logger.shared.debug("Duplicate entities found for \(entityName). Deleting...")
                        for duplicate in duplicates.dropFirst() {
                            context.delete(duplicate)
                        }
                    }
                }
                
                // Save changes to persist deletions
                if context.hasChanges {
                    try context.save()
                    Logger.shared.debug("Changes saved successfully for \(entityName).")
                }
            } catch {
                Logger.shared.error("Error fetching or deduplicating entities for \(entityName): \(error)")
                throw error
            }
        }
    }
}
