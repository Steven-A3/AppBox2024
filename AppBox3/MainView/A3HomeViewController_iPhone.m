//
//  A3HomeViewController_iPhone.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/10/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3HomeViewController_iPhone.h"
#import "A3TickerControl.h"
#import "A3StatisticsViewController.h"
#import "A3MainMenuTableViewController.h"
#import "A3PhoneHomeCalendarMonthViewController.h"
#import "A3WeatherStickerViewController.h"
#import "A3StockTickerControl.h"
#import "UIViewController+A3AppCategory.h"
#import "UIViewController+MMDrawerController.h"
#import "common.h"
#import "UIViewController+navigation.h"

enum {
	A3PhoneHomeScreenSegmentSelectionStatistics = 0,
	A3PhoneHomeScreenSegmentSelectionCalendar,
	A3PhoneHomeScreenSegmentSelectionTimeline
};

@interface A3HomeViewController_iPhone ()

@property (nonatomic, strong) IBOutlet UIScrollView *mainScrollView;
@property (nonatomic, strong) IBOutlet A3StockTickerControl *stockTickerControl;
@property (nonatomic, strong) IBOutlet UIView *contentsView;
@property (nonatomic, strong) IBOutlet A3SegmentedControl *segmentedControl;
@property (nonatomic, strong) A3MainMenuTableViewController *menuTableViewController;

@end

@implementation A3HomeViewController_iPhone

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		[self setTitle:@"Home"];

		[[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
	}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	[self leftBarButtonAppsButton];

	CGRect screenBounds = [[UIScreen mainScreen] bounds];
	screenBounds.size.height -= 44.0 + 20.0;	// for navigation bar + status bar
	_mainScrollView.frame = screenBounds;

	[self segmentedControl:self.segmentedControl didChangedSelectedIndex:0 fromIndex:0];

	A3WeatherStickerViewController *weatherStickerVC = [[A3WeatherStickerViewController alloc] initWithNibName:nil bundle:nil];
	CGRect frame = weatherStickerVC.view.frame;
	[weatherStickerVC.view setFrame:CGRectMake(174.0f, 10.0f, CGRectGetWidth(frame), CGRectGetHeight(frame))];
	[self.mainScrollView addSubview:[weatherStickerVC view]];
	[self addChildViewController:weatherStickerVC];

	[self.stockTickerControl startStockTickerAnimation];
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
	NSString *imageName = nil;
	switch (index) {
		case 0:
			imageName = @"home_statistics";
			break;
		case 1:
			imageName = @"home_calendar";
			break;
		case 2:
			imageName = @"home_timeline";
			break;
	}
	UIImage *image = nil;
	if (imageName) {
		image = [UIImage imageNamed:imageName];
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
//	FNLOG(@"Check Selected Index %d, from: %d", selectedIndex, fromIndex);

	if (self.activeViewControllerForSelectedSegment) {
		[_activeViewControllerForSelectedSegment.view removeFromSuperview];
		[_activeViewControllerForSelectedSegment removeFromParentViewController];
	}
	switch (selectedIndex) {
		case A3PhoneHomeScreenSegmentSelectionStatistics: {
			A3StatisticsViewController *viewController = [[A3StatisticsViewController alloc] initWithNibName:nil bundle:nil];
			_mainScrollView.contentSize = CGSizeMake(320.0, _contentsView.frame.origin.y + 310.0);
			[self.contentsView addSubview:viewController.view];
			self.activeViewControllerForSelectedSegment = viewController;
			break;
		}
		case A3PhoneHomeScreenSegmentSelectionCalendar: {
			_mainScrollView.contentSize = CGSizeMake(320.0, _contentsView.frame.origin.y + 370.0);
			A3PhoneHomeCalendarMonthViewController *viewController = [[A3PhoneHomeCalendarMonthViewController alloc] initWithNibName:@"A3PhoneHomeCalendarMonthViewController" bundle:nil];
            [viewController.view setFrame:_contentsView.bounds];
			[self.contentsView addSubview:viewController.view];
            
			self.activeViewControllerForSelectedSegment = viewController;
			break;
		}
	}
	[self addChildViewController:self.activeViewControllerForSelectedSegment];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];

	CGSize contentSize;
	switch (_segmentedControl.selectedIndex) {
		case A3PhoneHomeScreenSegmentSelectionStatistics:
			contentSize = CGSizeMake(320.0, 504.0);
			break;
		case A3PhoneHomeScreenSegmentSelectionCalendar: {
			contentSize = CGSizeMake(320.0, 564.0);
			break;
        }
		case A3PhoneHomeScreenSegmentSelectionTimeline:
			contentSize = CGSizeMake(320.0, 564.0);
			break;
	}
	_mainScrollView.contentSize = contentSize;
}

@end
