//
//  LoanCalcData+Calculation.m
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "LoanCalcData+Calculation.h"
#import "NSDateFormatter+A3Addition.h"
#import "A3AppDelegate.h"

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
                return round(days/7.0);
            }
            case A3LC_FrequencyBiweekly:
            {
                double days = 365*self.monthOfTerms.doubleValue/12.0;
                return round(days/14.0);
            }
            case A3LC_FrequencyMonthly:
            {
                return self.monthOfTerms.doubleValue;
            }
            case A3LC_FrequencyBimonthly:
            {
                return round(self.monthOfTerms.doubleValue/2.0);
            }
            case A3LC_FrequencyQuarterly:
            {
                return round(self.monthOfTerms.doubleValue/3.0);
            }
            case A3LC_FrequencySemiannualy:
            {
                return round(self.monthOfTerms.doubleValue/6.0);
            }
            case A3LC_FrequencyAnnually:
            {
                return round(self.monthOfTerms.doubleValue/12.0);
            }
            default:
                return round(self.monthOfTerms.doubleValue);
        }
    }
    else {
        return 0;
    }
}

- (double)termsInMonth:(double) terms
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
    
    if (![self principalValid] || ![self termsValid]) {
        return;
    }
    
	double repayment;
	double principal, downPayment = 0.0;
	double interestRateOfFrequency = [self interestRateOfFrequency];
	double termsInFrequency = [self termsInFrequency];
    
	principal = self.principal.doubleValue;
    downPayment = self.downPayment ? self.downPayment.doubleValue : 0;

	if (interestRateOfFrequency > 0) {
		repayment = (interestRateOfFrequency / (1 - pow(1 + interestRateOfFrequency, -termsInFrequency))) * (principal - downPayment);
		repayment = round(repayment * 100) / 100;
		if (isnan(repayment)) {
			repayment = 0;
		}
	} else {
		repayment = principal / termsInFrequency;
	}

	FNLOG("principal = %f\nmonthlyPayment = %f\nmonthlyInterestRate = %f\nterminMonth = %f\ndownPayment = %f", principal, repayment, interestRateOfFrequency, termsInFrequency, downPayment);
    
	self.repayment = @(repayment);
}

- (void)calculatePrincipal {
    
    if (![self repaymentValid] || ![self termsValid]) {
        return;
    }
    
	double principal;
	double repayment;
	double downPayment = 0.0;
	double interestRateOfFrequency = [self interestRateOfFrequency];
	double termsInFrequency = [self termsInFrequency];
    
	repayment = self.repayment.doubleValue;

	if (interestRateOfFrequency > 0) {
		principal = (repayment*pow(interestRateOfFrequency+1,termsInFrequency)-repayment)/(interestRateOfFrequency*pow(interestRateOfFrequency+1,termsInFrequency));
	} else {
		principal = repayment * termsInFrequency;
	}

    downPayment = self.downPayment ? self.downPayment.doubleValue : 0;
    principal += downPayment;
    
	FNLOG("principal = %f\nmonthlyPayment = %f\nmonthlyInterestRate = %f\nterminMonth = %f\ndownPayment = %f", principal, repayment, interestRateOfFrequency, termsInFrequency, downPayment);
    
	self.principal = @(principal);
}

- (void)calculateDownPayment {
    
    if (![self principalValid] || ![self repaymentValid] || ![self termsValid]) {
        return;
    }
    
	double downPayment;
	double principal = self.principal.doubleValue;
	double repayment = self.repayment.doubleValue;
	double interestRateOfFrequency = [self interestRateOfFrequency];
	double termsInFrequency = [self termsInFrequency];

	double calculatedPrincipal;
	if (interestRateOfFrequency > 0) {
		calculatedPrincipal = (repayment*pow(interestRateOfFrequency+1,termsInFrequency)-repayment)/(interestRateOfFrequency*pow(interestRateOfFrequency+1,termsInFrequency));
	} else {
		calculatedPrincipal = repayment * termsInFrequency;
	}
	downPayment = round(principal - calculatedPrincipal);
    
	FNLOG("principal = %f\nmonthlyPayment = %f\nmonthlyInterestRate = %f\nterminMonth = %f\ndownPayment = %f", principal, repayment, interestRateOfFrequency, termsInFrequency, downPayment);
    
	self.downPayment = @(downPayment);
}

- (void)calculateTermInMonth
{
    if (![self principalValid] || ![self repaymentValid]) {
        return;
    }
    
    double principal = self.principal.doubleValue;
    double downPayment = self.downPayment ? self.downPayment.doubleValue : 0;
	double repayment = self.repayment.doubleValue;
	double interestRateOfFrequency = [self interestRateOfFrequency];
    
	double calculatedPrincipal = principal - downPayment;
	double term;
	if (interestRateOfFrequency > 0) {
		term = log(repayment / (repayment - calculatedPrincipal * interestRateOfFrequency)) / log(interestRateOfFrequency + 1);
	} else {
		term = calculatedPrincipal / repayment;
	}

	FNLOG("principal = %f\nmonthlyPayment = %f\nmonthlyInterestRate = %f\nterm = %f\ndownPayment = %f", principal, repayment, interestRateOfFrequency, term, downPayment);  
    self.monthOfTerms = @([self termsInMonth:term]);
}

#pragma mark - Total info

- (NSNumber *)totalAmount {
	double totalAmount;
	double balance = [self.principal doubleValue];

	NSInteger maxTurn = (NSInteger) round([self termsInFrequency]);
	FNLOG(@"maxTurn = %ld", (long)maxTurn);

	NSCalendar *calendar = [[A3AppDelegate instance] calendar];
	NSDate *startDate = self.startDate ? self.startDate : [NSDate date];
	NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:startDate];
	NSInteger startYear = components.year;
	NSInteger startMonth = components.month;

	components = [calendar components:NSMonthCalendarUnit fromDate:self.extraPaymentYearlyDate ? self.extraPaymentYearlyDate : [NSDate date]];
	NSInteger extraPaymentYearlyMonth = components.month;

	components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:self.extraPaymentOneTimeDate ? self.extraPaymentOneTimeDate : [NSDate date]];
	NSInteger extraPaymentOneTimeYear = components.year;
	NSInteger extraPaymentOneTimeMonth = components.month;

	double repayment = self.repayment.doubleValue;;
	totalAmount = 0;
	double interestRate = [self interestRateOfFrequency];
	FNLOG(@"interestRate = %@", @(interestRate));

	for (NSInteger turn = 0; turn < maxTurn; turn++) {
		if (self.extraPaymentMonthly) {
			repayment += self.extraPaymentMonthly.doubleValue;
		}
		NSInteger currentMonth = (startMonth + turn) % 12;
		currentMonth = currentMonth == 0 ? 12 : currentMonth;

		if (self.extraPaymentYearly && extraPaymentYearlyMonth == currentMonth) {
			repayment += self.extraPaymentYearly.doubleValue;
		}
		if ((extraPaymentOneTimeYear == (startYear + ceil((startMonth + turn - 1) / 12)) ) && (extraPaymentOneTimeMonth ==  currentMonth)) {
			repayment += self.extraPaymentOneTime.doubleValue;
		}

		if ((balance - repayment) < 0) {
			totalAmount += balance;
			break;
		} else {
			balance -= repayment - (balance * interestRate);
			totalAmount += repayment;
		}
	}

	FNLOG(@"totalAmount = %@", @(totalAmount));
	return @(totalAmount);
}

- (NSNumber *)totalInterest {
	if (self.interestRateOfFrequency == 0.0) {
		return @0;
	}
    double downPayment = self.downPayment ? self.downPayment.doubleValue : 0;
	if (isnan(downPayment))
		downPayment = 0.0;
	double totalInterest = [self totalAmount].doubleValue - (self.principal.doubleValue + downPayment);
	return @(totalInterest);
}

- (NSNumber *)monthlyAverageInterest {
	if (self.interestRateOfFrequency == 0.0) {
		return @0;
	}
    double totalInterest = [self totalInterest].doubleValue;
    double termsInFrequency = [self termsInFrequency];
	double average = totalInterest/termsInFrequency;
	return @(average);
}

#pragma mark - Schedule info
- (NSDate *)dateOfPaymentIndex:(NSUInteger)index
{
	NSCalendar *calendar = [[A3AppDelegate instance] calendar];
    NSDate *dateOfPayment;
    switch (self.frequencyIndex) {
        case A3LC_FrequencyWeekly:
        {
            NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
            [dateComponents setDay:7*(index+1)];
            dateOfPayment = [calendar dateByAddingComponents:dateComponents toDate:self.startDate options:0];
        }
            break;
        case A3LC_FrequencyBiweekly:
        {
            NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
            [dateComponents setDay:14*(index+1)];
            dateOfPayment = [calendar dateByAddingComponents:dateComponents toDate:self.startDate options:0];
        }
            break;
        case A3LC_FrequencyMonthly:
        {
            NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
            [dateComponents setMonth:1*(index+1)];
            dateOfPayment = [calendar dateByAddingComponents:dateComponents toDate:self.startDate options:0];
        }
            break;
        case A3LC_FrequencyBimonthly:
        {
            NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
            [dateComponents setMonth:2*(index+1)];
            dateOfPayment = [calendar dateByAddingComponents:dateComponents toDate:self.startDate options:0];
        }
            break;
        case A3LC_FrequencyQuarterly:
        {
            NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
            [dateComponents setMonth:3*(index+1)];
            dateOfPayment = [calendar dateByAddingComponents:dateComponents toDate:self.startDate options:0];
        }
            break;
        case A3LC_FrequencySemiannualy:
        {
            NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
            [dateComponents setMonth:6*(index+1)];
            dateOfPayment = [calendar dateByAddingComponents:dateComponents toDate:self.startDate options:0];
        }
            break;
        case A3LC_FrequencyAnnually:
        {
            NSDateComponents* dateComponents = [[NSDateComponents alloc]init];
            [dateComponents setYear:1*(index+1)];
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
            NSCalendar *cal = [[A3AppDelegate instance] calendar];

            NSDateComponents *preComponents = [cal components:NSCalendarUnitMonth fromDate:prePaymentDate];
            NSDateComponents *thisComponents = [cal components:NSCalendarUnitMonth fromDate:thisPaymentDate];
            NSInteger preMonth = [preComponents month];
            NSInteger thisMonth = [thisComponents month];
            if (preMonth != thisMonth) {
                addedExtraPayments += self.extraPaymentMonthly.doubleValue;
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
            NSCalendar *cal = [[A3AppDelegate instance] calendar];
            NSDateComponents *preComponents = [cal components:NSCalendarUnitMonth fromDate:prePaymentDate];
            NSDateComponents *thisComponents = [cal components:NSCalendarUnitMonth fromDate:thisPaymentDate];
            NSDateComponents *extraPayComponents = [cal components:NSCalendarUnitMonth fromDate:self.extraPaymentYearlyDate];
            NSInteger preMonth = [preComponents month];
            NSInteger thisMonth = [thisComponents month];
            NSInteger extraPayMonth = [extraPayComponents month];
            
            if ((extraPayMonth == thisMonth) && (thisMonth != preMonth)) {
                addedExtraPayments += self.extraPaymentYearly.doubleValue;
            }
        }
         */
        
        NSCalendar *cal = [[A3AppDelegate instance] calendar];
        NSDateComponents *preComponents = [cal components:NSCalendarUnitMonth fromDate:prePaymentDate];
        NSDateComponents *thisComponents = [cal components:NSCalendarUnitMonth fromDate:thisPaymentDate];
        NSDateComponents *extraPayComponents = [cal components:NSCalendarUnitMonth fromDate:self.extraPaymentYearlyDate];
        NSInteger preMonth = [preComponents month];
        NSInteger thisMonth = [thisComponents month];
        NSInteger extraPayMonth = [extraPayComponents month];
        
        if ((extraPayMonth == thisMonth) && (thisMonth != preMonth)) {
            addedExtraPayments += self.extraPaymentYearly.doubleValue;
        }
        
    }
    
    // onetime payment
    if (self.extraPaymentOneTime && (self.extraPaymentOneTime.doubleValue>0) && self.extraPaymentOneTimeDate) {
        if (prePaymentDate == nil) {
            if (([thisPaymentDate compare:self.extraPaymentOneTimeDate] == NSOrderedDescending) || ([thisPaymentDate compare:self.extraPaymentOneTimeDate] == NSOrderedSame)) {
                addedExtraPayments += self.extraPaymentOneTime.doubleValue;
            }
        }
        else {
            if ([prePaymentDate compare:self.extraPaymentOneTimeDate] == NSOrderedAscending) {
                if (([thisPaymentDate compare:self.extraPaymentOneTimeDate] == NSOrderedDescending) || ([thisPaymentDate compare:self.extraPaymentOneTimeDate] == NSOrderedSame)) {
                    addedExtraPayments += self.extraPaymentOneTime.doubleValue;
                }
            }
        }
    }
    
    return @(fixedRepayment+addedExtraPayments);
}

#pragma mark - Manage
- (BOOL)calculated
{
    if ([self.totalAmount isEqualToNumber:[NSDecimalNumber notANumber]]) {
        return NO;
    }
    
    if ([self repaymentValid] && [self principalValid] && [self termsValid]) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)repaymentValid
{
    if (self.repayment && (self.repayment.doubleValue>0)) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)principalValid
{
    if (self.principal && (self.principal.doubleValue>0)) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)termsValid
{
    if (self.monthOfTerms && (self.monthOfTerms.doubleValue>0)) {
        return YES;
    }
    else {
        return NO;
    }
}

#pragma mark - CSV Attachment File Export
- (NSString *)filePathOfCsvStringForMonthlyDataWithFileName:(NSString *)fileName {
    NSMutableArray *csvArray = [NSMutableArray new];
    NSDateFormatter *df = [NSDateFormatter new];
//    df.dateStyle = NSDateFormatterLongStyle;
//    df.dateFormat = [df formatStringByRemovingDayComponent:[df dateFormat]];
    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    
    NSArray *paymentDataList = [self paymentList];

	[csvArray addObject:NSLocalizedString(@"Date, Principal, Payment, Interest, Balance", @"Date, Principal, Payment, Interest, Balance")];
    [paymentDataList enumerateObjectsUsingBlock:^(NSDictionary *data, NSUInteger idx, BOOL *stop) {
        NSString *date;
        NSString *principal;
        NSString *payment;
        NSString *interest;
        NSString *balance;
        
        date = [df localizedMediumStyleYearMonthFromDate:data[@"Date"]];

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
        
        [csvArray addObject:[NSString stringWithFormat:@"%@, %@, %@, %@, %@",
                             [self stringOfCSVFormatFromString:date],
                             [self stringOfCSVFormatFromString:principal],
                             [self stringOfCSVFormatFromString:payment],
                             [self stringOfCSVFormatFromString:interest],
                             [self stringOfCSVFormatFromString:balance]]];
    }];
    
    NSString *csvString = [csvArray componentsJoinedByString:@"\n"];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    BOOL result = [fileManager createFileAtPath:filePath contents:[csvString dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    
    return result ? filePath : nil;
}

- (NSString *)stringOfCSVFormatFromString:(NSString *)string
{
    NSRange range = [string rangeOfString:@"," options:NSCaseInsensitiveSearch];
    if (range.location != NSNotFound) {
        string = [NSString stringWithFormat:@"\"%@\"", string];
    }
    
    return string;
}

- (NSArray *)paymentList
{
    NSMutableArray * paymentList;
    paymentList = [[NSMutableArray alloc] init];
    
    // date, payment, principal, interest, balance
    double downPayment = self.downPayment ? self.downPayment.doubleValue : 0;
    double balance = (self.principal.doubleValue - downPayment);
    NSUInteger paymentIndex = 0;    // start from 0
    
    do {
        NSDate *payDate = [self dateOfPaymentIndex:paymentIndex];
        NSNumber *interest = @(balance * [self interestRateOfFrequency]);
        
        double paymentTmp = [self paymentOfPaymentIndex:paymentIndex].doubleValue;
        if ((paymentTmp-interest.doubleValue) > balance) {
            paymentTmp = balance + interest.doubleValue;
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
