//
//  LoanCalcString.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 8..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoanCalcMode.h"

//extern NSString *const A3LC_ModeTitle_DownPayment;
//extern NSString *const A3LC_ModeTitle_Repayment;
//extern NSString *const A3LC_ModeTitle_Principal;
//extern NSString *const A3LC_ModeTitle_TermOfYears;
//extern NSString *const A3LC_ModeTitle_TermOfMonths;
//
//extern NSString *const A3LC_ItemTitle_Principal;
//extern NSString *const A3LC_ItemTitle_DownPayment;
//extern NSString *const A3LC_ItemTitle_Term;
//extern NSString *const A3LC_ItemTitle_InterestRate;
//extern NSString *const A3LC_ItemTitle_Repayment;
//extern NSString *const A3LC_ItemTitle_Frequency;
//
//extern NSString *const A3LC_FrequencyTitle_Weekly;
//extern NSString *const A3LC_FrequencyTitle_Biweekly;
//extern NSString *const A3LC_FrequencyTitle_Monthly;
//extern NSString *const A3LC_FrequencyTitle_Bimonthly;
//extern NSString *const A3LC_FrequencyTitle_Quarterly;
//extern NSString *const A3LC_FrequencyTitle_SemiAnnually;
//extern NSString *const A3LC_FrequencyTitle_Annually;
//
//extern NSString *const A3LC_ExtraPaymentTitle_Monthly;
//extern NSString *const A3LC_ExtraPaymentTitle_Yearly;
//extern NSString *const A3LC_ExtraPaymentTitle_Onetime;

@class LoanCalcData;

@interface LoanCalcString : NSObject

+ (NSString *)titleOfCalFor:(A3LoanCalcCalculationMode)mode;
+ (NSString *)titleOfItem:(A3LoanCalcCalculationItem)item;
+ (NSString *)titleOfFrequency:(A3LoanCalcFrequencyType)type;
+ (NSString *)titleOfExtraPayment:(A3LoanCalcExtraPaymentType)type;
+ (NSString *)shortTitleOfFrequency:(A3LoanCalcFrequencyType)type;
+ (NSString *)shortUnitTitleOfFrequency:(A3LoanCalcFrequencyType)type;
+ (NSString *)valueTextForCalcItem:(A3LoanCalcCalculationItem)calcItem fromData:(LoanCalcData *)loan formatter:(NSNumberFormatter *)currencyFormatter;

@end
