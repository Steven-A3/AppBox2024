//
//  LoanCalcComparisonHistory_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension LoanCalcComparisonHistory_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LoanCalcComparisonHistory_> {
        return NSFetchRequest<LoanCalcComparisonHistory_>(entityName: "LoanCalcComparisonHistory_")
    }

    @NSManaged public var currencyCode: String?
    @NSManaged public var totalAmountA: String?
    @NSManaged public var totalAmountB: String?
    @NSManaged public var totalInterestA: String?
    @NSManaged public var totalInterestB: String?
    @NSManaged public var uniqueID: String?
    @NSManaged public var updateDate: Date?

}
