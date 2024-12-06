//
//  A3AppDelegate+CloudKit.swift
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 12/1/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//

import Foundation
import CoreData

extension A3AppDelegate {
    @objc public func handleRemoteChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            print("No userInfo in NSPersistentStoreRemoteChange notification.")
            return
        }
        
        guard let context = CoreDataStack.shared.persistentContainer?.viewContext else {
            print("Persistent container viewContext is nil.")
            return
        }
        
        // Extract the persistent history token
        guard let changeNotifications = userInfo[NSPersistentHistoryTokenKey] as? NSPersistentHistoryToken else {
            print("No persistent history token found in userInfo.")
            return
        }
        
        let fetchRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: changeNotifications)
        fetchRequest.resultType = .transactionsAndChanges
        
        do {
            if let result = try context.execute(fetchRequest) as? NSPersistentHistoryResult,
               let transactions = result.result as? [NSPersistentHistoryTransaction] {
                
                for transaction in transactions {
                    for change in transaction.changes ?? [] {
                        let objectID = change.changedObjectID
                        
                        if let entityName = objectID.entity.name, entityName == "WalletFieldItem_" {
                            handleChange(change, for: objectID, context: context)
                        }
                    }
                }
            }
        } catch {
            print("Error fetching persistent history changes: \(error.localizedDescription)")
        }
    }
    
    private func handleChange(_ change: NSPersistentHistoryChange, for objectID: NSManagedObjectID, context: NSManagedObjectContext) {
        switch change.changeType {
        case .insert:
            handleInsert(for: objectID, context: context)
        case .update:
            handleUpdate(for: objectID, context: context)
        case .delete:
            handleDelete(for: objectID, context: context)
        default:
            print("Unhandled change type: \(change.changeType)")
        }
    }

    // Handle Insert
    private func handleInsert(for objectID: NSManagedObjectID, context: NSManagedObjectContext) {
        fetchWalletFieldItem(for: objectID, context: context) { walletFieldItem in
            if walletFieldItem.isImageField {
                print("WalletFieldItem_ with fieldType 'image' was added: \(walletFieldItem)")
                // Add additional handling logic for inserts
            }
        }
    }
    
    // Handle Update
    private func handleUpdate(for objectID: NSManagedObjectID, context: NSManagedObjectContext) {
        fetchWalletFieldItem(for: objectID, context: context) { walletFieldItem in
            if walletFieldItem.isImageField {
                print("WalletFieldItem_ with fieldType 'image' was updated: \(walletFieldItem)")
                // Add additional handling logic for updates
            }
        }
    }
    
    // Handle Delete
    private func handleDelete(for objectID: NSManagedObjectID, context: NSManagedObjectContext) {
        print("WalletFieldItem_ with objectID \(objectID) was deleted.")
        // Add additional handling logic for deletes
    }
    
    // Helper to fetch WalletFieldItem_
    private func fetchWalletFieldItem(for objectID: NSManagedObjectID, context: NSManagedObjectContext, completion: (WalletFieldItem_) -> Void) {
        do {
            let object = try context.existingObject(with: objectID)
            if let walletFieldItem = object as? WalletFieldItem_ {
                completion(walletFieldItem)
            } else {
                print("Object is not of type WalletFieldItem_: \(objectID)")
            }
        } catch {
            print("Error fetching WalletFieldItem: \(error.localizedDescription)")
        }
    }
}
