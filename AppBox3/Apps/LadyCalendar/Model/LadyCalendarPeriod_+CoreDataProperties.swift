//
//  LadyCalendarPeriod_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension LadyCalendarPeriod_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LadyCalendarPeriod_> {
        return NSFetchRequest<LadyCalendarPeriod_>(entityName: "LadyCalendarPeriod_")
    }

    @NSManaged public var accountID: String?
    @NSManaged public var cycleLength: NSNumber?
    @NSManaged public var endDate: Date?
    @NSManaged public var isAutoSave: NSNumber?
    @NSManaged public var isPredict: NSNumber?
    @NSManaged public var notes: String?
    @NSManaged public var ovulation: Date?
    @NSManaged public var periodEnds: Date?
    @NSManaged public var startDate: Date?
    @NSManaged public var uniqueID: String?
    @NSManaged public var updateDate: Date?

}
