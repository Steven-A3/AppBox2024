//
//  ExpenseListBudget_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension ExpenseListBudget_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExpenseListBudget_> {
        return NSFetchRequest<ExpenseListBudget_>(entityName: "ExpenseListBudget_")
    }

    @NSManaged public var category: String?
    @NSManaged public var currencyCode: String?
    @NSManaged public var date: Date?
    @NSManaged public var isModified: NSNumber?
    @NSManaged public var location: Data?
    @NSManaged public var notes: String?
    @NSManaged public var paymentType: String?
    @NSManaged public var title: String?
    @NSManaged public var totalAmount: NSNumber?
    @NSManaged public var uniqueID: String?
    @NSManaged public var updateDate: Date?
    @NSManaged public var usedAmount: NSNumber?

}
