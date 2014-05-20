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
        CGFloat x = self.leftSeparatorInset;
        
		NSStringDrawingContext *context = [NSStringDrawingContext new];
		CGRect textLabelBounds = [self.textLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                                attributes:@{NSFontAttributeName:self.textLabel.font}
                                                                   context:context];
        if (textLabelBounds.size.width != 0) {          // KJH
            x += ceil(textLabelBounds.size.width) + 10; // + self.leftSeparatorInset;
        }
        
        //self.textField.frame = CGRectMake(x, 10, CGRectGetWidth(self.frame) - x - 15, CGRectGetHeight(self.frame) - 20);
        self.textField.frame = CGRectMake(x, 0, CGRectGetWidth(self.frame) - x - 15, CGRectGetHeight(self.frame));
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];

	[self calculateTextFieldFrame];
}

@end
