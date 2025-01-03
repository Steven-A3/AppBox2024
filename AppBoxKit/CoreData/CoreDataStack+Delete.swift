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
}
