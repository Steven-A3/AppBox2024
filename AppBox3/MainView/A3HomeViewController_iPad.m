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
#import "PaperFoldView.h"
#import "A3PhoneHomeCalendarMonthViewController.h"
#import "A3GradientView.h"
#import "QuickDialog.h"
#import "A3TimeLineTableViewController.h"

@interface A3HomeViewController_iPad ()
@property (nonatomic, strong) IBOutlet UIScrollView *mainScrollView;
@property (nonatomic, strong) IBOutlet A3StockTickerControl *stockTickerControl;
@property (nonatomic, strong) IBOutlet UIView *contentsView;
@property (nonatomic, strong) IBOutlet UILabel *calendarLabel;
@property (nonatomic, strong) IBOutlet UIView *calendarView;
@property (nonatomic, strong) IBOutlet UIView *timelineView;
@property (nonatomic, strong) A3StatisticsViewController *statisticsViewController;

@property (nonatomic, strong) IBOutlet A3GradientView *calendarTopGradient, *calendarLeftGradient, *calendarRightGradient;
@property (nonatomic, strong) IBOutlet A3GradientView *timelineTopGradient, *timelineLeftGradient, *timelineRightGradient;

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

- (void)setupGradientViews {
	NSArray *gradientColors1 = @[
			(__bridge id)[UIColor colorWithRed:186.0f/255.0f green:187.0f/255.0f blue:189.0f/255.0f alpha:1.0f].CGColor,
			(__bridge id)[UIColor colorWithRed:186.0f/255.0f green:187.0f/255.0f blue:189.0f/255.0f alpha:0.0f].CGColor
	];
	self.calendarTopGradient.gradientColors = gradientColors1;
	self.calendarTopGradient.vertical = NO;
	[self.calendarTopGradient setNeedsDisplay];

	self.timelineTopGradient.gradientColors = gradientColors1;
	self.timelineTopGradient.vertical = NO;
	[self.timelineTopGradient setNeedsDisplay];

	NSArray *gradientColors2 = @[
			(__bridge id)[UIColor colorWithRed:200.0f/255.0f green:201.0f/255.0f blue:201.0f/255.0f alpha:0.0f].CGColor,
			(__bridge id)[UIColor colorWithRed:200.0f/255.0f green:201.0f/255.0f blue:202.0f/255.0f alpha:1.0f].CGColor
	];
	self.calendarLeftGradient.gradientColors = gradientColors2;
	self.calendarLeftGradient.vertical = YES;
	[self.calendarLeftGradient setNeedsDisplay];
	self.timelineLeftGradient.gradientColors = gradientColors2;
	self.timelineLeftGradient.vertical = YES;
	[self.timelineLeftGradient setNeedsDisplay];

	NSArray *gradientColors3 = @[
			(__bridge id)[UIColor colorWithRed:200.0f/255.0f green:201.0f/255.0f blue:202.0f/255.0f alpha:1.0f].CGColor,
			(__bridge id)[UIColor colorWithRed:200.0f/255.0f green:201.0f/255.0f blue:202.0f/255.0f alpha:0.0f].CGColor
	];
	self.calendarRightGradient.gradientColors = gradientColors3;
	self.calendarRightGradient.vertical = YES;
	[self.calendarRightGradient setNeedsDisplay];

	self.timelineRightGradient.gradientColors = gradientColors3;
	self.timelineRightGradient.vertical = YES;
	[self.timelineRightGradient setNeedsDisplay];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	[self.navigationController.navigationBar setBarStyle:UIStatusBarStyleBlackOpaque];

	[self addLeftBarButton];
	[self addRightBarButton];

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

	A3TimeLineTableViewController *timeLineTableViewController = [[A3TimeLineTableViewController alloc] initWithStyle:UITableViewStylePlain];
	[timeLineTableViewController.view setFrame:self.timelineView.bounds];
	[self.timelineView addSubview:timeLineTableViewController.view];
	[self addChildViewController:timeLineTableViewController];

	[self setupGradientViews];

}

- (void)addLeftBarButton {
	NSString *imageFilePath = [[NSBundle mainBundle] pathForResource:@"bt_applist" ofType:@"png"];
	UIImage *sideMenuButtonImage = [UIImage imageWithContentsOfFile:imageFilePath];
	UIBarButtonItem *sideMenuButton = [[UIBarButtonItem alloc] initWithImage:sideMenuButtonImage style:UIBarButtonItemStyleBordered target:self action:@selector(sideMenuButtonAction)];
	self.navigationItem.leftBarButtonItem = sideMenuButton;
}

- (void)addRightBarButton {
	NSString *imageFilePath = [[NSBundle mainBundle] pathForResource:@"icon_notification" ofType:@"png"];
	UIImage *buttonImage = [UIImage imageWithContentsOfFile:imageFilePath];
	UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:buttonImage style:UIBarButtonItemStylePlain target:self action:@selector(showNotificationButtonAction)];
	self.navigationItem.rightBarButtonItem = button;
}

- (void)showNotificationButtonAction {
	self.paperFoldView.state  == PaperFoldStateRightUnfolded ?
			[self.paperFoldView setPaperFoldState:PaperFoldStateDefault animated:YES] :
			[self.paperFoldView setPaperFoldState:PaperFoldStateRightUnfolded animated:YES];
}

- (void)sideMenuButtonAction {
	self.paperFoldView.state  == PaperFoldStateLeftUnfolded ?
			[self.paperFoldView setPaperFoldState:PaperFoldStateDefault animated:YES] :
			[self.paperFoldView setPaperFoldState:PaperFoldStateLeftUnfolded animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
