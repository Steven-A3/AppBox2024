//
//  DaysCounterFavorite_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension DaysCounterFavorite_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DaysCounterFavorite_> {
        return NSFetchRequest<DaysCounterFavorite_>(entityName: "DaysCounterFavorite_")
    }

    @NSManaged public var eventID: String?
    @NSManaged public var order: String?
    @NSManaged public var uniqueID: String?
    @NSManaged public var updateDate: Date?

}
