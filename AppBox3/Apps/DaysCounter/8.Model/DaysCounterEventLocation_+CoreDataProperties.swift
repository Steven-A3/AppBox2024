//
//  DaysCounterEventLocation_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension DaysCounterEventLocation_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DaysCounterEventLocation_> {
        return NSFetchRequest<DaysCounterEventLocation_>(entityName: "DaysCounterEventLocation_")
    }

    @NSManaged public var address: String?
    @NSManaged public var city: String?
    @NSManaged public var contact: String?
    @NSManaged public var country: String?
    @NSManaged public var eventID: String?
    @NSManaged public var latitude: NSNumber?
    @NSManaged public var locationName: String?
    @NSManaged public var longitude: NSNumber?
    @NSManaged public var state: String?
    @NSManaged public var uniqueID: String?
    @NSManaged public var updateDate: Date?

}
