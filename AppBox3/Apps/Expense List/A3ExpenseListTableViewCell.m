//
//  A3ExpenseListTableViewCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/6/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3ExpenseListTableViewCell.h"
#import "SSCheckBoxView.h"

@implementation A3ExpenseListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;

		CGFloat y = 15.0, labelHeight = 28.0, margin = 20.0;
        // Initialization code
		_checkBox = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(9.0, 11.0, 22.0, 22.0) style:kSSCheckBoxViewStyleGlossy checked:NO];
		[self.contentView addSubview:_checkBox];

		_item = [[UILabel alloc] initWithFrame:CGRectMake(54.0 + margin, y, 248.0 - margin * 2.0, labelHeight)];
		_item.textAlignment = NSTextAlignmentLeft;
		[self applyAttributesToLabel:_item];

		_price = [[UILabel alloc] initWithFrame:CGRectMake(302.0 + margin, y, 110.0 - margin * 2.0, labelHeight)];
		_price.textAlignment = NSTextAlignmentRight;
		[self applyAttributesToLabel:_price];

		_qty = [[UILabel alloc] initWithFrame:CGRectMake(412.0 + margin, y, 61.0 - margin * 2.0, labelHeight)];
		_qty.textAlignment = NSTextAlignmentCenter;
		[self applyAttributesToLabel:_qty];

		_subtotal = [[UILabel alloc] initWithFrame:CGRectMake(473.0 + margin, y, 153.0 - margin * 2.0, labelHeight)];
		_subtotal.textAlignment = NSTextAlignmentRight;
		[self applyAttributesToLabel:_subtotal];

		[self.contentView addSubview:_item];
		[self.contentView addSubview:_price];
		[self.contentView addSubview:_qty];
		[self.contentView addSubview:_subtotal];
	}
    return self;
}

- (void)applyAttributesToLabel:(UILabel *)label {
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor colorWithRed:73.0/255.0 green:74.0/255.0 blue:73.0/255.0 alpha:1.0f];
	label.font = [UIFont systemFontOfSize:18.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
