//
//  DaysCounterEvent_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension DaysCounterEvent_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DaysCounterEvent_> {
        return NSFetchRequest<DaysCounterEvent_>(entityName: "DaysCounterEvent_")
    }

    @NSManaged public var alertDatetime: Date?
    @NSManaged public var alertInterval: NSNumber?
    @NSManaged public var alertType: NSNumber?
    @NSManaged public var calendarID: String?
    @NSManaged public var durationOption: NSNumber?
    @NSManaged public var effectiveStartDate: Date?
    @NSManaged public var eventName: String?
    @NSManaged public var hasReminder: NSNumber?
    @NSManaged public var isAllDay: NSNumber?
    @NSManaged public var isLunar: NSNumber?
    @NSManaged public var isPeriod: NSNumber?
    @NSManaged public var notes: String?
    @NSManaged public var photoID: String?
    @NSManaged public var repeatEndDate: Date?
    @NSManaged public var repeatType: NSNumber?
    @NSManaged public var uniqueID: String?
    @NSManaged public var updateDate: Date?

}
