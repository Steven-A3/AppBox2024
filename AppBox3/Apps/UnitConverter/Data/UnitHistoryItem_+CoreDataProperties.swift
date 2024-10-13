//
//  UnitHistoryItem_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension UnitHistoryItem_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UnitHistoryItem_> {
        return NSFetchRequest<UnitHistoryItem_>(entityName: "UnitHistoryItem_")
    }

    @NSManaged public var order: String?
    @NSManaged public var targetUnitItemID: NSNumber?
    @NSManaged public var uniqueID: String?
    @NSManaged public var unitHistoryID: String?
    @NSManaged public var updateDate: Date?

}
