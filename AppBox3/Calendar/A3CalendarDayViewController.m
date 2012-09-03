//
//  A3CalendarDayViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/27/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3CalendarDayViewController.h"
#import "A3CalendarMonthView.h"
#import "A3Utilities.h"
#import "A3CalendarDayHourlyView.h"

@interface A3CalendarDayViewController ()
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet A3CalendarMonthView *monthView;
@property (nonatomic, strong) IBOutlet A3CalendarDayHourlyView *hourlyView;

@end

@implementation A3CalendarDayViewController
@synthesize dateLabel = _dateLabel;
@synthesize hourlyView = _hourlyView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.currentDate = [NSDate date];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	self.monthView.currentDate = self.currentDate;
	[self updateDateLabel];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];

	[self.hourlyView resetContentSizeAfterLayoutChange];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (IBAction)gotoPreviousDay:(UIButton *)button {
	self.currentDate = [A3Utilities dateByAddingDay:-1 toDate:self.currentDate];
	self.monthView.currentDate = self.currentDate;

	[self updateDateLabel];
}

- (IBAction)gotoNextDay:(UIButton *)button {
	self.currentDate = [A3Utilities dateByAddingDay:1 toDate:self.currentDate];
	self.monthView.currentDate = self.currentDate;

	[self updateDateLabel];
}

- (void)updateDateLabel {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"EEEE, MMM d, y"];

	self.dateLabel.text = [dateFormatter stringFromDate:self.currentDate];
}

@end
