//
//  LoanCalcString.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 8..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoanCalcMode.h"

// calculation for
#define A3LC_ModeTitle_DownPayment  @"Down Payment";
#define A3LC_ModeTitle_Repayment    @"Payment";
#define A3LC_ModeTitle_Principal    @"Principal";
#define A3LC_ModeTitle_TermOfYears  @"Term(years)";
#define A3LC_ModeTitle_TermOfMonths @"Term(months)";

// calculation item
#define A3LC_ItemTitle_Principal        @"Principal";
#define A3LC_ItemTitle_DownPayment      @"Down Payment";
#define A3LC_ItemTitle_Term             @"Term";
#define A3LC_ItemTitle_InterestRate     @"Interest Rate";
#define A3LC_ItemTitle_Repayment        @"Payment";
#define A3LC_ItemTitle_Frequency        @"Frequency";

// frequency type
#define A3LC_FrequencyTitle_Weekly      @"Weekly";
#define A3LC_FrequencyTitle_Biweekly    @"Biweekly";
#define A3LC_FrequencyTitle_Monthly     @"Monthly";
#define A3LC_FrequencyTitle_Bimonthly   @"Bimonthly";
#define A3LC_FrequencyTitle_Quaterly    @"Quarterly";
#define A3LC_FrequencyTitle_Semiannualy @"Semiannually";
#define A3LC_FrequencyTitle_Annualy     @"Annually";

// extraPayment type
#define A3LC_ExtraPaymentTitle_Monthly  @"Monthly";
#define A3LC_ExtraPaymentTitle_Yearly   @"Yearly";
#define A3LC_ExtraPaymentTitle_Onetime  @"One-Time";

@interface LoanCalcString : NSObject

+ (NSString *)titleOfCalFor:(A3LoanCalcCalculationMode)mode;
+ (NSString *)titleOfItem:(A3LoanCalcCalculationItem)item;
+ (NSString *)titleOfFrequency:(A3LoanCalcFrequencyType)type;
+ (NSString *)titleOfExtraPayment:(A3LoanCalcExtraPaymentType)type;
+ (NSString *)shortTitleOfFrequency:(A3LoanCalcFrequencyType)type;

@end
