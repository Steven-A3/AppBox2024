//
//  A3SBTickerView.m
//  A3TeamWork
//
//  Created by Sanghyun Yu on 2013. 11. 27..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3SBTickerView.h"

@interface A3SBTickerView ()

@property (nonatomic, strong) id<MASConstraint> constraint1, constraint2;

@end

@implementation A3SBTickerView

- (void)setFrontView:(UIView *)frontView {
	[_constraint1 uninstall];
	[_constraint2 uninstall];
	_constraint1 = nil;
	_constraint2 = nil;

	[super setFrontView:frontView];

	[frontView makeConstraints:^(MASConstraintMaker *make) {
		_constraint1 = make.centerX.equalTo(self.centerX);
		_constraint2 = make.centerY.equalTo(self.centerY);
	}];
}

@end
