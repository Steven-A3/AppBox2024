//
//  A3AbbreviationTableViewCell.m
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 12/13/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3AbbreviationTableViewCell.h"

@interface A3AbbreviationTableViewCell ()

@end

@implementation A3AbbreviationTableViewCell

+ (NSString *)reuseIdentifier {
	return @"abbreviationTableViewCell";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)addTrapezoidShape {
	CGRect bounds = self.alphabetTopView.bounds;
	UIBezierPath *trapezoidPath = [UIBezierPath new];
	[trapezoidPath moveToPoint:CGPointMake(7, 0)];
	[trapezoidPath addLineToPoint:CGPointMake(0, bounds.size.height)];
	[trapezoidPath addLineToPoint:CGPointMake(bounds.size.width, bounds.size.height)];
	[trapezoidPath addLineToPoint:CGPointMake(bounds.size.width - 6, 0)];
	[trapezoidPath closePath];
	
	CAShapeLayer *trapezoidShapeLayer = [CAShapeLayer layer];
	trapezoidShapeLayer.frame = self.alphabetTopView.bounds;
	trapezoidShapeLayer.fillColor = [UIColor whiteColor].CGColor;
	trapezoidShapeLayer.path = trapezoidPath.CGPath;
	self.alphabetTopView.layer.mask = trapezoidShapeLayer;
}

- (void)setClipToTrapezoid:(BOOL)clipToTrapezoid {
	_clipToTrapezoid = clipToTrapezoid;
	if (_clipToTrapezoid) {
		[self addTrapezoidShape];
	} else {
		self.alphabetTopView.layer.mask = nil;
	}
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];

	if (_clipToTrapezoid) {
		[self addTrapezoidShape];
	}
}

@end
