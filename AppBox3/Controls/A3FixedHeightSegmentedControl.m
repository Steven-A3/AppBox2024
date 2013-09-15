//
//  A3FixedHeightSegmentedControl.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/14/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3FixedHeightSegmentedControl.h"

@implementation A3FixedHeightSegmentedControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (CGSize)intrinsicContentSize {
	CGSize size = [super intrinsicContentSize];
	size.height = _fixedHeight;
	return size;
}

- (CGSize)sizeThatFits:(CGSize)size {
	CGSize mySize = [super sizeThatFits:size];
	mySize.height = _fixedHeight;
	return mySize;
}

- (void)sizeToFit {
	[super sizeToFit];
	CGRect frame = self.frame;
	frame.size.height = _fixedHeight;
	self.frame = frame;
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
