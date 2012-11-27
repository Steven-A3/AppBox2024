//
//  A3HomeViewController_iPad.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 11/27/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3HomeViewController_iPad.h"
#import "A3StockTickerControl.h"
#import "A3WeatherStickerViewController.h"
#import "A3StatisticsViewController.h"
#import "A3PhoneHomeCalendarMonthViewController.h"

@interface A3HomeViewController_iPad ()
@property (nonatomic, strong) IBOutlet UIScrollView *mainScrollView;
@property (nonatomic, strong) IBOutlet A3StockTickerControl *stockTickerControl;
@property (nonatomic, strong) IBOutlet UIView *contentsView;
@property (nonatomic, strong) IBOutlet UILabel *calendarLabel;
@property (nonatomic, strong) IBOutlet UIView *calendarView;
@property (nonatomic, strong) A3StatisticsViewController *statisticsViewController;

@end

@implementation A3HomeViewController_iPad

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

- (A3StatisticsViewController *)statisticsViewController {
	if (nil == _statisticsViewController) {
		_statisticsViewController = [[A3StatisticsViewController alloc] init];
		_statisticsViewController.showPieChart = YES;
		[_statisticsViewController.view setFrame:CGRectMake(0.0f, 0.0f, 714.0f, 220.0f)];
	}
	return _statisticsViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	[self.navigationController.navigationBar setBarStyle:UIStatusBarStyleBlackOpaque];

	NSString *imageFilePath = [[NSBundle mainBundle] pathForResource:@"bt_applist" ofType:@"png"];
	UIImage *sideMenuButtonImage = [UIImage imageWithContentsOfFile:imageFilePath];
	UIBarButtonItem *sideMenuButton = [[UIBarButtonItem alloc] initWithImage:sideMenuButtonImage style:UIBarButtonItemStyleBordered target:self action:@selector(sideMenuButtonAction)];
	self.navigationItem.leftBarButtonItem = sideMenuButton;

	A3WeatherStickerViewController *weatherStickerVC = [[A3WeatherStickerViewController alloc] initWithNibName:nil bundle:nil];
	CGRect frame = weatherStickerVC.view.frame;
	[weatherStickerVC.view setFrame:CGRectMake(self.view.bounds.size.width - frame.size.width - 10.0f, 10.0f, CGRectGetWidth(frame), CGRectGetHeight(frame))];
	[self.mainScrollView addSubview:[weatherStickerVC view]];
	[self addChildViewController:weatherStickerVC];

	[self.stockTickerControl startStockTickerAnimation];
    [self addChildViewController:self.statisticsViewController];
	[self.contentsView insertSubview:[self.statisticsViewController view] belowSubview:self.calendarLabel ];

	A3PhoneHomeCalendarMonthViewController *calendarMonthViewController = [[A3PhoneHomeCalendarMonthViewController alloc] initWithNibName:@"A3PhoneHomeCalendarMonthViewController" bundle:nil];
	[self.calendarView addSubview:[calendarMonthViewController view] ];
    [self addChildViewController:calendarMonthViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
