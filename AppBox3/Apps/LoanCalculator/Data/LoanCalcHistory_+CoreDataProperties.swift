//
//  LoanCalcHistory_+CoreDataProperties.swift
//  
//
//  Created by BYEONG KWON KWAK on 10/2/24.
//
//

import Foundation
import CoreData


extension LoanCalcHistory_ {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LoanCalcHistory_> {
        return NSFetchRequest<LoanCalcHistory_>(entityName: "LoanCalcHistory_")
    }

    @NSManaged public var calculationMode: NSNumber?
    @NSManaged public var comparisonHistoryID: String?
    @NSManaged public var currencyCode: String?
    @NSManaged public var downPayment: String?
    @NSManaged public var editing: NSNumber?
    @NSManaged public var extraPaymentMonthly: String?
    @NSManaged public var extraPaymentOnetime: String?
    @NSManaged public var extraPaymentOnetimeYearMonth: Date?
    @NSManaged public var extraPaymentYearly: String?
    @NSManaged public var extraPaymentYearlyMonth: Date?
    @NSManaged public var frequency: NSNumber?
    @NSManaged public var interestRate: String?
    @NSManaged public var interestRatePerYear: NSNumber?
    @NSManaged public var location: String?
    @NSManaged public var monthlyPayment: String?
    @NSManaged public var notes: String?
    @NSManaged public var orderInComparison: String?
    @NSManaged public var principal: String?
    @NSManaged public var showAdvanced: NSNumber?
    @NSManaged public var showDownPayment: NSNumber?
    @NSManaged public var showExtraPayment: NSNumber?
    @NSManaged public var startDate: Date?
    @NSManaged public var term: String?
    @NSManaged public var termTypeMonth: NSNumber?
    @NSManaged public var uniqueID: String?
    @NSManaged public var updateDate: Date?
    @NSManaged public var useSimpleInterest: NSNumber?

}
