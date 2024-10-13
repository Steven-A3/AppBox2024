//
//  TranslatorHistory_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension TranslatorHistory_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TranslatorHistory_> {
        return NSFetchRequest<TranslatorHistory_>(entityName: "TranslatorHistory_")
    }

    @NSManaged public var groupID: String?
    @NSManaged public var originalText: String?
    @NSManaged public var translatedText: String?
    @NSManaged public var uniqueID: String?
    @NSManaged public var updateDate: Date?

}
