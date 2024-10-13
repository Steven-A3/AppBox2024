//
//  DaysCounterDate_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension DaysCounterDate_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DaysCounterDate_> {
        return NSFetchRequest<DaysCounterDate_>(entityName: "DaysCounterDate_")
    }

    @NSManaged public var day: NSNumber?
    @NSManaged public var eventID: String?
    @NSManaged public var hour: NSNumber?
    @NSManaged public var isLeapMonth: NSNumber?
    @NSManaged public var isStartDate: NSNumber?
    @NSManaged public var minute: NSNumber?
    @NSManaged public var month: NSNumber?
    @NSManaged public var solarDate: Date?
    @NSManaged public var uniqueID: String?
    @NSManaged public var updateDate: Date?
    @NSManaged public var year: NSNumber?

}
