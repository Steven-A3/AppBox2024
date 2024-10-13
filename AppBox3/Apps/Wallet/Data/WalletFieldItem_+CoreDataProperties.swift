//
//  WalletFieldItem_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/5/24.
//
//

import Foundation
import CoreData


extension WalletFieldItem_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WalletFieldItem_> {
        return NSFetchRequest<WalletFieldItem_>(entityName: "WalletFieldItem_")
    }

    @NSManaged public var date: Date?
    @NSManaged public var fieldID: String?
    @NSManaged public var hasImage: NSNumber?
    @NSManaged public var hasVideo: NSNumber?
    @NSManaged public var imageMetaData: Data?
    @NSManaged public var uniqueID: String?
    @NSManaged public var updateDate: Date?
    @NSManaged public var value: String?
    @NSManaged public var videoCreationDate: Date?
    @NSManaged public var videoExtension: String?
    @NSManaged public var walletItemID: String?

}
