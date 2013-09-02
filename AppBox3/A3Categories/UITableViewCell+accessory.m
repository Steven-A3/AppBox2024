//
//  UITableViewCell+accessory.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/28/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "UITableViewCell+accessory.h"
#import "A3UIDevice.h"

@implementation UITableViewCell (accessory)

- (UIView *)createAddPublicMarkToSelf {
	UIView *borderView = [UIView new];
	borderView.layer.borderColor = [UIColor whiteColor].CGColor;
	borderView.layer.borderWidth = IS_RETINA ? 1 : 0.5;
	borderView.layer.cornerRadius = 9;

	UILabel *publicString;
	publicString = [UILabel new];
	publicString.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
	publicString.text = @"P";
	publicString.textColor = [UIColor whiteColor];
	publicString.textAlignment = NSTextAlignmentCenter;
	[borderView addSubview:publicString];

	[publicString makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(borderView);
	}];
	[self addSubview:borderView];

	return borderView;
}

@end
