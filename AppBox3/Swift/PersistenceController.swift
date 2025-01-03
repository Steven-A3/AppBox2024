//
//  PersistenceController.swift
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 12/31/24.
//  Copyright © 2024 ALLABOUTAPPS. All rights reserved.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Add mock data for the preview
        if let entity = NSEntityDescription.entity(forEntityName: "WalletItem_", in: viewContext) {
            for i in 0..<5 {
                let newItem = NSManagedObject(entity: entity, insertInto: viewContext) as! WalletItem_
                newItem.name = "Item \(i)"
                newItem.updateDate = Calendar.current.date(byAdding: .day, value: -i, to: Date())
                newItem.categoryID = "Category \(i % 2)" // Group by 2 categories
            }

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        } else {
            fatalError("Failed to create entity for preview")
        }

        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "AppBox2024")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
            container.persistentStoreDescriptions.first!.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        }

        container.loadPersistentStores(completionHandler: {(description, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
