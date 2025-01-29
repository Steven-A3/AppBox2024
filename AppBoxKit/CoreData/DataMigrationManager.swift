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
    var oldPersistentContainer: NSPersistentContainer?
    var newPersistentContainer: NSPersistentContainer?
    
    // Progress Tracking
    @Published var progress: Double = 0.0
    @Published var isMigrating: Bool = false
    @Published var isMigrationComplete: Bool = false
#if DEBUG
    @Published var isPreviewMode: Bool = false
#endif

    private let migrationQueue = OperationQueue()
    
    @objc public
    override init() {
        super.init()
        
        migrationQueue.maxConcurrentOperationCount = 1 // Adjust concurrency as needed
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
    func migrateData(fromV3: Bool, sourceContainer: NSPersistentContainer, completion: @escaping () -> Void) {
        self.oldPersistentContainer = sourceContainer
        self.newPersistentContainer = CoreDataStack.shared.persistentContainer

        isMigrating = true
        progress = 0.0
        
        Logger.shared.debug("Migrating data from version 3...")
        UIApplication.printCallStackIfDebug()
        
        let startTime = Date()
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
        newPersistentContainer!.viewContext.automaticallyMergesChangesFromParent = false
        
        for (index, entityName) in entitiesToMigrate.enumerated() {
            let operation = MigrationOperation(
                context: oldPersistentContainer!.viewContext,
                newContext: newPersistentContainer!.viewContext,
                entityName: entityName,
                batchSize: 3000,
                isFromV3: fromV3
            )
            
            operation.completionBlock = { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.progress = Double(index + 1) / Double(totalEntities)
                    print("completion block for \(index + 1) of \(totalEntities): \(entityName) migration complete")
                }
            }
            
            migrationQueue.addOperation(operation)
        }
        
        migrationQueue.addBarrierBlock { [weak self] in
            print("barrier block")
            
            guard let self = self else { return }

            newPersistentContainer?.viewContext.automaticallyMergesChangesFromParent = true

            let timeElapsed = Date().timeIntervalSince(startTime)
            let delayTime = max(2.0 - timeElapsed, 0)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
                self.isMigrating = false
                self.cleanupMemory()
                self.isMigrationComplete = true
                Logger.shared.debug("isMigrationComplete = \(self.isMigrationComplete)")
                completion()
            }
        }
    }
    
    private func cleanupMemory() {
        guard let oldPersistentContainer = oldPersistentContainer else {
            return
        }
        oldPersistentContainer.viewContext.reset()
        
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
        let stack = CoreDataStack.shared
        let sourceBaseURL = stack.appGroupContainerURL()!
        stack.loadPersistentContainer(modelName: "AppBox3", baseURL: sourceBaseURL) { sourceContainer, storeDescription, error in
            guard let sourceContainer = sourceContainer else {
                Logger.shared.error("Error loading source container: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            self.migrateData(fromV3: true, sourceContainer: sourceContainer) {
                if #available(iOS 17.0, *) {
                    let mediaManager = CloudKitMediaFileManagerWrapper.shared
                    let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: iCloudConstants.APP_GROUP_CONTAINER_IDENTIFIER)!.appendingPathComponent(iCloudConstants.MEDIA_FILES_PATH)
                    
                    mediaManager.addAllMediaFiles(from: url) { error in
                        completion()
                    }
                } else {
                    completion()
                }
            }
        }
    }
}

// MARK: - Migration Operation
class MigrationOperation: Operation, @unchecked Sendable {
    private let context: NSManagedObjectContext
    private let newContext: NSManagedObjectContext
    private let entityName: String
    private let batchSize: Int
    private let isFromV3: Bool
    
    init(context: NSManagedObjectContext, newContext: NSManagedObjectContext, entityName: String, batchSize: Int, isFromV3: Bool) {
        self.context = context
        self.newContext = newContext
        self.entityName = entityName
        self.batchSize = batchSize
        self.isFromV3 = isFromV3
    }
    
    override func main() {
        if isCancelled { return }
        
        let sourceEntityName = isFromV3 ? entityName : entityName + "_"
        let newEntityName = entityName + "_"
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: sourceEntityName)
        fetchRequest.fetchBatchSize = batchSize
        let isiCloudAvailable = FileManager.default.ubiquityIdentityToken != nil
        
        do {
            let totalEntityCount = try context.count(for: fetchRequest)
            var currentBatchIndex = 0
            
            while currentBatchIndex * batchSize < totalEntityCount {
                if isCancelled { return }
                
                fetchRequest.fetchOffset = currentBatchIndex * batchSize
                
                CoreDataStack.shared.migrateEntity(context, fetchRequest, sourceEntityName, newContext, newEntityName, iCloudAvailable: isiCloudAvailable)
                currentBatchIndex += 1
            }
            print("Finished migrating operation \(sourceEntityName) total \(totalEntityCount)")
        } catch {
            print("Error migrating operation \(sourceEntityName): \(error)")
        }
    }
}
