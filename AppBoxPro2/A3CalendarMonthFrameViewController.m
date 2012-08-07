//
//  A3CalendarMonthFrameViewController.m
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 8/7/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3CalendarMonthFrameViewController.h"
#import "A3CalendarMonthView.h"

@interface A3CalendarMonthFrameViewController ()

@property (nonatomic, weak) IBOutlet UILabel *big3LetterMonthLabel;
@property (nonatomic, weak) IBOutlet UILabel *smallFullMonthLabel;
@property (nonatomic, weak) IBOutlet UILabel *yearLabel;
@property (nonatomic, weak) IBOutlet A3CalendarMonthView *monthView;

@end

@implementation A3CalendarMonthFrameViewController

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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];

	[self.monthView setNeedsDisplay];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)jumpToYear:(NSInteger)year month:(NSInteger)month {
	self.monthView.year = year;
	self.monthView.month = month;

	[self.monthView setNeedsDisplay];
	[self updateLabels];
}

- (void)changeYear:(NSInteger)yearDiffence month:(NSInteger)monthDifference {
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
	dateComponents.month = self.monthView.month;
	dateComponents.year = self.monthView.year;
	NSDate *currentDate = [gregorian dateFromComponents:dateComponents];
	NSDateComponents *addComponents = [[NSDateComponents alloc] init];
	addComponents.year = yearDiffence;
	addComponents.month = monthDifference;

	NSDate *newDate = [gregorian dateByAddingComponents:addComponents toDate:currentDate options:0];
	NSDateComponents *resultComponents = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:newDate];

	[self jumpToYear:resultComponents.year month:resultComponents.month];
}

- (IBAction)jumpToPreviousMonth {
	[self changeYear:0 month:-1];
}

- (IBAction)jumpToNextMonth {
	[self changeYear:0 month:1];
}

- (IBAction)jumpToPreviousYear {
	[self changeYear:-1 month:0];
}

- (IBAction)jumpToNextYear {
	[self changeYear:1 month:0];
}

- (void)updateLabels {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
	dateComponents.year = self.monthView.year;
	dateComponents.month = self.monthView.month;
	NSDate *date = [gregorian dateFromComponents:dateComponents];

	[dateFormatter setDateFormat:@"MMM"];
	self.big3LetterMonthLabel.text = [dateFormatter stringFromDate:date];
	[dateFormatter setDateFormat:@"MMMM"];
	self.smallFullMonthLabel.text = [dateFormatter stringFromDate:date];

	self.yearLabel.text = [NSString stringWithFormat:@"%d", self.monthView.year];
}

- (void)jumpToDate:(NSDate *)date {
}

@end
