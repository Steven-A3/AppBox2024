//
//  NSManagedObject+extension.swift
//  AppBoxKit
//
//  Created by BYEONG KWON KWAK on 1/30/25.
//  Copyright © 2025 ALLABOUTAPPS. All rights reserved.
//

import CoreData

extension NSManagedObject {
    @objc public class func findFirst(
        with predicate: NSPredicate?,
        sortedBy property: String?,
        ascending: Bool,
        in context: NSManagedObjectContext
    ) -> NSManagedObject? {
        var firstObject: NSManagedObject? = nil

        context.performAndWait {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: String(describing: self))
            if let predicate = predicate {
                fetchRequest.predicate = predicate
            }
            if let property = property {
                let sortDescriptor = NSSortDescriptor(key: property, ascending: ascending)
                fetchRequest.sortDescriptors = [sortDescriptor]
            }
            fetchRequest.fetchLimit = 1 // Fetch only 1 result

            do {
                firstObject = try context.fetch(fetchRequest).first
            } catch {
                print("Fetch error: \(error)")
            }
        }

        return firstObject
    }
}
