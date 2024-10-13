//
//  CurrencyFavorite_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension CurrencyFavorite_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CurrencyFavorite_> {
        return NSFetchRequest<CurrencyFavorite_>(entityName: "CurrencyFavorite_")
    }

    @NSManaged public var order: String?
    @NSManaged public var uniqueID: String?

}
