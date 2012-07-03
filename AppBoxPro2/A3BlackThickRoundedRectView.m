//
//  A3BlackThickRoundedRectView.m
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 7/2/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "A3BlackThickRoundedRectView.h"

@interface A3BlackThickRoundedRectView ()
- (void)setupLayers;

@end

@implementation A3BlackThickRoundedRectView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self setupLayers];
	}
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self setupLayers];
	}

	return self;
}

- (void)setupLayers {
	CALayer *thickRoundedRectLayer = [CALayer layer];
	thickRoundedRectLayer.cornerRadius = 10.0;
	thickRoundedRectLayer.borderWidth = 2.0;
	thickRoundedRectLayer.borderColor = [UIColor blackColor].CGColor;

	[self.layer addSublayer:thickRoundedRectLayer];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
