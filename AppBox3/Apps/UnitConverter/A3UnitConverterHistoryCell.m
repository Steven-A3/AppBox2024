//
//  A3UnitConverterHistoryCell.m
//  A3TeamWork
//
//  Created by kihyunkim on 13. 10. 23..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3UnitConverterHistoryCell.h"

@implementation A3UnitConverterHistoryCell

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
