//
//  UnitPriceInfo_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension UnitPriceInfo_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UnitPriceInfo_> {
        return NSFetchRequest<UnitPriceInfo_>(entityName: "UnitPriceInfo_")
    }

    @NSManaged public var discountPercent: NSNumber?
    @NSManaged public var discountPrice: NSNumber?
    @NSManaged public var historyID: String?
    @NSManaged public var note: String?
    @NSManaged public var price: NSNumber?
    @NSManaged public var priceName: String?
    @NSManaged public var quantity: NSNumber?
    @NSManaged public var size: NSNumber?
    @NSManaged public var uniqueID: String?
    @NSManaged public var unitCategoryID: NSNumber?
    @NSManaged public var unitID: NSNumber?
    @NSManaged public var updateDate: Date?

}
