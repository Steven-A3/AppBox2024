//
//  A3TickerScrollView.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/18/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3TickerScrollView.h"

@implementation A3TickerScrollView

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ([self.touchDelegate respondsToSelector:@selector(userTouch)]) {
		[self.touchDelegate userTouch];
	}
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if ([self.touchDelegate respondsToSelector:@selector(userDrag)]) {
		[self.touchDelegate userDrag];
	}
}

- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event {

	if (!self.dragging) {
		[self.nextResponder touchesEnded: touches withEvent:event];
	}
	[super touchesEnded: touches withEvent: event];

	if ([self.touchDelegate respondsToSelector:@selector(userEndTouch)]) {
		[self.touchDelegate userEndTouch];
	}
}

@end
