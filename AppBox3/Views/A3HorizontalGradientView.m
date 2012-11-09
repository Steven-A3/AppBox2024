//
//  A3HorizontalGradientView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/23/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3HorizontalGradientView.h"
#import "A3Utilities.h"

@implementation A3HorizontalGradientView

- (NSArray *)gradientColors {
	if (nil == _gradientColors) {
		_gradientColors = @[(__bridge id)[[UIColor colorWithRed:247.0f/255.0f green:250.0f/255.0f blue:249.0f/255.0f alpha:1.0f] CGColor],
		(__bridge id)[[UIColor colorWithRed:232.0f/255.0f green:235.0f/255.0f blue:234.0f/255.0f alpha:1.0f] CGColor]];
	}
	return _gradientColors;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();
	drawLinearGradient(context, rect, self.gradientColors);
}

@end
