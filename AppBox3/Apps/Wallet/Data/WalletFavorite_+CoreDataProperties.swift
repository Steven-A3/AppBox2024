//
//  WalletFavorite_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension WalletFavorite_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WalletFavorite_> {
        return NSFetchRequest<WalletFavorite_>(entityName: "WalletFavorite_")
    }

    @NSManaged public var itemID: String?
    @NSManaged public var order: String?
    @NSManaged public var uniqueID: String?
    @NSManaged public var updateDate: Date?

}
