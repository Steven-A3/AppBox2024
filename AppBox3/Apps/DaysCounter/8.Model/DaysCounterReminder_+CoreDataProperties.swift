//
//  DaysCounterReminder_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension DaysCounterReminder_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DaysCounterReminder_> {
        return NSFetchRequest<DaysCounterReminder_>(entityName: "DaysCounterReminder_")
    }

    @NSManaged public var alertDate: Date?
    @NSManaged public var eventID: String?
    @NSManaged public var isOn: NSNumber?
    @NSManaged public var isUnread: NSNumber?
    @NSManaged public var startDate: Date?
    @NSManaged public var uniqueID: String?
    @NSManaged public var updateDate: Date?

}
