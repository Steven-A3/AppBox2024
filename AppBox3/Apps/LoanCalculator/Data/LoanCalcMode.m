//
//  LoanCalcMode.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 8..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "LoanCalcMode.h"
#import "LoanCalcPreference.h"

@implementation LoanCalcMode

+ (NSArray *) calculationModes
{
    return @[@(A3LC_CalculationForDownPayment),
             @(A3LC_CalculationForRepayment),
             @(A3LC_CalculationForPrincipal),
             @(A3LC_CalculationForTermOfYears),
             @(A3LC_CalculationForTermOfMonths)];
}

+ (NSArray *) frequencyTypes
{
    return @[@(A3LC_FrequencyWeekly),
             @(A3LC_FrequencyBiweekly),
             @(A3LC_FrequencyMonthly),
             @(A3LC_FrequencyBimonthly),
             @(A3LC_FrequencyQuarterly),
             @(A3LC_FrequencySemiannualy),
             @(A3LC_FrequencyAnnually)];
}

+ (NSArray *) extraPaymentTypes
{
    return @[@(A3LC_ExtraPaymentMonthly),
             @(A3LC_ExtraPaymentYearly),
             @(A3LC_ExtraPaymentOnetime)];
}

+ (NSArray *) compareCalculateItemsForDownPaymentEnabled:(BOOL)onoff
{
    if (onoff) {
        return @[
                 @(A3LC_CalculationItemPrincipal),
                 @(A3LC_CalculationItemDownPayment),
                 @(A3LC_CalculationItemTerm),
                 @(A3LC_CalculationItemInterestRate),
                 @(A3LC_CalculationItemFrequency)];
    }
    else {
        return @[
                 @(A3LC_CalculationItemPrincipal),
                 @(A3LC_CalculationItemTerm),
                 @(A3LC_CalculationItemInterestRate),
                 @(A3LC_CalculationItemFrequency)];
    }
}

+ (NSArray *) calculateItemForMode:(A3LoanCalcCalculationMode) mode withDownPaymentEnabled:(BOOL)enabled
{
    switch (mode) {
        case A3LC_CalculationForDownPayment:
        {
            return @[
                     @(A3LC_CalculationItemPrincipal),
                     @(A3LC_CalculationItemTerm),
                     @(A3LC_CalculationItemInterestRate),
                     @(A3LC_CalculationItemRepayment),
                     @(A3LC_CalculationItemFrequency)];
            break;
        }
        case A3LC_CalculationForRepayment:
        {
            if (enabled) {
                return @[
                         @(A3LC_CalculationItemPrincipal),
                         @(A3LC_CalculationItemDownPayment),
                         @(A3LC_CalculationItemTerm),
                         @(A3LC_CalculationItemInterestRate),
                         @(A3LC_CalculationItemFrequency)];
            }
            else {
                return @[
                         @(A3LC_CalculationItemPrincipal),
                         @(A3LC_CalculationItemTerm),
                         @(A3LC_CalculationItemInterestRate),
                         @(A3LC_CalculationItemFrequency)];
            }
            
            break;
        }
        case A3LC_CalculationForPrincipal:
        {
            if (enabled) {
                return @[
                         @(A3LC_CalculationItemDownPayment),
                         @(A3LC_CalculationItemTerm),
                         @(A3LC_CalculationItemInterestRate),
                         @(A3LC_CalculationItemRepayment),
                         @(A3LC_CalculationItemFrequency)];
            }
            else {
                return @[
                         @(A3LC_CalculationItemTerm),
                         @(A3LC_CalculationItemInterestRate),
                         @(A3LC_CalculationItemRepayment),
                         @(A3LC_CalculationItemFrequency)];
            }
            
            break;
        }
        case A3LC_CalculationForTermOfYears:
        {
            if (enabled) {
                return @[
                         @(A3LC_CalculationItemPrincipal),
                         @(A3LC_CalculationItemDownPayment),
                         @(A3LC_CalculationItemInterestRate),
                         @(A3LC_CalculationItemRepayment),
                         @(A3LC_CalculationItemFrequency)];
            }
            else {
                return @[
                         @(A3LC_CalculationItemPrincipal),
                         @(A3LC_CalculationItemInterestRate),
                         @(A3LC_CalculationItemRepayment),
                         @(A3LC_CalculationItemFrequency)];
            }
            
            break;
        }
        case A3LC_CalculationForTermOfMonths:
        {
            if (enabled) {
                return @[
                         @(A3LC_CalculationItemPrincipal),
                         @(A3LC_CalculationItemDownPayment),
                         @(A3LC_CalculationItemInterestRate),
                         @(A3LC_CalculationItemRepayment),
                         @(A3LC_CalculationItemFrequency)];
            }
            else {
                return @[
                         @(A3LC_CalculationItemPrincipal),
                         @(A3LC_CalculationItemInterestRate),
                         @(A3LC_CalculationItemRepayment),
                         @(A3LC_CalculationItemFrequency)];
            }
            
            break;
        }
            
        default:
            break;
    }
}

+ (A3LoanCalcCalculationItem)resltItemForCalcFor:(A3LoanCalcCalculationMode)calFor
{
    A3LoanCalcCalculationItem resultItem = A3LC_CalculationItemRepayment;
    switch (calFor) {
        case A3LC_CalculationForDownPayment:
            resultItem = A3LC_CalculationItemDownPayment;
            break;
        case A3LC_CalculationForPrincipal:
            resultItem = A3LC_CalculationItemPrincipal;
            break;
        case A3LC_CalculationForRepayment:
            resultItem = A3LC_CalculationItemRepayment;
            break;
        case A3LC_CalculationForTermOfMonths:
            resultItem = A3LC_CalculationItemTerm;
            break;
        case A3LC_CalculationForTermOfYears:
            resultItem = A3LC_CalculationItemTerm;
            break;
            
        default:
            break;
    }
    return resultItem;
}

@end
