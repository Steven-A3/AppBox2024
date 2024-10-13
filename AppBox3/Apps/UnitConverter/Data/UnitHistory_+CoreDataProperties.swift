//
//  UnitHistory_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension UnitHistory_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UnitHistory_> {
        return NSFetchRequest<UnitHistory_>(entityName: "UnitHistory_")
    }

    @NSManaged public var categoryID: NSNumber?
    @NSManaged public var uniqueID: String?
    @NSManaged public var unitID: NSNumber?
    @NSManaged public var updateDate: Date?
    @NSManaged public var value: NSNumber?

}
