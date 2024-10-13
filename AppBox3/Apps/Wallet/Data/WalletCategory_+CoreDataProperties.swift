//
//  WalletCategory_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension WalletCategory_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WalletCategory_> {
        return NSFetchRequest<WalletCategory_>(entityName: "WalletCategory_")
    }

    @NSManaged public var doNotShow: NSNumber?
    @NSManaged public var icon: String?
    @NSManaged public var isSystem: NSNumber?
    @NSManaged public var name: String?
    @NSManaged public var order: String?
    @NSManaged public var uniqueID: String?

}
