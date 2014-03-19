//
//  LoanCalcData+Calculation.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "LoanCalcData+Calculation.h"
#import "common.h"
#import "NSString+conversion.h"

@implementation LoanCalcData (Calculation)

- (double)interestRateOfFrequency
{
    if (self.annualInterestRate) {
        double divider;
        switch (self.frequencyIndex) {
            case A3LC_FrequencyWeekly:
                divider = 7.0/365.0;
                break;
            case A3LC_FrequencyBiweekly:
                divider = 14.0/365.0;
                break;
            case A3LC_FrequencyMonthly:
                divider = 1.0/12.0;
                break;
            case A3LC_FrequencyBimonthly:
                divider = 2.0/12.0;
                break;
            case A3LC_FrequencyQuarterly:
                divider = 0.25;
                break;
            case A3LC_FrequencySemiannualy:
                divider = 0.5;
                break;
            case A3LC_FrequencyAnnually:
                divider = 1;
                break;
                
            default:
                divider = 1.0/12.0;
                break;
        }
        
        return self.annualInterestRate.doubleValue * divider;
    }
    else {
        return 0;
    }
}

- (double)termsInFrequency
{
    if (self.monthOfTerms) {
        
        switch (self.frequencyIndex) {
            case A3LC_FrequencyWeekly:
            {
                double days = 365*self.monthOfTerms.doubleValue/12.0;
                return days/7.0;
                break;
            }
            case A3LC_FrequencyBiweekly:
            {
                double days = 365*self.monthOfTerms.doubleValue/12.0;
                return days/14.0;
                break;
            }
            case A3LC_FrequencyMonthly:
            {
                return self.monthOfTerms.doubleValue;
                break;
            }
            case A3LC_FrequencyBimonthly:
            {
                return self.monthOfTerms.doubleValue/2.0;
                break;
            }
            case A3LC_FrequencyQuarterly:
            {
                return self.monthOfTerms.doubleValue/3.0;
                break;
            }
            case A3LC_FrequencySemiannualy:
            {
                return self.monthOfTerms.doubleValue/6.0;
                break;
            }
            case A3LC_FrequencyAnnually:
            {
                return self.monthOfTerms.floatValue/12.0;
                break;
            }
            default:
                return self.monthOfTerms.floatValue;
                break;
        }
    }
    else {
        return 0;
    }
}

- (float)termsInMonth:(float) terms
{
    switch (self.frequencyIndex) {
        case A3LC_FrequencyWeekly:
        {
            return (terms/(365.0/7.0)) * 12;
            break;
        }
        case A3LC_FrequencyBiweekly:
        {
            return (terms/(365.0/14.0)) * 12;
            break;
        }
        case A3LC_FrequencyMonthly:
        {
            return terms;
            break;
        }
        case A3LC_FrequencyBimonthly:
        {
            return terms*2;
            break;
        }
        case A3LC_FrequencyQuarterly:
        {
            return terms*3;
            break;
        }
        case A3LC_FrequencySemiannualy:
        {
            return terms*6;
            break;
        }
        case A3LC_FrequencyAnnually:
        {
            return terms*12;
            break;
        }
        default:
            return 0;
            break;
    }
}

- (void)calculateRepayment {
    
    if (![self pricipalValid] || ![self termsValid] || ![self interestValid]) {
        return;
    }
    
	double repayment;
	double principal, downPayment = 0.0;
	double interestRateOfFrequency = [self interestRateOfFrequency];
	double termsInFrequency = [self termsInFrequency];
    
	principal = self.principal.doubleValue;
    downPayment = self.downPayment ? self.downPayment.floatValue : 0;
    
	repayment = (interestRateOfFrequency / (1 - pow(1 + interestRateOfFrequency, -termsInFrequency))) * (principal - downPayment);
    
	FNLOG("principal = %f\nmonthlyPayment = %f\nmonthlyInterestRate = %f\nterminMonth = %f\ndownPayment = %f", principal, repayment, interestRateOfFrequency, termsInFrequency, downPayment);
    
	self.repayment = @(repayment);
}

- (void)calculatePrincipal {
    
    if (![self repaymentValid] || ![self termsValid] || ![self interestValid]) {
        return;
    }
    
	double principal;
	double repayment;
	double downPayment = 0.0;
	double interestRateOfFrequency = [self interestRateOfFrequency];
	double termsInFrequency = [self termsInFrequency];
    
	repayment = self.repayment.doubleValue;
    
	principal = (repayment*pow(interestRateOfFrequency+1,termsInFrequency)-repayment)/(interestRateOfFrequency*pow(interestRateOfFrequency+1,termsInFrequency));
    
    downPayment = self.downPayment ? self.downPayment.doubleValue : 0;
    principal += downPayment;
    
	FNLOG("principal = %f\nmonthlyPayment = %f\nmonthlyInterestRate = %f\nterminMonth = %f\ndownPayment = %f", principal, repayment, interestRateOfFrequency, termsInFrequency, downPayment);
    
	self.principal = @(principal);
}

- (void)calculateDownPayment {
    
    if (![self pricipalValid] || ![self repaymentValid] || ![self termsValid] || ![self interestValid]) {
        return;
    }
    
	double downPayment;
	double principal = self.principal.floatValue;
	double repayment = self.repayment.floatValue;
	double interestRateOfFrequency = [self interestRateOfFrequency];
	double termsInFrequency = [self termsInFrequency];
    
	double calculatedPrincipal = (repayment*pow(interestRateOfFrequency+1,termsInFrequency)-repayment)/(interestRateOfFrequency*pow(interestRateOfFrequency+1,termsInFrequency));
	downPayment = principal - calculatedPrincipal;
    
	FNLOG("principal = %f\nmonthlyPayment = %f\nmonthlyInterestRate = %f\nterminMonth = %f\ndownPayment = %f", principal, repayment, interestRateOfFrequency, termsInFrequency, downPayment);
    
	self.downPayment = @(downPayment);
}

- (void)calculateTermInMonth
{
    if (![self pricipalValid] || ![self repaymentValid] || ![self interestValid]) {
        return;
    }
    
    double principal = self.principal.doubleValue;
    double downPayment = self.downPayment ? self.downPayment.floatValue : 0;
	double repayment = self.repayment.doubleValue;
	double interestRateOfFrequency = [self interestRateOfFrequency];
    
	float calculatedPrincipal = principal - downPayment;
	float term = logf(repayment/(repayment-calculatedPrincipal*interestRateOfFrequency))/log(interestRateOfFrequency+1);
    
	FNLOG("principal = %f\nmonthlyPayment = %f\nmonthlyInterestRate = %f\nterm = %f\ndownPayment = %f", principal, repayment, interestRateOfFrequency, term, downPayment);
    
    self.monthOfTerms = @([self termsInMonth:term]);
}

#pragma mark - Total info
- (NSNumber *)totalAmount {
	float totalAmount = self.repayment.floatValue * [self termsInFrequency];
	return [NSNumber numberWithFloat:totalAmount];
}

- (NSNumber *)totalInterest {
    float downPayment = self.downPayment ? self.downPayment.floatValue : 0;
	float totalInterest = self.repayment.floatValue * [self termsInFrequency] - (self.principal.floatValue - downPayment);
	return [NSNumber numberWithFloat:totalInterest];
}

- (NSNumber *)monthlyAverageInterest {
    float totalInterest = [self totalInterest].floatValue;
    float termsInFrequency = [self termsInFrequency];
	float average = totalInterest/termsInFrequency;
	return [NSNumber numberWithFloat:average];
}

#pragma mark - Schedule info
- (NSDate *)dateOfPaymentIndex:(NSUInteger)index
{
    NSDate *dateOfPayment;
    switch (self.frequencyIndex) {
        case A3LC_FrequencyWeekly:
        {
            NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
            [dateComponents setDay:7*(index+1)];
            NSCalendar* calendar = [NSCalendar currentCalendar];
            dateOfPayment = [calendar dateByAddingComponents:dateComponents toDate:self.startDate options:0];
        }
            break;
        case A3LC_FrequencyBiweekly:
        {
            NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
            [dateComponents setDay:14*(index+1)];
            NSCalendar* calendar = [NSCalendar currentCalendar];
            dateOfPayment = [calendar dateByAddingComponents:dateComponents toDate:self.startDate options:0];
        }
            break;
        case A3LC_FrequencyMonthly:
        {
            NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
            [dateComponents setMonth:1*(index+1)];
            NSCalendar* calendar = [NSCalendar currentCalendar];
            dateOfPayment = [calendar dateByAddingComponents:dateComponents toDate:self.startDate options:0];
        }
            break;
        case A3LC_FrequencyBimonthly:
        {
            NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
            [dateComponents setMonth:2*(index+1)];
            NSCalendar* calendar = [NSCalendar currentCalendar];
            dateOfPayment = [calendar dateByAddingComponents:dateComponents toDate:self.startDate options:0];
        }
            break;
        case A3LC_FrequencyQuarterly:
        {
            NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
            [dateComponents setMonth:3*(index+1)];
            NSCalendar* calendar = [NSCalendar currentCalendar];
            dateOfPayment = [calendar dateByAddingComponents:dateComponents toDate:self.startDate options:0];
        }
            break;
        case A3LC_FrequencySemiannualy:
        {
            NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
            [dateComponents setMonth:6*(index+1)];
            NSCalendar* calendar = [NSCalendar currentCalendar];
            dateOfPayment = [calendar dateByAddingComponents:dateComponents toDate:self.startDate options:0];
        }
            break;
        case A3LC_FrequencyAnnually:
        {
            NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
            [dateComponents setYear:1*(index+1)];
            NSCalendar* calendar = [NSCalendar currentCalendar];
            dateOfPayment = [calendar dateByAddingComponents:dateComponents toDate:self.startDate options:0];
        }
            break;
            
        default:
            dateOfPayment = self.startDate;
            break;
    }
    
    return dateOfPayment;
}

- (NSNumber *)paymentOfPaymentIndex:(NSUInteger)index
{
    double fixedRepayment = self.repayment.doubleValue;
    double addedExtraPayments = 0;
    
    /* add extraPayment */
    NSDate *prePaymentDate = (index == 0) ? nil : [self dateOfPaymentIndex:index-1];
    NSDate *thisPaymentDate = [self dateOfPaymentIndex:index];
    
    // monthly extra payment
    if (self.extraPaymentMonthly && (self.extraPaymentMonthly.doubleValue>0)) {
        if (prePaymentDate == nil) {
            addedExtraPayments += self.extraPaymentMonthly.doubleValue;
        }
        else {
            NSCalendar *cal = [NSCalendar currentCalendar];

            NSDateComponents *preComponents = [cal components:NSCalendarUnitMonth fromDate:prePaymentDate];
            NSDateComponents *thisComponents = [cal components:NSCalendarUnitMonth fromDate:thisPaymentDate];
            NSInteger preMonth = [preComponents month];
            NSInteger thisMonth = [thisComponents month];
            if (preMonth != thisMonth) {
                addedExtraPayments += self.extraPaymentMonthly.floatValue;
            }
        }
    }
    
    // yearly extra payment
    if (self.extraPaymentYearly && (self.extraPaymentYearly.doubleValue>0) && self.extraPaymentYearlyDate) {
        /*
        if (prePaymentDate == nil) {
            addedExtraPayments += self.extraPaymentYearly.doubleValue;
        }
        else {
            NSCalendar *cal = [NSCalendar currentCalendar];
            NSDateComponents *preComponents = [cal components:NSCalendarUnitMonth fromDate:prePaymentDate];
            NSDateComponents *thisComponents = [cal components:NSCalendarUnitMonth fromDate:thisPaymentDate];
            NSDateComponents *extraPayComponents = [cal components:NSCalendarUnitMonth fromDate:self.extraPaymentYearlyDate];
            NSInteger preMonth = [preComponents month];
            NSInteger thisMonth = [thisComponents month];
            NSInteger extraPayMonth = [extraPayComponents month];
            
            if ((extraPayMonth == thisMonth) && (thisMonth != preMonth)) {
                addedExtraPayments += self.extraPaymentYearly.floatValue;
            }
        }
         */
        
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *preComponents = [cal components:NSCalendarUnitMonth fromDate:prePaymentDate];
        NSDateComponents *thisComponents = [cal components:NSCalendarUnitMonth fromDate:thisPaymentDate];
        NSDateComponents *extraPayComponents = [cal components:NSCalendarUnitMonth fromDate:self.extraPaymentYearlyDate];
        NSInteger preMonth = [preComponents month];
        NSInteger thisMonth = [thisComponents month];
        NSInteger extraPayMonth = [extraPayComponents month];
        
        if ((extraPayMonth == thisMonth) && (thisMonth != preMonth)) {
            addedExtraPayments += self.extraPaymentYearly.floatValue;
        }
        
    }
    
    // onetime payment
    if (self.extraPaymentOneTime && (self.extraPaymentOneTime.floatValue>0) && self.extraPaymentOneTimeDate) {
        if (prePaymentDate == nil) {
            if (([thisPaymentDate compare:self.extraPaymentOneTimeDate] == NSOrderedDescending) || ([thisPaymentDate compare:self.extraPaymentOneTimeDate] == NSOrderedSame)) {
                addedExtraPayments += self.extraPaymentOneTime.floatValue;
            }
        }
        else {
            if ([prePaymentDate compare:self.extraPaymentOneTimeDate] == NSOrderedAscending) {
                if (([thisPaymentDate compare:self.extraPaymentOneTimeDate] == NSOrderedDescending) || ([thisPaymentDate compare:self.extraPaymentOneTimeDate] == NSOrderedSame)) {
                    addedExtraPayments += self.extraPaymentOneTime.floatValue;
                }
            }
        }
    }
    
    return @(fixedRepayment+addedExtraPayments);
}

#pragma mark - Manage
- (BOOL)calculated
{
    if ([self repaymentValid] && [self pricipalValid] && [self interestValid] && [self termsValid]) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)repaymentValid
{
    if (self.repayment && (self.repayment.floatValue>0)) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)pricipalValid
{
    if (self.principal && (self.principal.floatValue>0)) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)interestValid
{
    if (self.annualInterestRate && (self.annualInterestRate.floatValue>=0)) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)termsValid
{
    if (self.monthOfTerms && (self.monthOfTerms.floatValue>0)) {
        return YES;
    }
    else {
        return NO;
    }
}

//- (NSString *)filePahtOfCsvStringForMonthlyDataArray:(NSArray *)dataArray {
- (NSString *)filePathOfCsvStringForMonthlyDataWithFileName:(NSString *)fileName {
    NSString *csvString;
    NSMutableArray *csvArray = [NSMutableArray new];
    NSDateFormatter *df = [NSDateFormatter new];
    df.dateStyle = NSDateFormatterShortStyle;
    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    
    NSArray *paymentDataList = [self paymentList];
    
    [csvArray addObject:[NSString stringWithFormat:@"Date, Principal, Payment, Interest, Balance"]];
    [paymentDataList enumerateObjectsUsingBlock:^(NSDictionary *data, NSUInteger idx, BOOL *stop) {
        NSString *date;
        NSString *principal;
        NSString *payment;
        NSString *interest;
        NSString *balance;
        
        if ((self.frequencyIndex == A3LC_FrequencyBiweekly) || (self.frequencyIndex == A3LC_FrequencyWeekly)) {
            date = [df stringFromDate:data[@"Date"]];
        }
        else {
            [df setDateFormat:@"MMM yyyy"];
            date = [df stringFromDate:data[@"Date"]];
        }
        
        if (IS_IPHONE) {
            interest = [[numberFormatter stringFromNumber:data[@"Interest"]] stringByReplacingOccurrencesOfString:[numberFormatter currencySymbol] withString:@""];
            payment = [[numberFormatter stringFromNumber:data[@"Payment"]] stringByReplacingOccurrencesOfString:[numberFormatter currencySymbol] withString:@""];
            principal = [[numberFormatter stringFromNumber:data[@"Principal"]] stringByReplacingOccurrencesOfString:[numberFormatter currencySymbol] withString:@""];
            balance = [[numberFormatter stringFromNumber:data[@"Balance"]] stringByReplacingOccurrencesOfString:[numberFormatter currencySymbol] withString:@""];
        }
        else {
            interest = [numberFormatter stringFromNumber:data[@"Interest"]];
            payment = [numberFormatter stringFromNumber:data[@"Payment"]];
            principal = [numberFormatter stringFromNumber:data[@"Principal"]];
            balance = [numberFormatter stringFromNumber:data[@"Balance"]];
        }
        
        [csvArray addObject:[NSString stringWithFormat:@"\"%@\", \"%@\", \"%@\", \"%@\", \"%@\"", date, principal, payment, interest, balance]];
    }];
    
    
    csvString = [csvArray componentsJoinedByString:@"\n"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    BOOL result = [fileManager createFileAtPath:filePath contents:[csvString dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    
    return result ? filePath : nil;
}

- (NSArray *)paymentList
{
    NSMutableArray * paymentList = [NSMutableArray new];
    paymentList = [[NSMutableArray alloc] init];
    
    // date, payment, principal, interest, balance
    
    double downPayment = self.downPayment ? self.downPayment.doubleValue : 0;
    double balance = (self.principal.doubleValue - downPayment);
    NSUInteger paymentIndex = 0;    // start from 0
    
    do {
        NSDate *payDate = [self dateOfPaymentIndex:paymentIndex];
        NSNumber *interest = @(balance * [self interestRateOfFrequency]);
        
        double paymentTmp = [self paymentOfPaymentIndex:paymentIndex].doubleValue;
        if ((paymentTmp-interest.floatValue) > balance) {
            paymentTmp = balance + interest.floatValue;
        }
        NSNumber *payment = @(paymentTmp);
        NSNumber *principal = @(payment.doubleValue - interest.doubleValue);
        balance -= principal.doubleValue;
        
        // 간혹 마지막 차에서 소수점이 남는 문제를 보정하기 위해 0.5미만은 0으로 바꾼다.
        if (balance < 0.5) {
            balance = 0;
        }
        NSNumber *balanceNum = @(balance);
        
        [paymentList addObject:@{
                                 @"Date": payDate,
                                 @"Payment": payment,
                                 @"Principal": principal,
                                 @"Interest": interest,
                                 @"Balance": balanceNum
                                 }];
        paymentIndex++;
        
    } while (balance > 0);
    
    return paymentList;
}


@end
