//
//  A3KeyboardMoveButton.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 12/26/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "A3KeyboardMoveButton.h"
#import "A3UIKit.h"

@implementation A3KeyboardMoveButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];
}

- (UIColor *)buttonColor {
	CGFloat width = 10.0, height = 5;
	UIGraphicsBeginImageContext(CGSizeMake(width, height));
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGRect rect = CGRectMake(0.0, 0.0, width, 2.0);
	NSArray *colors = @[(__bridge id)[UIColor colorWithRed:127.0/255.0 green:128.0/255.0 blue:129.0/255.0 alpha:1.0f].CGColor,
	(__bridge id)[UIColor colorWithRed:96.0/255.0 green:97.0/255.0 blue:103.0/255.0 alpha:0.9].CGColor];
	[A3UIKit drawLinearGradientToContext:context rect:rect withColors:colors];

	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return [UIColor colorWithPatternImage:image];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGRect drawingRect = CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetWidth(rect), 2.5);
	NSArray *colors = @[(__bridge id)[UIColor colorWithRed:107.0/255.0 green:108.0/255.0 blue:115.0/255.0 alpha:1.0f].CGColor,
			(__bridge id)[UIColor colorWithRed:90.0/255.0 green:91.0/255.0 blue:97.0/255.0 alpha:1.0].CGColor,
			(__bridge id)[UIColor colorWithRed:68.0/255.0 green:69.0/255.0 blue:76.0/255.0 alpha:1.0].CGColor];
	[A3UIKit drawLinearGradientToContext:context rect:drawingRect withColors:colors];

	for (NSInteger count = 0; count < 4; count++) {
		drawingRect = CGRectOffset(drawingRect, 0.0, 5.0);
		[A3UIKit drawLinearGradientToContext:context rect:drawingRect withColors:colors];
	}
}

@end
