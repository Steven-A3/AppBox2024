//
//  WalletItem_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension WalletItem_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WalletItem_> {
        return NSFetchRequest<WalletItem_>(entityName: "WalletItem_")
    }

    @NSManaged public var categoryID: String?
    @NSManaged public var lastOpened: Date?
    @NSManaged public var name: String?
    @NSManaged public var note: String?
    @NSManaged public var order: String?
    @NSManaged public var uniqueID: String?
    @NSManaged public var updateDate: Date?

}
