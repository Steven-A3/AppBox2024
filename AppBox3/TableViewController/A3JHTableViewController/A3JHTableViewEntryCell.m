//
//  A3JHTableViewEntryCell.m
//  AppBox3
//
//  Created by A3 on 10/31/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3JHTableViewEntryCell.h"
#import "A3UIDevice.h"

@interface A3JHTableViewEntryCell () <UITextFieldDelegate>
@end

@implementation A3JHTableViewEntryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		// Initialization code
		_textField = [UITextField new];
		_textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		_textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		_textField.textAlignment = NSTextAlignmentRight;
		[self.contentView addSubview:_textField];
	}
    return self;
}

- (void)calculateTextFieldFrame {

	if (self.textLabel.font) {
        CGFloat width = 60.0;

		if ([self.textField.text length]) {
			NSStringDrawingContext *context = [NSStringDrawingContext new];
			CGRect textFieldBounds = [self.textField.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
																	   options:NSStringDrawingUsesLineFragmentOrigin
																	attributes:@{NSFontAttributeName:self.textLabel.font}
																	   context:context];
			if (textFieldBounds.size.width < 60.0) {
				width = 60.0;
			} else if (textFieldBounds.size.width > self.bounds.size.width / 2.0 - 30.0) {
				width = self.bounds.size.width / 2.0 - 30.0;
			} else {
				width = ceilf(textFieldBounds.size.width);
			}
		}
		CGRect textLabelFrame = self.textLabel.frame;
		textLabelFrame.size.width = self.bounds.size.width - width - 30.0;
		self.textLabel.frame = textLabelFrame;
        self.textField.frame = CGRectMake(self.bounds.size.width - width - 15.0, 0, width, CGRectGetHeight(self.frame));
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];

	[self calculateTextFieldFrame];
}

@end
