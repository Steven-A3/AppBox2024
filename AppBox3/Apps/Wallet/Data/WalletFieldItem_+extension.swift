//
//  WalletFieldItem_+extension.swift
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 12/2/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//

import Foundation

@objc(WalletFieldItem_)
extension WalletFieldItem_ {
    @objc public var isImageField: Bool {
        // Fetch the WalletField_ object associated with this WalletFieldItem_
        if let walletField = fetchWalletField() {
            // Check if the type is WalletFieldTypeImage
            return walletField.type == "image"
        }
        return false
    }
    
    @objc public var isVideoField: Bool {
        // Fetch the WalletField_ object associated with this WalletFieldItem_
        if let walletField = fetchWalletField() {
            // Check if the type is WalletFieldTypeVideo
            return walletField.type == "video"
        }
        return false
    }
    
    // Helper method to fetch the associated WalletField_
    func fetchWalletField() -> WalletField_? {
        // Ensure the fieldID is set
        guard let fieldID = self.fieldID else {
            return nil
        }
        
        // Retrieve the managed object context
        guard let context = self.managedObjectContext else {
            return nil
        }
        
        // Create a fetch request
        let fetchRequest: NSFetchRequest<WalletField_> = WalletField_.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uniqueID == %@", fieldID)
        fetchRequest.fetchLimit = 1 // We only need one match
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first // Return the first (and only) result
        } catch {
            print("Error fetching WalletField: \(error.localizedDescription)")
            return nil
        }
    }
}
