//
//  A3CalendarWeekView.m
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 8/3/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "A3CalendarWeekView.h"
#import "A3CalendarWeekViewMetrics.h"

@interface A3CalendarWeekView ()
@property(nonatomic, strong) A3CalendarWeekContentsView *contentsView;

@end

@implementation A3CalendarWeekView
@synthesize contentsView = _contentsView;


- (void)initialize {
	self.contentSize = CGSizeMake(CGRectGetWidth(self.bounds), A3_CALENDAR_WEEKVIEW_HEIGHT);
	self.contentOffset = CGPointMake(0.0f, 0.0f);
	self.backgroundColor = [UIColor clearColor];
	self.bounces = NO;
	[self addSubview:self.contentsView];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self initialize];
	}
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self initialize];
	}

	return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (A3CalendarWeekContentsView *)contentsView {
	if (nil == _contentsView) {
		_contentsView = [[A3CalendarWeekContentsView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds), self.contentSize.height)];
	}
	return _contentsView;
}

@end
