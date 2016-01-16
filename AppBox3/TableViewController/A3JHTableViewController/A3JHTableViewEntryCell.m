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
		CGRect screenBounds = [A3UIDevice screenBoundsAdjustedWithOrientation];

		if (![self.textLabel.text length]) {
			CGRect frame;
			frame.origin.x = IS_IPHONE ? 15 : 28;
			frame.origin.y = 0;
			frame.size.width = screenBounds.size.width - (IS_IPHONE ? 30 : 28 + 15);
			frame.size.height = CGRectGetHeight(self.frame);
			self.textField.frame = frame;
			return;
		}

		CGFloat minWidth = screenBounds.size.width * 0.4;
        CGFloat textFieldWidth = minWidth;
		CGFloat textFieldTextWidth = 60.0;

		if ([self.textField.text length]) {
			NSStringDrawingContext *context = [NSStringDrawingContext new];
			CGRect textFieldBounds = [self.textField.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
																	   options:NSStringDrawingUsesLineFragmentOrigin
																	attributes:@{NSFontAttributeName:self.textField.font}
																	   context:context];
			textFieldTextWidth = textFieldBounds.size.width;
			if (textFieldBounds.size.width < minWidth) {
				textFieldWidth = minWidth;
			} else if (textFieldBounds.size.width > self.bounds.size.width / 2.0 - 30.0) {
				textFieldWidth = self.bounds.size.width / 2.0 - 30.0;
			} else {
				textFieldWidth = roundf(textFieldBounds.size.width);
			}
		}
		textFieldWidth += 10.0;
		CGRect textLabelFrame = self.textLabel.frame;
		textLabelFrame.origin.x = self.separatorInset.left;
		textLabelFrame.size.width = self.bounds.size.width - textFieldTextWidth - self.separatorInset.left;
		self.textLabel.frame = textLabelFrame;
        self.textField.frame = CGRectMake(self.bounds.size.width - textFieldWidth - 15.0, 0, textFieldWidth, CGRectGetHeight(self.frame));
		FNLOGRECT(textLabelFrame);
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];

	[self calculateTextFieldFrame];
}

@end
