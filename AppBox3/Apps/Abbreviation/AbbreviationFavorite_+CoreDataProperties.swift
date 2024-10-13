//
//  AbbreviationFavorite_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension AbbreviationFavorite_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AbbreviationFavorite_> {
        return NSFetchRequest<AbbreviationFavorite_>(entityName: "AbbreviationFavorite_")
    }

    @NSManaged public var order: String?
    @NSManaged public var uniqueID: String?

}
