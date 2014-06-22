//
//  LoanCalcString.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 8..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "LoanCalcString.h"
#import "LoanCalcData.h"


@implementation LoanCalcString

+ (NSString *)titleOfCalFor:(A3LoanCalcCalculationMode)mode
{
    switch (mode) {
        case A3LC_CalculationForDownPayment:
            return NSLocalizedString(@"Down Payment", nil);
        case A3LC_CalculationForRepayment:
            return NSLocalizedString(@"Payment", nil);
        case A3LC_CalculationForPrincipal:
            return NSLocalizedString(@"Principal", nil);
        case A3LC_CalculationForTermOfMonths:
            return NSLocalizedString(@"Term(years)", nil);
        case A3LC_CalculationForTermOfYears:
            return NSLocalizedString(@"Term(months)", nil);

        default:
            return @"";
    }
}

+ (NSString *)titleOfItem:(A3LoanCalcCalculationItem)item
{
    switch (item) {
        case A3LC_CalculationItemPrincipal:
            return NSLocalizedString(@"Principal", nil);
        case A3LC_CalculationItemDownPayment:
            return NSLocalizedString(@"Down Payment", nil);
        case A3LC_CalculationItemTerm:
            return NSLocalizedString(@"Term", nil);
        case A3LC_CalculationItemInterestRate:
            return NSLocalizedString(@"Interest Rate", nil);
        case A3LC_CalculationItemRepayment:
            return NSLocalizedString(@"Payment", nil);
        case A3LC_CalculationItemFrequency:
            return NSLocalizedString(@"Frequency", nil);

        default:
            return @"";
    }
}

+ (NSString *)titleOfFrequency:(A3LoanCalcFrequencyType)type
{
    switch (type) {
        case A3LC_FrequencyWeekly:
            return NSLocalizedString(@"Weekly", nil);
        case A3LC_FrequencyBiweekly:
            return NSLocalizedString(@"Biweekly", nil);
        case A3LC_FrequencyMonthly:
            return NSLocalizedString(@"LoanCalc_Monthly", nil);
        case A3LC_FrequencyBimonthly:
            return NSLocalizedString(@"Bimonthly", nil);
        case A3LC_FrequencyQuarterly:
            return NSLocalizedString(@"Quarterly", nil);
        case A3LC_FrequencySemiannualy:
            return NSLocalizedString(@"Semiannually", nil);
        case A3LC_FrequencyAnnually:
            return NSLocalizedString(@"Annually", nil);

        default:
            return @"";
    }
}

+ (NSString *)shortTitleOfFrequency:(A3LoanCalcFrequencyType)type
{
    switch (type) {
        case A3LC_FrequencyWeekly:
            return NSLocalizedString(@"Loan Calc Frequency short string weekly", @"wk");
        case A3LC_FrequencyBiweekly:
            return NSLocalizedString(@"Loan Calc Frequency short string biweekly", @"biwk");
        case A3LC_FrequencyMonthly:
            return NSLocalizedString(@"Loan Calc Frequency short string monthly", @"mo");
        case A3LC_FrequencyBimonthly:
            return NSLocalizedString(@"Loan Calc Frequency short string bi montly", @"bimo");
        case A3LC_FrequencyQuarterly:
            return NSLocalizedString(@"Loan Calc Frequency short string quarterly", @"qt");
        case A3LC_FrequencySemiannualy:
            return NSLocalizedString(@"Loan Calc Frequency short string semi annually", @"semian");
        case A3LC_FrequencyAnnually:
            return NSLocalizedString(@"Loan Calc Frequency short string annually", @"an");

        default:
            return @"";
    }
}

+ (NSString *)titleOfExtraPayment:(A3LoanCalcExtraPaymentType)type
{
    switch (type) {
        case A3LC_ExtraPaymentMonthly:
            return NSLocalizedString(@"Monthly", nil);
        case A3LC_ExtraPaymentYearly:
            return NSLocalizedString(@"Yearly", nil);
        case A3LC_ExtraPaymentOnetime:
            return NSLocalizedString(@"One-Time", nil);

        default:
            return @"";
    }
}

+ (NSString *)valueTextForCalcItem:(A3LoanCalcCalculationItem)calcItem fromData:(LoanCalcData *)loan formatter:(NSNumberFormatter *)currencyFormatter
{
    switch (calcItem) {
        case A3LC_CalculationItemDownPayment:
        {
            return [currencyFormatter stringFromNumber:loan.downPayment];
        }
        case A3LC_CalculationItemFrequency:
        {
            return [LoanCalcString titleOfFrequency:loan.frequencyIndex];
        }
        case A3LC_CalculationItemInterestRate:
        {
            return [loan interestRateString];
        }
        case A3LC_CalculationItemPrincipal:
        {
            return [currencyFormatter stringFromNumber:loan.principal];
        }
        case A3LC_CalculationItemRepayment:
        {
            return [NSString stringWithFormat:@"%@/%@", [currencyFormatter stringFromNumber:loan.repayment], [LoanCalcString shortTitleOfFrequency:loan.frequencyIndex]];
        }
        case A3LC_CalculationItemTerm:
        {
            return [loan termValueString];
        }
        default:
            return @"";
    }
}

@end
