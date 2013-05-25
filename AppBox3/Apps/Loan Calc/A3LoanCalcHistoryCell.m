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

@implementation A3LoanCalcHistoryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setObject:(LoanCalcHistory *)object {
	NSDateFormatter *df = [[NSDateFormatter alloc] init];
	[df setDateStyle:NSDateFormatterShortStyle];
	[df setTimeStyle:NSDateFormatterShortStyle];
	self.date.text = [df stringFromDate:object.created];

	self.notes.text = object.notes;

	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	[nf setNumberStyle:NSNumberFormatterCurrencyStyle];

	self.condition.text = object.conditionString;
	self.monthlyPayment.text = object.monthlyPayment;
}

@end
