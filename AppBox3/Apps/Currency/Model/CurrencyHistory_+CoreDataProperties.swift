//
//  CurrencyHistory_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension CurrencyHistory_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrencyHistory_> {
        return NSFetchRequest<CurrencyHistory_>(entityName: "CurrencyHistory_")
    }

    @NSManaged public var currencyCode: String?
    @NSManaged public var rate: NSNumber?
    @NSManaged public var uniqueID: String?
    @NSManaged public var updateDate: Date?
    @NSManaged public var value: NSNumber?

}
