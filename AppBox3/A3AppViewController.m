//
//  A3AppViewController
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/19/13 9:06 PM.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3AppViewController.h"
#import "UIViewController+A3AppCategory.h"
#import "common.h"


@implementation A3AppViewController {

}

- (void)viewWillDisappear:(BOOL)animated {
	FNLOG(@"check");
	[super viewWillDisappear:animated];

	[self closeActionMenuViewWithAnimation:NO];
}

@end