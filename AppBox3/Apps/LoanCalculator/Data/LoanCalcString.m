//
//  LoanCalcString.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 8..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "LoanCalcString.h"
#import "LoanCalcData.h"

NSString *const A3LC_ModeTitle_DownPayment  = @"Down Payment";
NSString *const A3LC_ModeTitle_Repayment    = @"Payment";
NSString *const A3LC_ModeTitle_Principal    = @"Principal";
NSString *const A3LC_ModeTitle_TermOfYears  = @"Term(years)";
NSString *const A3LC_ModeTitle_TermOfMonths = @"Term(months)";

NSString *const A3LC_ItemTitle_Principal        = @"Principal";
NSString *const A3LC_ItemTitle_DownPayment      = @"Down Payment";
NSString *const A3LC_ItemTitle_Term             = @"Term";
NSString *const A3LC_ItemTitle_InterestRate     = @"Interest Rate";
NSString *const A3LC_ItemTitle_Repayment        = @"Payment";
NSString *const A3LC_ItemTitle_Frequency        = @"Frequency";

NSString *const A3LC_FrequencyTitle_Weekly      = @"Weekly";
NSString *const A3LC_FrequencyTitle_Biweekly    = @"Biweekly";
NSString *const A3LC_FrequencyTitle_Monthly     = @"Monthly";
NSString *const A3LC_FrequencyTitle_Bimonthly   = @"Bimonthly";
NSString *const A3LC_FrequencyTitle_Quarterly = @"Quarterly";
NSString *const A3LC_FrequencyTitle_SemiAnnually = @"Semiannually";
NSString *const A3LC_FrequencyTitle_Annually = @"Annually";

NSString *const A3LC_ExtraPaymentTitle_Monthly  = @"Monthly";
NSString *const A3LC_ExtraPaymentTitle_Yearly   = @"Yearly";
NSString *const A3LC_ExtraPaymentTitle_Onetime  = @"One-Time";

@implementation LoanCalcString

+ (NSString *)titleOfCalFor:(A3LoanCalcCalculationMode)mode
{
    switch (mode) {
        case A3LC_CalculationForDownPayment:
            return NSLocalizedString(A3LC_ModeTitle_DownPayment, nil);
        case A3LC_CalculationForRepayment:
            return NSLocalizedString(A3LC_ModeTitle_Repayment, nil);
        case A3LC_CalculationForPrincipal:
            return NSLocalizedString(A3LC_ModeTitle_Principal, nil);
        case A3LC_CalculationForTermOfMonths:
            return NSLocalizedString(A3LC_ModeTitle_TermOfMonths, nil);
        case A3LC_CalculationForTermOfYears:
            return NSLocalizedString(A3LC_ModeTitle_TermOfYears, nil);

        default:
            return @"";
    }
}

+ (NSString *)titleOfItem:(A3LoanCalcCalculationItem)item
{
    switch (item) {
        case A3LC_CalculationItemPrincipal:
            return NSLocalizedString(A3LC_ItemTitle_Principal, nil);
        case A3LC_CalculationItemDownPayment:
            return NSLocalizedString(A3LC_ItemTitle_DownPayment, nil);
        case A3LC_CalculationItemTerm:
            return NSLocalizedString(A3LC_ItemTitle_Term, nil);
        case A3LC_CalculationItemInterestRate:
            return NSLocalizedString(A3LC_ItemTitle_InterestRate, nil);
        case A3LC_CalculationItemRepayment:
            return NSLocalizedString(A3LC_ItemTitle_Repayment, nil);
        case A3LC_CalculationItemFrequency:
            return NSLocalizedString(A3LC_ItemTitle_Frequency, nil);

        default:
            return @"";
    }
}

+ (NSString *)titleOfFrequency:(A3LoanCalcFrequencyType)type
{
    switch (type) {
        case A3LC_FrequencyWeekly:
            return NSLocalizedString(A3LC_FrequencyTitle_Weekly, nil);
        case A3LC_FrequencyBiweekly:
            return NSLocalizedString(A3LC_FrequencyTitle_Biweekly, nil);
        case A3LC_FrequencyMonthly:
            return NSLocalizedString(A3LC_FrequencyTitle_Monthly, nil);
        case A3LC_FrequencyBimonthly:
            return NSLocalizedString(A3LC_FrequencyTitle_Bimonthly, nil);
        case A3LC_FrequencyQuarterly:
            return NSLocalizedString(A3LC_FrequencyTitle_Quarterly, nil);
        case A3LC_FrequencySemiannualy:
            return NSLocalizedString(A3LC_FrequencyTitle_SemiAnnually, nil);
        case A3LC_FrequencyAnnually:
            return NSLocalizedString(A3LC_FrequencyTitle_Annually, nil);

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
            return NSLocalizedString(A3LC_ExtraPaymentTitle_Monthly, nil);
        case A3LC_ExtraPaymentYearly:
            return NSLocalizedString(A3LC_ExtraPaymentTitle_Yearly, nil);
        case A3LC_ExtraPaymentOnetime:
            return NSLocalizedString(A3LC_ExtraPaymentTitle_Onetime, nil);

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
