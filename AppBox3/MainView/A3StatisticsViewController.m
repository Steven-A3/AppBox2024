//
//  A3StatisticsViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/19/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3StatisticsViewController.h"
#import "A3StatisticsViewCellController.h"
#import "UIDevice+systemStatus.h"
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

@end

@implementation A3StatisticsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

	double memoryUsage = [UIDevice memoryUsage];
	UIView *memoryGaugeView = [[UIView alloc] initWithFrame:CGRectMake(48.0f + 3.0f, 9.0f + (1.0 - memoryUsage)*30.0f, 16.0f, 30.0f * memoryUsage)];
	memoryGaugeView.backgroundColor = [UIColor colorWithRed:229.0f / 255.0f green:192.0f / 255.0f blue:36.0f / 255.0f alpha:1.0f];
	[memoryGaugeView setAccessibilityLabel:@"Memory Usage"];
	[statusView addSubview:memoryGaugeView];

	double storageUsage = [UIDevice storageUsage];
	UIView *storageGuageView = [[UIView alloc] initWithFrame:CGRectMake(48.0f * 2.0f - 9.0f, 8.0f + 32.0f * (1.0f - storageUsage), 28.0f, 32.0f * storageUsage)];
	storageGuageView.backgroundColor = [UIColor colorWithRed:60.0f / 255.0f green:162.0f / 255.0f blue:24.0f / 255.0f alpha:1.0f];
	[storageGuageView setAccessibilityLabel:@"Storage Usage"];
	[statusView addSubview:storageGuageView];

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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

	NSArray *imageFilePaths = @[@"icon_home_events", @"icon_home_downloader", @"icon_home_notes", @"icon_home_photo", @"icon_home_wallet", @"icon_home_status"];
	NSArray *titleLabels = @[@"EVENTS", @"DOWNLOADER", @"NOTES", @"PHOTOS", @"Wallet", @"Device Status"];
	NSAssert([titleLabels count] == 6, @"This has 6 cells");

	NSString *imageFilePath;
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	for (int i = 0; i < 6; i++) {
		A3StatisticsViewCellController *cellController = [[A3StatisticsViewCellController alloc] initWithNibName:@"A3StatisticsViewCellController" bundle:nil];
		CGFloat width = CGRectGetWidth(cellController.view.frame);
		CGFloat height = CGRectGetHeight(cellController.view.frame);
		[cellController.view setFrame:CGRectMake((i % 2) * width, (i / 2) * height, width, height)];

		imageFilePath = [[NSBundle mainBundle] pathForResource:[imageFilePaths objectAtIndex:i] ofType:@"png"];
		cellController.titleImage.image = [UIImage imageWithContentsOfFile:imageFilePath];
		cellController.titleLabel.text = NSLocalizedString([titleLabels objectAtIndex:i], nil);
		cellController.dateLabel.text = [NSString stringWithFormat:@"Updated %@", [dateFormatter stringFromDate:[NSDate date] ] ];

		switch (i) {
			case A3StatisticsCellNameEvents:
				cellController.valueLabel.text = [NSString stringWithFormat:@"%03d", 17];
				cellController.valueLabel.textColor = [UIColor colorWithRed:142.0f/255.0f green:196.0f/255.0f blue:33.0f/255.0f alpha:1.0f];
				cellController.valueLabel.font = [UIFont boldSystemFontOfSize:35.0f];
				break;
			case A3StatisticsCellNameDownloader:
				cellController.valueLabel.text = [NSString stringWithFormat:@"%03d", 124];
				cellController.valueLabel.textColor = [UIColor colorWithRed:6.0f/255.0f green:75.0f/255.0f blue:23.0f/255.0f alpha:1.0f];
				cellController.valueLabel.font = [UIFont boldSystemFontOfSize:55.0f];
				break;
			case A3StatisticsCellNameNotes:
				cellController.valueLabel.text = [NSString stringWithFormat:@"%03d", 026];
				cellController.valueLabel.textColor = [UIColor colorWithRed:6.0f/255.0f green:75.0f/255.0f blue:23.0f/255.0f alpha:1.0f];
				cellController.valueLabel.font = [UIFont boldSystemFontOfSize:45.0f];
				break;
			case A3StatisticsCellNamePhotos:
				cellController.valueLabel.text = [NSString stringWithFormat:@"%03d", 3];
				cellController.valueLabel.textColor = [UIColor colorWithRed:6.0f/255.0f green:75.0f/255.0f blue:23.0f/255.0f alpha:1.0f];
				cellController.valueLabel.font = [UIFont boldSystemFontOfSize:30.0f];
				break;
			case A3StatisticsCellNameWallet:
				cellController.valueLabel.text = [NSString stringWithFormat:@"%03d", 43];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
