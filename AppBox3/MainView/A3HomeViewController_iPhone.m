//
//  A3HomeViewController_iPhone.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/10/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3HomeViewController_iPhone.h"
#import "common.h"

@interface A3HomeViewController_iPhone ()

@end

@implementation A3HomeViewController_iPhone

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		[self setTitle:@"Home"];
	}
    return self;
}

- (void)sideMenuButtonAction {

}

- (void)viewDidLoad
{
    [super viewDidLoad];

	[self.navigationController.navigationBar setBarStyle:UIStatusBarStyleBlackOpaque];

	NSString *imageFilePath = [[NSBundle mainBundle] pathForResource:@"bt_applist" ofType:@"png"];
	UIImage *sideMenuButtonImage = [UIImage imageWithContentsOfFile:imageFilePath];
	UIBarButtonItem *sideMenuButton = [[UIBarButtonItem alloc] initWithImage:sideMenuButtonImage style:UIBarButtonItemStyleBordered target:self action:@selector(sideMenuButtonAction)];
	self.navigationItem.leftBarButtonItem = sideMenuButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark A3SegmentedControlDataSource
- (NSUInteger)numberOfColumnsInSegmentedControl:(A3SegmentedControl *)control{
	return 3;
}

- (UIImage *)segmentedControl:(A3SegmentedControl *)control imageForIndex:(NSUInteger)index{
	NSString *imageFilePath = nil;
	switch (index) {
		case 0:
			imageFilePath = [[NSBundle mainBundle] pathForResource:@"icon_home_statistics" ofType:@"png"];
			break;
		case 1:
			imageFilePath = [[NSBundle mainBundle] pathForResource:@"icon_home_calendar" ofType:@"png"];
			break;
		case 2:
			imageFilePath = [[NSBundle mainBundle] pathForResource:@"icon_home_timeline" ofType:@"png"];
			break;
	}
	UIImage *image = nil;
	if (imageFilePath) {
		image = [UIImage imageWithContentsOfFile:imageFilePath];
	}
	return image;
}

- (NSString *)segmentedControl:(A3SegmentedControl *)control titleForIndex:(NSUInteger)index{
	NSString *title = nil;
	switch (index) {
		case 0:
			title = @"Statistics";
			break;
		case 1:
			title = @"Calendar";
			break;
		case 2:
			title = @"Timeline";
			break;
	}
	return title;
}

#pragma mark A3SegmentedControlDelegate

- (void)segmentedControl:(A3SegmentedControl *)control didChangedSelectedIndex:(NSInteger)selectedIndex fromIndex:(NSInteger)fromIndex {
	FNLOG(@"Check Selected Index %d, from: %d", selectedIndex, fromIndex);
}

@end
