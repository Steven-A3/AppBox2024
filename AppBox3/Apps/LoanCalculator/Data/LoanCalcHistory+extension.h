//
//  LoanCalcHistory+extension.h
//  AppBox3
//
//  Created by A3 on 7/17/14.
//  Copyright (c) 2014 ALLABOUTAPPS. All rights reserved.
//

#import "LoanCalcHistory.h"

@class LoanCalcData;

@interface LoanCalcHistory (extension)

+ (BOOL)sameDataExistForLoanCalcData:(LoanCalcData *)data type:(NSString *)type;

@end
