//
//  A3CurrencyHistoryCell
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/10/13 8:48 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3CurrencyHistory3RowCell.h"
#import "A3CurrencyHistoryCell.h"


@implementation A3CurrencyHistoryCell {

}

- (UILabel *)addUILabelWithColor:(UIColor *)color {
	UILabel *label = [[UILabel alloc] init];
	label.textColor = color;
	label.translatesAutoresizingMaskIntoConstraints = NO;
	[self.contentView addSubview:label];
	return label;
}

- (void)addConstraintLeft:(UILabel *)left right:(UILabel *)right centerY:(CGFloat)centerY {
	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:left
													 attribute:NSLayoutAttributeLeft
													 relatedBy:NSLayoutRelationEqual
														toItem:self.contentView
													 attribute:NSLayoutAttributeLeft
													multiplier:1.0
													  constant:15.0]];
	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:left
													 attribute:NSLayoutAttributeCenterY
													 relatedBy:NSLayoutRelationEqual
														toItem:self.contentView
													 attribute:NSLayoutAttributeCenterY
													multiplier:centerY
													  constant:0.0]];
	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:right
													 attribute:NSLayoutAttributeRight
													 relatedBy:NSLayoutRelationEqual
														toItem:self.contentView
													 attribute:NSLayoutAttributeRight
													multiplier:1.0
													  constant:-15.0]];
	[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:right
													 attribute:NSLayoutAttributeCenterY
													 relatedBy:NSLayoutRelationEqual
														toItem:left
													 attribute:NSLayoutAttributeCenterY
													multiplier:1.0
													  constant:0.0]];
}
@end