//
//  A3iPadBatteryLifeViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 6/12/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3iPadBatteryLifeViewController.h"
#import "common.h"
#import "CommonUIDefinitions.h"
#import "A3BlackThickRoundedRectView.h"

@interface A3iPadBatteryLifeViewController ()

@end

@implementation A3iPadBatteryLifeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

	CGFloat viewHeight;
	if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
		viewHeight = IPAD_SCREEN_HEIGHT_LANDSCAPE;
	} else {
		viewHeight = IPAD_SCREEN_HEIGHT_PORTRAIT;
	}
	A3BlackThickRoundedRectView *backgroundView = [[A3BlackThickRoundedRectView alloc] initWithFrame:CGRectMake(0.0, 0.0, APP_VIEW_WIDTH, viewHeight)];
	self.view = backgroundView;

	self.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
