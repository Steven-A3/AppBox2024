//
//  A3LoanCalcHistoryCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/25/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcHistoryCell.h"
#import "LoanCalcHistory.h"
#import "LoanCalcHistory+calculation.h"
#import "A3Formatter.h"

@implementation A3LoanCalcHistoryCell

- (void)setObject:(LoanCalcHistory *)object {
	self.date.text = [A3Formatter shortStyleDateTimeStringFromDate:object.created];

	self.notes.text = object.notes;

	self.condition.text = object.conditionString;
	self.monthlyPayment.text = object.monthlyPaymentString;
}

@end
