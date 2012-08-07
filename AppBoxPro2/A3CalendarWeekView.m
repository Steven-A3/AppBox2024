//
//  A3CalendarWeekView.m
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 8/3/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3CalendarWeekView.h"
#import "A3CalendarWeekContentsView.h"

@implementation A3CalendarWeekView
@synthesize contentsView = _contentsView;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		_contentsView = [[A3CalendarWeekContentsView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds), A3_CALENDAR_WEEKVIEW_HEIGHT)];
		[self addSubview:_contentsView];
		self.contentSize = CGSizeMake(CGRectGetWidth(self.bounds), A3_CALENDAR_WEEKVIEW_HEIGHT);
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

@end
