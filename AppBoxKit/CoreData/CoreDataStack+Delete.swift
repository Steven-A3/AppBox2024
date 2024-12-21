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
}
