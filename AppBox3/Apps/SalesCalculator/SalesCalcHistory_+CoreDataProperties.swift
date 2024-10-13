//
//  SalesCalcHistory_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension SalesCalcHistory_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SalesCalcHistory_> {
        return NSFetchRequest<SalesCalcHistory_>(entityName: "SalesCalcHistory_")
    }

    @NSManaged public var additionalOff: NSNumber?
    @NSManaged public var additionalOffType: NSNumber?
    @NSManaged public var currencyCode: String?
    @NSManaged public var discount: NSNumber?
    @NSManaged public var discountType: NSNumber?
    @NSManaged public var notes: String?
    @NSManaged public var price: NSNumber?
    @NSManaged public var priceType: NSNumber?
    @NSManaged public var shownPriceType: NSNumber?
    @NSManaged public var tax: NSNumber?
    @NSManaged public var taxType: NSNumber?
    @NSManaged public var uniqueID: String?
    @NSManaged public var updateDate: Date?

}
