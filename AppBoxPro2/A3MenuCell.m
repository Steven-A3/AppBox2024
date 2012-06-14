//
//  A3MenuCell.m
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 6/11/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3MenuCell.h"
#import "A3Utilities.h"
#import "common.h"
#import "A3RowSeparatorView.h"

@implementation A3MenuCell {
@private
	__weak UILabel *_menuName;
	__weak UIImageView *_appIcon;

	BOOL addedSeparator;
}

@synthesize menuName = _menuName;
@synthesize appIcon = _appIcon;


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
	[super layoutSubviews];

	if (!addedSeparator) {
		A3RowSeparatorView *bottom = [[A3RowSeparatorView alloc] initWithFrame:CGRectMake(10.0, CGRectGetHeight(self.bounds) - 1.0, CGRectGetWidth(self.bounds) - 20.0, 2.0)];
		[self addSubview:bottom];
		addedSeparator = YES;
	}
}


@end
