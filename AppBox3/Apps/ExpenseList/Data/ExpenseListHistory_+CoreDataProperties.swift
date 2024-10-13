//
//  ExpenseListHistory_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension ExpenseListHistory_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExpenseListHistory_> {
        return NSFetchRequest<ExpenseListHistory_>(entityName: "ExpenseListHistory_")
    }

    @NSManaged public var budgetID: String?
    @NSManaged public var uniqueID: String?
    @NSManaged public var updateDate: Date?

}
