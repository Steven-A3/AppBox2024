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
- (void)addConstraintLeft:(UILabel *)left right:(UILabel *)right centerY:(CGFloat)centerY hMargin:(CGFloat)hMargin {
	[self addConstraint:[NSLayoutConstraint constraintWithItem:left
													 attribute:NSLayoutAttributeLeft
													 relatedBy:NSLayoutRelationEqual
														toItem:self
													 attribute:NSLayoutAttributeLeft
													multiplier:1.0
													  constant:10.0]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:left
													 attribute:NSLayoutAttributeCenterY
													 relatedBy:NSLayoutRelationEqual
														toItem:self
													 attribute:NSLayoutAttributeCenterY
													multiplier:centerY
													  constant:0.0]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:right
													 attribute:NSLayoutAttributeRight
													 relatedBy:NSLayoutRelationEqual
														toItem:self
													 attribute:NSLayoutAttributeRight
													multiplier:1.0
													  constant:-hMargin]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:right
													 attribute:NSLayoutAttributeCenterY
													 relatedBy:NSLayoutRelationEqual
														toItem:left
													 attribute:NSLayoutAttributeCenterY
													multiplier:1.0
													  constant:0.0]];
}
@end