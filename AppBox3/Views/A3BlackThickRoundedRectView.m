//
//  A3BlackThickRoundedRectView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 7/2/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "A3BlackThickRoundedRectView.h"
#import "common.h"

@interface A3BlackThickRoundedRectView ()
- (void)setupLayers;

@property (assign)	BOOL layerSetupDone;

@end

@implementation A3BlackThickRoundedRectView
@synthesize layerSetupDone;

- (id)initWithFrame:(CGRect)frame {
	FNLOG(@"");
	self = [super initWithFrame:frame];
	if (self) {
		[self setupLayers];
	}

	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	FNLOG(@"");
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self setupLayers];
	}

	return self;
}

- (void)awakeFromNib {
	FNLOG(@"");
	[self setupLayers];
}

- (void)setupLayers {
	if (self.layerSetupDone)
		return;

	self.layerSetupDone = YES;

	CALayer *thickRoundedRectLayer = [CALayer layer];
	thickRoundedRectLayer.cornerRadius = 5.0;
	thickRoundedRectLayer.bounds = self.layer.bounds;
	thickRoundedRectLayer.anchorPoint = CGPointMake(0.0, 0.0);
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
