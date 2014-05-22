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
            return A3LC_ModeTitle_DownPayment;
            break;
        case A3LC_CalculationForRepayment:
            return A3LC_ModeTitle_Repayment;
            break;
        case A3LC_CalculationForPrincipal:
            return A3LC_ModeTitle_Principal;
            break;
        case A3LC_CalculationForTermOfMonths:
            return A3LC_ModeTitle_TermOfMonths;
            break;
        case A3LC_CalculationForTermOfYears:
            return A3LC_ModeTitle_TermOfYears;
            break;
            
        default:
            return @"";
            break;
    }
}

+ (NSString *)titleOfItem:(A3LoanCalcCalculationItem)item
{
    switch (item) {
        case A3LC_CalculationItemPrincipal:
            return A3LC_ItemTitle_Principal;
            break;
        case A3LC_CalculationItemDownPayment:
            return A3LC_ItemTitle_DownPayment;
            break;
        case A3LC_CalculationItemTerm:
            return A3LC_ItemTitle_Term;
            break;
        case A3LC_CalculationItemInterestRate:
            return A3LC_ItemTitle_InterestRate;
            break;
        case A3LC_CalculationItemRepayment:
            return A3LC_ItemTitle_Repayment;
            break;
        case A3LC_CalculationItemFrequency:
            return A3LC_ItemTitle_Frequency;
            break;
            
        default:
            return @"";
            break;
    }
}

+ (NSString *)titleOfFrequency:(A3LoanCalcFrequencyType)type
{
    switch (type) {
        case A3LC_FrequencyWeekly:
            return A3LC_FrequencyTitle_Weekly;
            break;
        case A3LC_FrequencyBiweekly:
            return A3LC_FrequencyTitle_Biweekly;
            break;
        case A3LC_FrequencyMonthly:
            return A3LC_FrequencyTitle_Monthly;
            break;
        case A3LC_FrequencyBimonthly:
            return A3LC_FrequencyTitle_Bimonthly;
            break;
        case A3LC_FrequencyQuarterly:
            return A3LC_FrequencyTitle_Quaterly;
            break;
        case A3LC_FrequencySemiannualy:
            return A3LC_FrequencyTitle_Semiannualy;
            break;
        case A3LC_FrequencyAnnually:
            return A3LC_FrequencyTitle_Annualy;
            break;
            
        default:
            return @"";
            break;
    }
}

+ (NSString *)shortTitleOfFrequency:(A3LoanCalcFrequencyType)type
{
    switch (type) {
        case A3LC_FrequencyWeekly:
            return @"wk";
            break;
        case A3LC_FrequencyBiweekly:
            return @"biwk";
            break;
        case A3LC_FrequencyMonthly:
            return @"mo";
            break;
        case A3LC_FrequencyBimonthly:
            return @"bimo";
            break;
        case A3LC_FrequencyQuarterly:
            return @"qt";
            break;
        case A3LC_FrequencySemiannualy:
            return @"semian";
            break;
        case A3LC_FrequencyAnnually:
            return @"an";
            break;
            
        default:
            return @"";
            break;
    }
}

+ (NSString *)titleOfExtraPayment:(A3LoanCalcExtraPaymentType)type
{
    switch (type) {
        case A3LC_ExtraPaymentMonthly:
            return A3LC_ExtraPaymentTitle_Monthly;
            break;
        case A3LC_ExtraPaymentYearly:
            return A3LC_ExtraPaymentTitle_Yearly;
            break;
        case A3LC_ExtraPaymentOnetime:
            return A3LC_ExtraPaymentTitle_Onetime;
            break;
            
        default:
            return @"";
            break;
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
