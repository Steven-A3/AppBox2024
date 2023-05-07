//
//  A3SharePopupFavoriteButton.m
//  AppBox3
//
//  Created by Byeong-Kwon Kwak on 1/30/17.
//  Copyright © 2017 ALLABOUTAPPS. All rights reserved.
//

#import "A3SharePopupFavoriteButton.h"
#import "A3AppDelegate.h"
#import "A3UserDefaults+A3Addition.h"

@interface A3SharePopupFavoriteButton ()

@property (nonatomic, strong) CAShapeLayer *maskLayer;

@end

@implementation A3SharePopupFavoriteButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)awakeFromNib {
	[super awakeFromNib];

	[self setupMask];
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];

	[self setupMask];
}

- (void)setBounds:(CGRect)bounds {
	[super setBounds:bounds];

	[self setupMask];
}

- (void)setupMask {
	UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight cornerRadii:CGSizeMake(10, 10)];
	CAShapeLayer *maskLayer = [CAShapeLayer layer];
	maskLayer.frame = self.bounds;
    maskLayer.fillColor = [[A3UserDefaults standardUserDefaults] themeColor].CGColor;
	maskLayer.path = maskPath.CGPath;
	maskLayer.lineWidth = 1.0;

	self.layer.mask = maskLayer;
	_maskLayer = maskLayer;
}

@end
