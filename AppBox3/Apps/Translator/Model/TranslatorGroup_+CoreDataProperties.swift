//
//  TranslatorGroup_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension TranslatorGroup_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TranslatorGroup_> {
        return NSFetchRequest<TranslatorGroup_>(entityName: "TranslatorGroup_")
    }

    @NSManaged public var order: String?
    @NSManaged public var sourceLanguage: String?
    @NSManaged public var targetLanguage: String?
    @NSManaged public var uniqueID: String?
    @NSManaged public var updateDate: Date?

}
