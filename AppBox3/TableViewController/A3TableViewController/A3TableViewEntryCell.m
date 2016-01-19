//
//  A3TableViewEntryCell.m
//  AppBox3
//
//  Created by A3 on 10/31/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TableViewEntryCell.h"
#import "A3UIDevice.h"

@interface A3TableViewEntryCell () <UITextFieldDelegate>
@end

@implementation A3TableViewEntryCell

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
		CGFloat leading = IS_IPHONE ? ([[UIScreen mainScreen] scale] > 2 ? 20 : 15) : 28;
		CGFloat x = leading;
		NSStringDrawingContext *context = [NSStringDrawingContext new];
		CGRect textLabelBounds = [self.textLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.textLabel.font} context:context];
		x += ceil(textLabelBounds.size.width) + 10;
		self.textField.frame = CGRectMake(x, 10, CGRectGetWidth(self.frame) - x - leading, CGRectGetHeight(self.frame) - 20);
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];

	[self calculateTextFieldFrame];
}

@end
