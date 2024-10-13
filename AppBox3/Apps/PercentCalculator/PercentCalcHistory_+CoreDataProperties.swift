//
//  PercentCalcHistory_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension PercentCalcHistory_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PercentCalcHistory_> {
        return NSFetchRequest<PercentCalcHistory_>(entityName: "PercentCalcHistory_")
    }

    @NSManaged public var historyItem: Data?
    @NSManaged public var uniqueID: String?
    @NSManaged public var updateDate: Date?

}
