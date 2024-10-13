//
//  TipCalcHistory_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension TipCalcHistory_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TipCalcHistory_> {
        return NSFetchRequest<TipCalcHistory_>(entityName: "TipCalcHistory_")
    }

    @NSManaged public var labelTip: String?
    @NSManaged public var labelTotal: String?
    @NSManaged public var uniqueID: String?
    @NSManaged public var updateDate: Date?

}
