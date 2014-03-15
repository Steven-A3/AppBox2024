//
//  A3CalculatorHistoryCell.m
//  A3TeamWork
//
//  Created by Soon Gyu Kim on 12/30/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3CalculatorHistoryCell.h"

@implementation A3CalculatorHistoryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		_L1 = [self addUILabelWithColor:[UIColor blackColor]];
		_L2 = [self addUILabelWithColor:[UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0]];
        
		_R1 = [self addUILabelWithColor:[UIColor colorWithRed:142.0/255.0 green:147.0/255.0 blue:147.0/255.0 alpha:1.0]];
		_R2 = [self addUILabelWithColor:[UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0]];
        
		[self useDynamicType];
		[self doAutolayout];
    }
    return self;
}

- (void)doAutolayout {
	[self addConstraintLeft:_L1 right:_R1 centerY:2.15 * (1.0 / 4.0)];
	[self addConstraintLeft:_L2 right:_R2 centerY:1.425];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)prepareForReuse {
	[super prepareForReuse];
    
	[self useDynamicType];
}

- (void)useDynamicType {
	self.L1.font = [UIFont systemFontOfSize:15];
	self.L2.font = [UIFont systemFontOfSize:13];
    self.L2.textColor = [UIColor colorWithRed:123.0/255.0 green:123.0/255.0 blue:123.0/255.0 alpha:1.0];
	self.R1.font = [UIFont systemFontOfSize:12];
    self.R1.textColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0];
	self.R2.font = [UIFont systemFontOfSize:12];
    self.R1.textColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:147.0/255.0 alpha:1.0];
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
