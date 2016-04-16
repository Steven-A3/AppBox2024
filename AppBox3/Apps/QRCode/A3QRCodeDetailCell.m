//
//  A3QRCodeDetailCell.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/10/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3QRCodeDetailCell.h"

@implementation A3QRCodeDetailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		// Initialization code
		[self setupLayout];
	}
	return self;
}

- (void)setupLayout
{
	CGFloat leading = IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28;
	
	[self.valueTextField makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(self.left).with.offset(leading);
		make.centerY.equalTo(self.centerY);
		make.right.equalTo(self.right).with.offset(-(leading + 10));
		make.height.equalTo(@50);
	}];

	self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (JVFloatLabeledTextField *)valueTextField {
	if (!_valueTextField) {
		_valueTextField = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectZero];
		_valueTextField.floatingLabelTextColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
		_valueTextField.floatingLabelFont = [UIFont systemFontOfSize:14];
		[self.contentView addSubview:_valueTextField];
	}
	return _valueTextField;
}

@end
