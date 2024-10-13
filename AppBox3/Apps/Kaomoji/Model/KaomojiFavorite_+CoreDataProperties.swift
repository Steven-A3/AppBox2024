//
//  KaomojiFavorite_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension KaomojiFavorite_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<KaomojiFavorite_> {
        return NSFetchRequest<KaomojiFavorite_>(entityName: "KaomojiFavorite_")
    }

    @NSManaged public var order: String?
    @NSManaged public var uniqueID: String?

}
