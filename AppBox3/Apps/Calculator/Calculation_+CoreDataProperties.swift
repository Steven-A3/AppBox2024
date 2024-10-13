//
//  Calculation_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension Calculation_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Calculation_> {
        return NSFetchRequest<Calculation_>(entityName: "Calculation_")
    }

    @NSManaged public var expression: String?
    @NSManaged public var result: String?
    @NSManaged public var uniqueID: String?
    @NSManaged public var updateDate: Date?

}
