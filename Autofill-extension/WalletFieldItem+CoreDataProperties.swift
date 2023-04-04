//
//  WalletFieldItem+CoreDataProperties.swift
//  Autofill Extension
//
//  Created by BYEONG KWON KWAK on 2023/03/30.
//  Copyright © 2023 ALLABOUTAPPS. All rights reserved.
//
//

import Foundation
import CoreData


extension WalletFieldItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WalletFieldItem> {
        return NSFetchRequest<WalletFieldItem>(entityName: "WalletFieldItem")
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
