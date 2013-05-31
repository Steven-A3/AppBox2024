//
//  A3ExpenseListHistoryTableViewCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 05/20/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3ExpenseListHistoryTableViewCell.h"
#import "A3CalcExpressionView.h"
#import "Expense.h"
#import "NSString+conversion.h"

@interface A3ExpenseListHistoryTableViewCell ()
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) A3CalcExpressionView *expressionView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *leftValueLabel;
@end

@implementation A3ExpenseListHistoryTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.backgroundColor = [UIColor colorWithRed:240.0 / 255.0 green:240.0 / 255.0 blue:242.0 / 255.0 alpha:1.0];
		[self addSubview:self.dateLabel];
		[self addSubview:self.expressionView];
		[self addSubview:self.leftValueLabel];
		[self addSubview:self.leftLabel];
		[self addSubview:self.titleLabel];
	}

	return self;
}

- (UILabel *)dateLabel {
	if (nil == _dateLabel) {
		_dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(6.0, 5.0, 220.0, 20.0)];
		_dateLabel.font = [UIFont systemFontOfSize:12.0];
		_dateLabel.textColor = [UIColor colorWithRed:115.0 / 255.0 green:115.0 / 255.0 blue:115.0 / 255.0 alpha:1.0];
		_dateLabel.backgroundColor = [UIColor clearColor];
	}
	return _dateLabel;
}

- (A3CalcExpressionView *)expressionView {
	if (nil == _expressionView) {
		_expressionView = [[A3CalcExpressionView alloc] initWithFrame:CGRectMake(6.0, 23.0, 200.0, 26.0)];
		_expressionView.style = CEV_TRANSPARENT_BACKGROUND;
	}
	return _expressionView;
}

- (UILabel *)titleLabel {
	if (nil == _titleLabel) {
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(6.0, 48.0, 300.0, 14.0)];
		_titleLabel.font = [UIFont systemFontOfSize:12.0];
		_titleLabel.textColor = [UIColor colorWithRed:115.0 / 255.0 green:115.0 / 255.0 blue:115.0 / 255.0 alpha:1.0];
		_titleLabel.backgroundColor = [UIColor clearColor];
	}
	return _titleLabel;
}

- (UILabel *)leftLabel {
	if (nil == _leftLabel) {
		_leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(320.0 - 6.0 - 80.0, 10.0, 80.0, 16.0)];
		_leftLabel.font = [UIFont boldSystemFontOfSize:14.0];
		_leftLabel.textAlignment = NSTextAlignmentRight;
		_leftLabel.textColor = [UIColor colorWithRed:115.0 / 255.0 green:115.0 / 255.0 blue:115.0 / 255.0 alpha:1.0];
		_leftLabel.backgroundColor = [UIColor clearColor];
	}
	return _leftLabel;
}

- (UILabel *)leftValueLabel {
	if (nil == _leftValueLabel) {
		_leftValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(320.0 - 6.0 - 108.0, 23.0, 108.0, 25.0)];
		_leftValueLabel.font = [UIFont boldSystemFontOfSize:20.0];
		_leftValueLabel.textAlignment = NSTextAlignmentRight;
		_leftValueLabel.backgroundColor = [UIColor clearColor];
	}
	return _leftValueLabel;
}

- (void)setExpenseObject:(Expense *)expenseObject {
	_expenseObject = expenseObject;

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];

	self.dateLabel.text = [dateFormatter stringFromDate:expenseObject.date];
	self.titleLabel.text = expenseObject.title;

	NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
	[nf setNumberStyle:NSNumberFormatterCurrencyStyle];
	self.leftValueLabel.text = [nf stringFromNumber:expenseObject.left];
	if ([expenseObject.left floatValue] >= 0.0) {
		self.leftValueLabel.textColor = [UIColor colorWithRed:42.0 / 255.0 green:125.0 / 255.0 blue:0.0 alpha:1.0];
		self.leftLabel.text = @"Left";
	} else {
		self.leftValueLabel.textColor = [UIColor redColor];
		self.leftLabel.text = @"Over";
	}

	self.expressionView.expression = @[[nf stringFromNumber:expenseObject.total], @"of", [nf stringFromNumber:@([expenseObject.budget floatValue]) ] ];
	NSDictionary *redText = @{A3ExpressionAttributeFont:[UIFont boldSystemFontOfSize:20.0], A3ExpressionAttributeTextColor:[UIColor redColor]};
	NSDictionary *blackText = @{A3ExpressionAttributeFont:[UIFont boldSystemFontOfSize:20.0], A3ExpressionAttributeTextColor:[UIColor blackColor]};
	NSDictionary *operatorText = @{A3ExpressionAttributeFont:[UIFont boldSystemFontOfSize:18.0]};
	self.expressionView.attributes = @[redText, operatorText, blackText];
	[self.expressionView setNeedsDisplay];
}

@end
