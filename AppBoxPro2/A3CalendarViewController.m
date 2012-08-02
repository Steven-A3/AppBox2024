//
//  A3CalendarViewController.m
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 7/31/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3CalendarViewController.h"
#import "A3CalendarMonthView.h"
#import "CoolButton.h"
#import "A3CalendarBackgroundView.h"

@interface A3CalendarViewController ()

@property (weak, nonatomic) IBOutlet A3CalendarMonthView *monthView;
@property (weak, nonatomic) IBOutlet CoolButton *todayButton;
@property (weak, nonatomic) IBOutlet UILabel *bigMonthLabel;
@property (weak, nonatomic) IBOutlet UILabel *smallMonthLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet A3CalendarBackgroundView *backgroundView;

@end

@implementation A3CalendarViewController
@synthesize monthView = _monthView;
@synthesize todayButton = _todayButton;
@synthesize segmentedControl = _segmentedControl;


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

    // Do any additional setup after loading the view from its nib.
	[self.todayButton setButtonColor:[UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:222.0f/255.0f alpha:1.0f]];

	[self updateLabels];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];

	[self.monthView setNeedsDisplay];
	[self.backgroundView setNeedsDisplay];
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

- (IBAction)jumpToToday {
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *dateComponents = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:[NSDate date]];

	[self jumpToYear:dateComponents.year month:dateComponents.month];
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
	self.bigMonthLabel.text = [dateFormatter stringFromDate:date];
	[dateFormatter setDateFormat:@"MMMM"];
	self.smallMonthLabel.text = [dateFormatter stringFromDate:date];

	self.yearLabel.text = [NSString stringWithFormat:@"%d", self.monthView.year];
}

@end
