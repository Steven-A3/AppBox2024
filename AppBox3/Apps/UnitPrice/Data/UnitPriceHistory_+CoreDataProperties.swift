//
//  UnitPriceHistory_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension UnitPriceHistory_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UnitPriceHistory_> {
        return NSFetchRequest<UnitPriceHistory_>(entityName: "UnitPriceHistory_")
    }

    @NSManaged public var currencyCode: String?
    @NSManaged public var uniqueID: String?
    @NSManaged public var updateDate: Date?

}
