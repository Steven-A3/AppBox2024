//
//  A3ExpenseListTableViewCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/6/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3ExpenseListTableViewCell.h"
#import "SSCheckBoxView.h"
#import "A3UIDevice.h"
#import "NSNumberExtensions.h"

@implementation A3ExpenseListTableViewCell {
	UIColor *_textColor;
	UIFont *_font;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		self.selectionStyle = UITableViewCellSelectionStyleBlue;

		NSArray *locations, *widths;

		CGFloat y, labelHeight, margin;
		CGRect checkboxFrame;
		if (IS_IPAD) {
			y = 15.0, labelHeight = 28.0, margin = 12.0;
			locations = @[@54.0, @302.0, @412.0, @473.0];
			widths = @[@248.0, @110.0, @61.0, @153.0];
			checkboxFrame = CGRectMake(9.0, 11.0, 22.0, 22.0);
			_font = [UIFont systemFontOfSize:18.0];
		} else {
			y = 8.0, labelHeight = 28.0, margin = 3.0;
			locations = @[@42.0, @136.0, @214.0, @240.0];
			widths = @[@101.0, @75.0, @25.0, @79.0];
			checkboxFrame = CGRectMake(5.0, 5.0, 22.0, 22.0);
			_font = [UIFont systemFontOfSize:14.0];
		}
		_textColor = [UIColor colorWithRed:73.0/255.0 green:74.0/255.0 blue:73.0/255.0 alpha:1.0f];

        // Initialization code
		_checkBox = [[SSCheckBoxView alloc] initWithFrame:checkboxFrame style:kSSCheckBoxViewStyleGlossy checked:NO];
		[self addSubview:_checkBox];

		_item = [[UITextField alloc] initWithFrame:CGRectMake([locations[0] cgFloatValue] + margin, y,
				[widths[0] cgFloatValue] - margin * 2.0, labelHeight)];
		_item.textAlignment = NSTextAlignmentLeft;
		_item.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		_item.placeholder = @"Item...";
		_item.tag = A3ExpenseListTextFieldItem;
		[self applyAttributesToLabel:_item];

		_price = [[UITextField alloc] initWithFrame:CGRectMake([locations[1] cgFloatValue] + margin, y,
				[widths[1] cgFloatValue] - margin * 2.0, labelHeight)];
		_price.textAlignment = NSTextAlignmentRight;
		_price.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		_price.adjustsFontSizeToFitWidth = YES;
		_price.minimumFontSize = 6.0;
		_price.placeholder = @"$0.00";
		_price.tag = A3ExpenseListTextFieldPrice;
		[self applyAttributesToLabel:_price];

		_qty = [[UITextField alloc] initWithFrame:CGRectMake([locations[2] cgFloatValue], y, [widths[2] cgFloatValue], labelHeight)];
		_qty.textAlignment = NSTextAlignmentCenter;
		_qty.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		_qty.adjustsFontSizeToFitWidth = YES;
		_qty.minimumFontSize = 6.0;
		_qty.placeholder = @"0";
		_qty.tag = A3ExpenseListTextFieldQuantity;
		[self applyAttributesToLabel:_qty];

		_subtotal = [[UILabel alloc] initWithFrame:CGRectMake([locations[3] cgFloatValue] + margin, y, [widths[3] cgFloatValue] - margin * 2.0, labelHeight)];
		_subtotal.textAlignment = NSTextAlignmentRight;
		[self applyAttributesToLabel:_subtotal];

		[self addSubview:_item];
		[self addSubview:_price];
		[self addSubview:_qty];
		[self addSubview:_subtotal];
	}
    return self;
}

- (void)applyAttributesToLabel:(id)object {
	[object setValue:[UIColor clearColor] forKey:@"backgroundColor"];
	[object setValue:_textColor forKey:@"textColor"];
	[object setValue:_font forKey:@"font"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
