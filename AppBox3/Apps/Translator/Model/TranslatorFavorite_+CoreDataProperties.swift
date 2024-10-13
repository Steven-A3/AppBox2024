//
//  TranslatorFavorite_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension TranslatorFavorite_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TranslatorFavorite_> {
        return NSFetchRequest<TranslatorFavorite_>(entityName: "TranslatorFavorite_")
    }

    @NSManaged public var groupID: String?
    @NSManaged public var historyID: String?
    @NSManaged public var order: String?
    @NSManaged public var uniqueID: String?
    @NSManaged public var updateDate: Date?

}
