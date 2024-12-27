//
//  WalletCategory_+deduplicatio.swift
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 12/25/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//


import CoreData

extension WalletCategory_ {
    /// Deduplicates `WalletCategory_` records by deleting duplicates that share the same `uniqueID`.
    /// - Parameter context: The `NSManagedObjectContext` used for fetching and deleting.
    public static func deduplicate(in context: NSManagedObjectContext) throws {
        // Fetch all WalletCategory_ records
        let fetchRequest: NSFetchRequest<WalletCategory_> = WalletCategory_.fetchRequest()
        fetchRequest.includesPropertyValues = true // Include only necessary properties for efficiency

        let categories = try context.fetch(fetchRequest)

        // Group records by uniqueID
        let groupedByUniqueID = Dictionary(grouping: categories, by: { $0.uniqueID ?? "undefined" })

        // Iterate through groups and remove duplicates
        for (_, records) in groupedByUniqueID {
            if records.count > 1 {
                // Keep the first record and delete the rest
                for duplicate in records.dropFirst() {
                    context.delete(duplicate)
                }
            }
        }

        // Save changes
        if context.hasChanges {
            try context.save()
        }
    }
}
