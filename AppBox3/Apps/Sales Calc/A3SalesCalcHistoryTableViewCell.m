//
//  A3SalesCalcHistoryTableViewCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 1/30/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3SalesCalcHistoryTableViewCell.h"
#import "A3CalcExpressionView.h"

@implementation A3SalesCalcHistoryTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		// Initialization code
		[self addSubview:self.dateLabel];
		[self addSubview:self.expressionView];
		[self addSubview:self.salePriceLabel];
		[self addSubview:self.notesLabel];
    }
    return self;
}

- (UILabel *)dateLabel {
	if (nil == _dateLabel) {
		_dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(6.0, 10.0, 300.0, 12.0)];
		_dateLabel.font = [UIFont systemFontOfSize:10.0];
		_dateLabel.textColor = [UIColor grayColor];
		_dateLabel.backgroundColor = [UIColor clearColor];
	}
	return _dateLabel;
}

- (A3CalcExpressionView *)expressionView {
	if (nil == _expressionView) {
		_expressionView = [[A3CalcExpressionView alloc] initWithFrame:CGRectMake(0.0, 23.0, 200.0, 20.0)];
		_expressionView.style = CEV_TRANSPARENT_BACKGROUND;
	}
	return _expressionView;
}

- (UILabel *)salePriceLabel {
	if (nil == _salePriceLabel) {
		_salePriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(160.0, 22.0, 154.0, 25.0)];
		_salePriceLabel.backgroundColor = [UIColor clearColor];
		_salePriceLabel.font = [UIFont boldSystemFontOfSize:23.0];
		_salePriceLabel.textColor = [UIColor colorWithRed:224.0/255.0 green:60.0/255.0 blue:28.0/255.0 alpha:1.0];
		_salePriceLabel.textAlignment = NSTextAlignmentRight;
	}
	return _salePriceLabel;
}

- (UILabel *)notesLabel {
	if (nil == _notesLabel) {
		_notesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 50.0, 314.0, 14.0)];
		_notesLabel.backgroundColor = [UIColor clearColor];
		_notesLabel.textColor = [UIColor grayColor];
		_notesLabel.font = [UIFont systemFontOfSize:12.0];
		_notesLabel.textAlignment = NSTextAlignmentRight;
	}
	return _notesLabel;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
