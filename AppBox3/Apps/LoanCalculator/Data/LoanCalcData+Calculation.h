//
//  LoanCalcData+Calculation.h
//  A3TeamWork
//
//  Created by kihyunkim on 2013. 12. 11..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "LoanCalcData.h"

@interface LoanCalcData (Calculation)

- (double)interestRateOfFrequency;

- (void)calculateRepayment;
- (void)calculatePrincipal;
- (void)calculateDownPayment;
- (void)calculateTermInMonth;

// total info
- (NSNumber *)totalAmount;
- (NSNumber *)totalInterest;
- (NSNumber *)monthlyAverageInterest;

// payment schedule
- (NSDate *)dateOfPaymentIndex:(NSUInteger)index;
- (NSNumber *)paymentOfPaymentIndex:(NSUInteger)index;

- (BOOL)calculated;

#pragma mark - CSV Attachment File Export
- (NSString *)filePathOfCsvStringForMonthlyDataWithFileName:(NSString *)fileName;
@end
