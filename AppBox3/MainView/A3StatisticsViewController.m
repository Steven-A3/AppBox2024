//
//  A3StatisticsViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/19/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3StatisticsViewController.h"
#import "A3StatisticsViewCellController.h"
#import "A3UIDevice.h"
#import "common.h"
#import "CorePlot-CocoaTouch.h"
#include <mach/mach_host.h>

typedef enum {
	A3StatisticsCellNameEvents = 0,
	A3StatisticsCellNameDownloader,
	A3StatisticsCellNameNotes,
	A3StatisticsCellNamePhotos,
	A3StatisticsCellNameWallet,
	A3StatisticsCellNameDeviceStatus,
} A3StatisticsCellName;

@interface A3StatisticsViewController ()

@property (nonatomic, strong)	NSArray *values;
@property (nonatomic, strong)	CPTGraphHostingView *graphHostingView;
@property (nonatomic, strong)	NSArray *plotLabels;
@property (nonatomic, strong)	NSArray *plotFillColors;

@end

@implementation A3StatisticsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.values = @[@17, @124, @26, @3, @43];
    }
    return self;
}

- (UIView *)deviceStatusView {
	UIView *statusView = [[UIView alloc] initWithFrame:CGRectMake(14.0f, 49.0f, 48.0f * 3.0f, 48.0f)];

	float batteryLevel = MAX([[UIDevice currentDevice] batteryLevel], 0.0f);

	UIView *batteryGaugeView = [[UIView alloc] initWithFrame:CGRectMake(14.0f, 7.0f + (1.0 - batteryLevel) * 37.0f, 20.0f, 37.0f * batteryLevel)];
	batteryGaugeView.backgroundColor = [UIColor colorWithRed:142.0f / 255.0f green:196.0f / 255.0f blue:33.0f / 255.0f alpha:1.0f];
	[batteryGaugeView setAccessibilityLabel:@"Battery Level"];
	[statusView addSubview:batteryGaugeView];

	double memoryUsage = [A3UIDevice memoryUsage];
	UIView *memoryGaugeView = [[UIView alloc] initWithFrame:CGRectMake(48.0f + 3.0f, (CGFloat) (9.0f + (1.0 - memoryUsage)*30.0f), 16.0f, (CGFloat)(30.0f * memoryUsage))];
	memoryGaugeView.backgroundColor = [UIColor colorWithRed:229.0f / 255.0f green:192.0f / 255.0f blue:36.0f / 255.0f alpha:1.0f];
	[memoryGaugeView setAccessibilityLabel:@"Memory Usage"];
	[statusView addSubview:memoryGaugeView];

	double storageUsage = [A3UIDevice storageUsage];
	UIView *storageGaugeView = [[UIView alloc] initWithFrame:CGRectMake(48.0f * 2.0f - 9.0f, (CGFloat)(8.0f + 32.0f * (1.0f - storageUsage)), 28.0f, (CGFloat)(32.0f * storageUsage))];
	storageGaugeView.backgroundColor = [UIColor colorWithRed:60.0f / 255.0f green:162.0f / 255.0f blue:24.0f / 255.0f alpha:1.0f];
	[storageGaugeView setAccessibilityLabel:@"Storage Usage"];
	[statusView addSubview:storageGaugeView];

	NSArray *imageNames = @[@"bg_status_battery", @"bg_status_memory", @"bg_status_storage"];
	int i = 0;
	for (NSString *filename in imageNames) {
		NSString *imagePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"png"];
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * 48.0f - i*10.0f - (i == 1?2.0f:0.0f), 0.0f, 48.0f, 48.0f)];
		imageView.image = [UIImage imageWithContentsOfFile:imagePath];
		[statusView addSubview:imageView];
		i++;
	}
	return statusView;
}

#define    A3_STATISTICS_VIEW_PIE_CHART_SIZE    220.0f

- (void)viewDidLoad
{
    [super viewDidLoad];

	CGFloat offsetX = _showPieChart ? A3_STATISTICS_VIEW_PIE_CHART_SIZE : 0.0f;
	NSInteger numberOfColumns = _showPieChart ? 3 : 2;

	if (_showPieChart) {
		[self addPieChart];
	}

	NSArray *imageFilePaths = @[@"home_events", @"home_downloader", @"home_notes", @"home_photo", @"home_wallet", @"home_status"];
	NSArray *titleLabels = @[@"EVENTS", @"DOWNLOADER", @"NOTES", @"PHOTOS", @"Wallet", @"Device Status"];
	NSAssert([titleLabels count] == 6, @"This has 6 cells");

	NSString *imageFilePath;
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	for (NSUInteger i = 0; i < 6; i++) {
		A3StatisticsViewCellController *cellController = [[A3StatisticsViewCellController alloc] initWithNibName:@"A3StatisticsViewCellController" bundle:nil];
		CGFloat width = CGRectGetWidth(cellController.view.frame);
		CGFloat height = CGRectGetHeight(cellController.view.frame);
		[cellController.view setFrame:CGRectMake(offsetX + (i % numberOfColumns) * width, (i / numberOfColumns) * height, width, height)];

		imageFilePath = [[NSBundle mainBundle] pathForResource:[imageFilePaths objectAtIndex:i] ofType:@"png"];
		cellController.titleImage.image = [UIImage imageWithContentsOfFile:imageFilePath];
		cellController.titleLabel.text = NSLocalizedString([titleLabels objectAtIndex:i], nil);
		cellController.dateLabel.text = [NSString stringWithFormat:@"Updated %@", [dateFormatter stringFromDate:[NSDate date] ] ];

		switch (i) {
			case A3StatisticsCellNameEvents:
				cellController.valueLabel.text = [NSString stringWithFormat:@"%03d", [_values[i] intValue] ];
				cellController.valueLabel.textColor = [UIColor colorWithRed:142.0f/255.0f green:196.0f/255.0f blue:33.0f/255.0f alpha:1.0f];
				cellController.valueLabel.font = [UIFont boldSystemFontOfSize:35.0f];
				break;
			case A3StatisticsCellNameDownloader:
				cellController.valueLabel.text = [NSString stringWithFormat:@"%03d", [_values[i] intValue] ];
				cellController.valueLabel.textColor = [UIColor colorWithRed:6.0f/255.0f green:75.0f/255.0f blue:23.0f/255.0f alpha:1.0f];
				cellController.valueLabel.font = [UIFont boldSystemFontOfSize:55.0f];
				break;
			case A3StatisticsCellNameNotes:
				cellController.valueLabel.text = [NSString stringWithFormat:@"%03d", [_values[i] intValue] ];
				cellController.valueLabel.textColor = [UIColor colorWithRed:6.0f/255.0f green:75.0f/255.0f blue:23.0f/255.0f alpha:1.0f];
				cellController.valueLabel.font = [UIFont boldSystemFontOfSize:45.0f];
				break;
			case A3StatisticsCellNamePhotos:
				cellController.valueLabel.text = [NSString stringWithFormat:@"%03d", [_values[i] intValue] ];
				cellController.valueLabel.textColor = [UIColor colorWithRed:6.0f/255.0f green:75.0f/255.0f blue:23.0f/255.0f alpha:1.0f];
				cellController.valueLabel.font = [UIFont boldSystemFontOfSize:30.0f];
				break;
			case A3StatisticsCellNameWallet:
				cellController.valueLabel.text = [NSString stringWithFormat:@"%03d", [_values[i] intValue] ];
				cellController.valueLabel.textColor = [UIColor colorWithRed:6.0f/255.0f green:75.0f/255.0f blue:23.0f/255.0f alpha:1.0f];
				cellController.valueLabel.font = [UIFont boldSystemFontOfSize:45.0f];
				break;
			case A3StatisticsCellNameDeviceStatus:
				cellController.valueLabel.text = @"";
				[cellController.view addSubview:[self deviceStatusView]];
				break;
		}
		[self.view addSubview:cellController.view];
		[self addChildViewController:cellController];
	}
}

- (NSArray *)plotLabels {
	if (nil == _plotLabels) {
		_plotLabels = @[@"Events", @"Downloader", @"Notes", @"Photos", @"Wallet"];
	}
	return _plotLabels;
}

- (NSArray *)plotFillColors {
	if (nil == _plotFillColors) {
		_plotFillColors = @[
				[UIColor colorWithRed:163.0f/255.0f green:223.0f/255.0f blue:40.0f/255.0f alpha:1.0f],
				[UIColor colorWithRed:2550.f/255.0f green:201.0f/255.0f blue:108.0f/255.0f alpha:1.0f],
				[UIColor colorWithRed:55.0f/255.0f green:231.0f/255.0f blue:227.0f/255.0f alpha:1.0f],
				[UIColor colorWithRed:253.0f/255.0f green:154.0f/244.0f blue:205.0f/255.0f alpha:1.0f],
				[UIColor colorWithRed:154.0f/255.0f green:174.0f/255.0f blue:244.0f/255.0f alpha:1.0f]
		];
	}
	return _plotFillColors;
}

- (void)addPieChart {
	CGRect chartFrame = CGRectMake(0.0f, 0.0f, A3_STATISTICS_VIEW_PIE_CHART_SIZE, A3_STATISTICS_VIEW_PIE_CHART_SIZE);
	self.graphHostingView = [[CPTGraphHostingView alloc] initWithFrame:chartFrame];
	[self.view addSubview:self.graphHostingView];

	CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.graphHostingView.bounds];
	graph.paddingLeft = 0.0f;
	graph.paddingRight = 0.0f;
	graph.paddingTop = 0.0f;
	graph.paddingBottom = 0.0f;
	graph.axisSet = nil;
	[graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
	graph.plotAreaFrame.borderLineStyle = nil;
	graph.backgroundColor = [UIColor clearColor].CGColor;

	self.graphHostingView.hostedGraph = graph;

	CPTMutableLineStyle *whiteLineStyle = [CPTMutableLineStyle lineStyle];
	whiteLineStyle.lineColor = [CPTColor whiteColor];

	CPTMutableShadow *whiteShadow = [CPTMutableShadow shadow];
	whiteShadow.shadowOffset     = CGSizeMake(0.0, -13.0);
	whiteShadow.shadowBlurRadius = 3.0;
	whiteShadow.shadowColor      = [[CPTColor darkGrayColor] colorWithAlphaComponent:0.25];

	CPTGradient *overlayGradient = [[CPTGradient alloc] init];
	overlayGradient.gradientType = CPTGradientTypeRadial;
	overlayGradient = [overlayGradient addColorStop:[[CPTColor whiteColor] colorWithAlphaComponent:1.0] atPosition:0.0];
	overlayGradient = [overlayGradient addColorStop:[[CPTColor whiteColor] colorWithAlphaComponent:0.0] atPosition:1.0];

	CPTPieChart *pieChart = [[CPTPieChart alloc] init];
	pieChart.dataSource = self;
	pieChart.delegate = self;
	pieChart.pieRadius = self.graphHostingView.bounds.size.width * 0.7f / 2.0f;
	pieChart.pieInnerRadius = pieChart.pieRadius / 2.0f - 5.0f;
	pieChart.identifier = @"StatisticsPieChart";
	pieChart.startAngle = M_PI_4;
	pieChart.sliceDirection = CPTPieDirectionClockwise;
	pieChart.borderLineStyle = whiteLineStyle;
	pieChart.shadow = whiteShadow;
	pieChart.overlayFill = [CPTFill fillWithGradient:overlayGradient];
	pieChart.labelOffset = -30.0f;
	pieChart.backgroundColor = [UIColor clearColor].CGColor;

	[graph addPlot:pieChart];
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
	return [_values count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
	return [_values objectAtIndex:index];
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
	static CPTMutableTextStyle *labelTextStyle = nil;
	if (!labelTextStyle) {
		labelTextStyle= [[CPTMutableTextStyle alloc] init];
		labelTextStyle.color = [CPTColor colorWithComponentRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
	}

	return [[CPTTextLayer alloc] initWithText:[self.plotLabels objectAtIndex:index] style:labelTextStyle];
}

-(CPTFill *)sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)idx {
	return [[CPTFill alloc] initWithColor:[self.plotFillColors objectAtIndex:idx]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
