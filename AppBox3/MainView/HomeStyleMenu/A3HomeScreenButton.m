//
//  A3HomeScreenButton.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 3/22/16.
//  Copyright © 2016 ALLABOUTAPPS. All rights reserved.
//

#import "A3HomeScreenButton.h"

@implementation A3HomeScreenButton

- (void)layoutSubviews {
	[super layoutSubviews];

	[self.imageView remakeConstraints:^(MASConstraintMaker *make) {
		make.centerX.equalTo(self.centerX);
		make.centerY.equalTo(self.centerY);
		make.width.equalTo(IS_IPHONE ? @30 : IS_IPAD_PRO ? @45 : @40);
		make.height.equalTo(IS_IPHONE ? @30 : IS_IPAD_PRO ? @45 : @40);
	}];
}

@end
