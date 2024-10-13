//
//  LadyCalendarAccount_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension LadyCalendarAccount_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LadyCalendarAccount_> {
        return NSFetchRequest<LadyCalendarAccount_>(entityName: "LadyCalendarAccount_")
    }

    @NSManaged public var birthday: Date?
    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var order: String?
    @NSManaged public var uniqueID: String?
    @NSManaged public var watchingDate: Date?

}
