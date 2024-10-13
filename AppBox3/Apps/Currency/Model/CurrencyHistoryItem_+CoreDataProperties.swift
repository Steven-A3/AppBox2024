//
//  CurrencyHistoryItem_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension CurrencyHistoryItem_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrencyHistoryItem_> {
        return NSFetchRequest<CurrencyHistoryItem_>(entityName: "CurrencyHistoryItem_")
    }

    @NSManaged public var currencyCode: String?
    @NSManaged public var historyID: String?
    @NSManaged public var order: String?
    @NSManaged public var rate: NSNumber?
    @NSManaged public var uniqueID: String?
    @NSManaged public var updateDate: Date?

}
