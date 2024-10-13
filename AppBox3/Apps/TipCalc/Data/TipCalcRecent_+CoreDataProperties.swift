//
//  TipCalcRecent_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension TipCalcRecent_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TipCalcRecent_> {
        return NSFetchRequest<TipCalcRecent_>(entityName: "TipCalcRecent_")
    }

    @NSManaged public var beforeSplit: NSNumber?
    @NSManaged public var costs: NSNumber?
    @NSManaged public var currencyCode: String?
    @NSManaged public var historyID: String?
    @NSManaged public var isMain: NSNumber?
    @NSManaged public var isPercentTax: NSNumber?
    @NSManaged public var isPercentTip: NSNumber?
    @NSManaged public var knownValue: NSNumber?
    @NSManaged public var optionType: NSNumber?
    @NSManaged public var showRounding: NSNumber?
    @NSManaged public var showSplit: NSNumber?
    @NSManaged public var showTax: NSNumber?
    @NSManaged public var split: NSNumber?
    @NSManaged public var tax: NSNumber?
    @NSManaged public var tip: NSNumber?
    @NSManaged public var uniqueID: String?
    @NSManaged public var updateDate: Date?
    @NSManaged public var valueType: NSNumber?

}
