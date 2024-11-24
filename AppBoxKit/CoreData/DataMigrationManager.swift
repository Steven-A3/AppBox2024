//
//  MigrationManager.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 10/13/24.
//

import CoreData
import CloudKit
import SwiftUI

@objcMembers public
class DataMigrationManager: NSObject, ObservableObject {
    
    // Core Data Persistent Containers
    var oldPersistentContainer: NSPersistentContainer
    var newPersistentContainer: NSPersistentContainer
    
    // Progress Tracking
    @Published var progress: Double = 0.0
    @Published var isMigrating: Bool = false
    @Published var isMigrationComplete: Bool = false
#if DEBUG
    @Published var isPreviewMode: Bool = false
#endif
    
    @objc public
    init(oldPersistentContainer: NSPersistentContainer, newPersistentContainer: NSPersistentContainer) {
        self.oldPersistentContainer = oldPersistentContainer
        self.newPersistentContainer = newPersistentContainer

#if DEBUG
        // Check if we are running in a preview environment in DEBUG mode
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            // Skip setting up Core Data containers in preview mode
            isPreviewMode = true
            return
        }
#endif
    }
    
    @objc public
    func migrateData(fromV3:Bool ,completion: @escaping () -> Void) {
        isMigrating = true
        progress = 0.0
        
        let startTime = Date()
        
#if DEBUG
        guard !isPreviewMode else {
            print("Skipping migration in preview mode")
            return
        }
#endif
        func finalize() {
            let timeElapsed = Date().timeIntervalSince(startTime)
            let delayTime = max(5.0 - timeElapsed, 0)
            DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
                self.isMigrating = false
                self.cleanupMemory()
                self.isMigrationComplete = true
                print("Migration complete")
                
                completion()
            }
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let context = self.oldPersistentContainer.viewContext
            let newContext = self.newPersistentContainer.viewContext
            
            // List of entity names to be migrated
            let entitiesToMigrate = [
                "AbbreviationFavorite", "Calculation", "CurrencyFavorite", "CurrencyHistory",
                "CurrencyHistoryItem", "DaysCounterCalendar", "DaysCounterDate", "DaysCounterEvent",
                "DaysCounterEventLocation", "DaysCounterFavorite", "DaysCounterReminder", "ExpenseListBudget",
                "ExpenseListBudgetLocation", "ExpenseListHistory", "ExpenseListItem", "KaomojiFavorite",
                "LadyCalendarAccount", "LadyCalendarPeriod", "LoanCalcComparisonHistory", "LoanCalcHistory",
                "Pedometer", "PercentCalcHistory", "QRCodeHistory", "SalesCalcHistory", "TipCalcHistory",
                "TipCalcRecent", "TranslatorFavorite", "TranslatorGroup", "TranslatorHistory", "UnitHistory",
                "UnitHistoryItem", "UnitPriceHistory", "UnitPriceInfo", "WalletCategory", "WalletFavorite",
                "WalletField", "WalletFieldItem", "WalletItem"
            ]
            
            let totalEntities = entitiesToMigrate.count
            let coreDataStack = CoreDataStack.shared
            var currentEntityIndex = 0
            
            for entityName in entitiesToMigrate {
                let batchSize: Int = 3000
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
                fetchRequest.fetchBatchSize = batchSize
                
                do {
                    let totalEntityCount = try context.count(for: fetchRequest)
                    print("Migrating \(entityName): \(totalEntityCount) entities")
                    
                    var currentBatchIndex = 0
                    while currentBatchIndex * batchSize < totalEntityCount {
                        fetchRequest.fetchOffset = currentBatchIndex * batchSize
                        let newEntityName = fromV3 ? entityName + "_" : entityName
                        coreDataStack.migrateEntity(context, fetchRequest, entityName, newContext, newEntityName)
                        
                        currentBatchIndex += 1
                    }
                } catch {
                    print("Error counting entities for \(entityName): \(error)")
                }
                
                currentEntityIndex += 1
                DispatchQueue.main.async {
                    self.progress = Double(currentEntityIndex) / Double(totalEntities)
                }
                print("Migrated \(entityName)")
            }
            
            finalize()
        }
    }
    
    private func cleanupMemory() {
        oldPersistentContainer.viewContext.reset()
        newPersistentContainer.viewContext.reset()
        
        DispatchQueue.main.async {
            self.triggerMemoryCleanup()
        }
    }
    
    @objc
    public func deleteStoreFiles(storeURL: URL) {
        let fileManager = FileManager.default
        let fileExtensions = ["sqlite", "sqlite-shm", "sqlite-wal"]
        
        for ext in fileExtensions {
            let fileURL = storeURL.deletingPathExtension().appendingPathExtension(ext)
            
            do {
                if fileManager.fileExists(atPath: fileURL.path) {
                    try fileManager.removeItem(at: fileURL)
                    print("Deleted old store file: \(fileURL.lastPathComponent)")
                } else {
                    print("Old store file \(fileURL.lastPathComponent) does not exist, skipping.")
                }
            } catch {
                print("Failed to delete \(fileURL.lastPathComponent): \(error)")
            }
        }
    }
    
    private func triggerMemoryCleanup() {
        for _ in 0..<10 {
            _ = [Int](repeating: 0, count: 100000)
        }
        print("Manual memory cleanup suggested to ARC.")
    }
    
    func migrateDataAfterUIChange(completion: @escaping () -> Void) {
        isMigrating = true
        progress = 0.0
        
#if DEBUG
        guard !isPreviewMode else {
            print("Skipping migration in preview mode")
            return
        }
#endif
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.migrateData(fromV3: true) {
                completion()
            }
        }
    }
}
