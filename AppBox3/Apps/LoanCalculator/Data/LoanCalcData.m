//
//  LoanCalcData.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 7..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "LoanCalcData.h"

NSString *const A3LoanCalcCurrencyCodeChanged = @"A3LoanCalcCurrencyCodeChanged";

@implementation LoanCalcData

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        _principal = [aDecoder decodeObjectForKey:@"principal"];
        _downPayment = [aDecoder decodeObjectForKey:@"downPayment"];
        _repayment = [aDecoder decodeObjectForKey:@"repayment"];
        _monthOfTerms = [aDecoder decodeObjectForKey:@"monthOfTerms"];
		_showsTermInMonths  = [aDecoder decodeObjectForKey:@"showsTermInMonths"];
        _annualInterestRate = [aDecoder decodeObjectForKey:@"annualInterestRate"];
		_showsInterestInYearly = [aDecoder decodeObjectForKey:@"showsInterestInYearly"];
		_frequencyIndex = (A3LoanCalcFrequencyType) [aDecoder decodeIntegerForKey:@"frequencyIndex"];
        _calculationDate = [aDecoder decodeObjectForKey:@"calculationDate"];
        
        // advanced
        _startDate = [aDecoder decodeObjectForKey:@"startDate"];
        _note = [aDecoder decodeObjectForKey:@"note"];
        
        // extra payment
        _extraPaymentMonthly = [aDecoder decodeObjectForKey:@"extraPaymentMonthly"];
        _extraPaymentYearly = [aDecoder decodeObjectForKey:@"extraPaymentYearly"];
        _extraPaymentYearlyDate = [aDecoder decodeObjectForKey:@"extraPaymentYearlyDate"];
        _extraPaymentOneTime = [aDecoder decodeObjectForKey:@"extraPaymentOneTime"];
        _extraPaymentOneTimeDate = [aDecoder decodeObjectForKey:@"extraPaymentOneTimeDate"];
        
        // setting
        _calculationMode = (A3LoanCalcCalculationMode) [aDecoder decodeIntegerForKey:@"calculationMode"];
        _showAdvanced = [aDecoder decodeBoolForKey:@"showAdvanced"];
        _showDownPayment = [aDecoder decodeBoolForKey:@"showDownPayment"];
        _showExtraPayment = [aDecoder decodeBoolForKey:@"showExtraPayment"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_principal forKey:@"principal"];
    [aCoder encodeObject:_downPayment forKey:@"downPayment"];
    [aCoder encodeObject:_repayment forKey:@"repayment"];
    [aCoder encodeObject:_monthOfTerms forKey:@"monthOfTerms"];
	[aCoder encodeObject:_showsTermInMonths forKey:@"showsTermInMonths"];
    [aCoder encodeObject:_annualInterestRate forKey:@"annualInterestRate"];
	[aCoder encodeObject:_showsInterestInYearly forKey:@"showsInterestInYearly"];
    [aCoder encodeInteger:_frequencyIndex forKey:@"frequencyIndex"];
    [aCoder encodeObject:_calculationDate forKey:@"calculationDate"];
    // advanced
    [aCoder encodeObject:_startDate forKey:@"startDate"];
    [aCoder encodeObject:_note forKey:@"note"];
    // extra payment
    [aCoder encodeObject:_extraPaymentMonthly forKey:@"extraPaymentMonthly"];
    [aCoder encodeObject:_extraPaymentYearly forKey:@"extraPaymentYearly"];
    [aCoder encodeObject:_extraPaymentYearlyDate forKey:@"extraPaymentYearlyDate"];
    [aCoder encodeObject:_extraPaymentOneTime forKey:@"extraPaymentOneTime"];
    [aCoder encodeObject:_extraPaymentOneTimeDate forKey:@"extraPaymentOneTimeDate"];
    // setting
    [aCoder encodeInteger:_calculationMode forKey:@"calculationMode"];
    [aCoder encodeBool:_showAdvanced forKey:@"showAdvanced"];
    [aCoder encodeBool:_showDownPayment forKey:@"showDownPayment"];
    [aCoder encodeBool:_showExtraPayment forKey:@"showExtraPayment"];
}

- (NSString *)termValueString {
	NSString *resultString;
	if ([self.showsTermInMonths boolValue]) {
		resultString = [NSString localizedStringWithFormat:NSLocalizedStringFromTable(@"%ld months", @"StringsDict", @"Loan Calculation terms in months"), (long)[self.monthOfTerms integerValue] ];
	} else {
		resultString = [NSString localizedStringWithFormat:NSLocalizedStringFromTable(@"%ld years", @"StringsDict", @"Loan Calculation terms in years"), (long)[self.monthOfTerms integerValue] / 12 ];
	}
	return resultString;
}

- (NSString *)interestRateString {
	NSString *resultString;
	NSNumberFormatter *formatter = [NSNumberFormatter new];
	[formatter setNumberStyle:NSNumberFormatterPercentStyle];
	[formatter setMaximumFractionDigits:3];
	if ([self.showsInterestInYearly boolValue]) {
		resultString = [NSString stringWithFormat:NSLocalizedString(@"Annual %@", @"Annual %@"), [formatter stringFromNumber:_annualInterestRate ? _annualInterestRate : @0]];
	} else {
		resultString = [NSString stringWithFormat:NSLocalizedString(@"Monthly %@", @"Monthly %@"), [formatter stringFromNumber:@([_annualInterestRate doubleValue] / 12.0)]];
	}
	return resultString;
}

@end
