//
//  ExpenseListItem_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension ExpenseListItem_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExpenseListItem_> {
        return NSFetchRequest<ExpenseListItem_>(entityName: "ExpenseListItem_")
    }

    @NSManaged public var budgetID: String?
    @NSManaged public var hasData: NSNumber?
    @NSManaged public var itemDate: Date?
    @NSManaged public var itemName: String?
    @NSManaged public var order: String?
    @NSManaged public var price: NSNumber?
    @NSManaged public var qty: NSNumber?
    @NSManaged public var subTotal: NSNumber?
    @NSManaged public var uniqueID: String?
    @NSManaged public var updateDate: Date?

}
