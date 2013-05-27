//
//  A3LoanCalcCompareHistoryCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 5/25/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcCompareHistoryCell.h"
#import "LoanCalcHistory.h"
#import "A3Formatter.h"
#import "LoanCalcHistory+calculation.h"
#import "A3ComparisonView.h"
#import "NSString+conversion.h"
#import "common.h"

@interface A3LoanCalcCompareHistoryCell ()

@property (nonatomic, weak) IBOutlet UILabel *date;
@property (nonatomic, weak) IBOutlet UILabel *leftAmount;
@property (nonatomic, weak) IBOutlet UILabel *leftCondition;
@property (nonatomic, weak) IBOutlet UILabel *leftMonthlyPayment;
@property (nonatomic, weak) IBOutlet UILabel *rightAmount;
@property (nonatomic, weak) IBOutlet UILabel *rightCondition;
@property (nonatomic, weak) IBOutlet UILabel *rightMonthlyPayment;
@property (nonatomic, weak) IBOutlet A3ComparisonView *comparisonView;


@end

@implementation A3LoanCalcCompareHistoryCell

- (void)awakeFromNib {
	[super awakeFromNib];

	[self addSubview:self.comparisonView];
	[self addSubview:self.leftMonthlyPayment];
	[self addSubview:self.rightMonthlyPayment];
	[self addSubview:self.rightAmount];
	[self addSubview:self.rightCondition];
	[self addSubview:self.date];
}


- (void)setObject:(LoanCalcHistory *)object {
	self.date.text = [A3Formatter shortStyleDateTimeStringFromDate:object.created];
	self.leftAmount.text = object.principal;
	self.leftCondition.text = object.interestTermString;
	self.leftMonthlyPayment.text = object.monthlyPaymentString;

	LoanCalcHistory *rightObject = object.compareWith;
	self.rightAmount.text = rightObject.principal;
	self.rightCondition.text = rightObject.interestTermString;
	self.rightMonthlyPayment.text = rightObject.monthlyPaymentString;

	self.comparisonView.leftValue = @([object.monthlyPayment floatValueEx]);
	self.comparisonView.rightValue = @([rightObject.monthlyPayment floatValueEx]);

	FNLOG(@"%f, %f", self.frame.size.width, self.frame.size.height);
}

@end
