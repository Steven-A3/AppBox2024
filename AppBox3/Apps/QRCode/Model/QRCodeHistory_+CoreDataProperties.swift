//
//  QRCodeHistory_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension QRCodeHistory_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<QRCodeHistory_> {
        return NSFetchRequest<QRCodeHistory_>(entityName: "QRCodeHistory_")
    }

    @NSManaged public var created: Date?
    @NSManaged public var dimension: String?
    @NSManaged public var productName: String?
    @NSManaged public var scanData: String?
    @NSManaged public var searchData: Data?
    @NSManaged public var type: String?
    @NSManaged public var uniqueID: String?

}
