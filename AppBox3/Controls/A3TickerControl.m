//
//  A3TickerControl.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/18/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3TickerControl.h"

@interface A3TickerControl ()
@property (nonatomic, strong) A3TickerScrollView *scrollView;
@property (nonatomic, strong) NSTimer *scrollingTimer;

@end

#define SCROLLING_TIME_INTERVAL 0.02
#define SCROLLING_PIXEL_DISTANCE 1

@implementation A3TickerControl {
	BOOL startScrolling;
	CGFloat contentWidth;
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

- (void)initialize {
	[self addSubview:self.scrollView];
	[_scrollView makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self);
	}];
}

- (A3TickerScrollView *)scrollView {
	if (nil == _scrollView) {
		_scrollView = [[A3TickerScrollView alloc] initWithFrame:self.bounds];
		_scrollView.delegate = self;
		_scrollView.touchDelegate = self;
		_scrollView.showsHorizontalScrollIndicator = NO;
	}
	return _scrollView;
}

//start scroll animation
- (void)startScrolling {
	if (!startScrolling) {
		startScrolling = YES;
		self.scrollingTimer = [NSTimer scheduledTimerWithTimeInterval:SCROLLING_TIME_INTERVAL
														  target:self
														selector:@selector(scroll:)
														userInfo:nil
														 repeats:YES];
	}
}

//stop scroll animation
- (void)stopScrolling {
	if (startScrolling) {
		[self.scrollingTimer invalidate];
		self.scrollingTimer = nil;
		startScrolling = NO;
	}
}

- (void)scroll:(NSTimer *)timer {
	if ([self.scrollView contentOffset].x >= contentWidth - self.frame.size.width) {
		[self.scrollView setContentOffset:CGPointMake(0, 0)];
	}
	CGPoint point = [self.scrollView contentOffset];
	point.x += SCROLLING_PIXEL_DISTANCE;
	[self.scrollView setContentOffset:point];
}

#pragma Scrollview Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self startScrolling];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	[self startScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	[self startScrolling];
}
#pragma mark CustomScrollviewDelegate

- (void)userEndTouch {
	//start scrolling again when user end touching
	[self startScrolling];
}

- (void)userTouch {
	//stop scrolling when user touch it
	[self stopScrolling];
}

- (void)userDrag {

}

- (void)startAnimation {
	for (UIView *subView in self.scrollView.subviews) {
		[subView removeFromSuperview];
	}

	CGFloat originX = CGRectGetWidth(self.bounds);
	for (UIView *newSubView in self.marqueeItems) {
		newSubView.frame = CGRectMake(originX, CGRectGetMinY(newSubView.frame), CGRectGetWidth(newSubView.frame), CGRectGetHeight(_scrollView.frame));
		[self.scrollView addSubview:newSubView];
		originX += CGRectGetWidth(newSubView.frame);
	}
	contentWidth = originX + CGRectGetWidth(self.bounds);
	[self.scrollView setContentSize:CGSizeMake(contentWidth, CGRectGetHeight(self.bounds))];

	[self startScrolling];
}

@end
