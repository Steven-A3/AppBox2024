//
//  WalletField_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension WalletField_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WalletField_> {
        return NSFetchRequest<WalletField_>(entityName: "WalletField_")
    }

    @NSManaged public var categoryID: String?
    @NSManaged public var name: String?
    @NSManaged public var order: String?
    @NSManaged public var style: String?
    @NSManaged public var type: String?
    @NSManaged public var uniqueID: String?

}
