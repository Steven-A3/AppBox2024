//
//  Pedometer_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension Pedometer_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pedometer_> {
        return NSFetchRequest<Pedometer_>(entityName: "Pedometer_")
    }

    @NSManaged public var date: String?
    @NSManaged public var distance: NSNumber?
    @NSManaged public var floorsAscended: NSNumber?
    @NSManaged public var floorsDescended: NSNumber?
    @NSManaged public var numberOfSteps: NSNumber?
    @NSManaged public var uniqueID: String?

}
