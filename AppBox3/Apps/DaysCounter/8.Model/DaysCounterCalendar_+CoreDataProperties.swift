//
//  DaysCounterCalendar_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension DaysCounterCalendar_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DaysCounterCalendar_> {
        return NSFetchRequest<DaysCounterCalendar_>(entityName: "DaysCounterCalendar_")
    }

    @NSManaged public var colorID: NSNumber?
    @NSManaged public var isShow: NSNumber?
    @NSManaged public var name: String?
    @NSManaged public var order: String?
    @NSManaged public var type: NSNumber?
    @NSManaged public var uniqueID: String?

}
