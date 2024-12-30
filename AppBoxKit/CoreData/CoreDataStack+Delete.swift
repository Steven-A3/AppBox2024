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
}
