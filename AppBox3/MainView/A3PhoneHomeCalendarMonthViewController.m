//
//  A3PhoneHomeCalendarMonthViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 11/8/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3PhoneHomeCalendarMonthViewController.h"
#import "A3CalendarMonthView.h"
#import "common.h"

@interface A3PhoneHomeCalendarMonthViewController ()

@property (nonatomic, strong) IBOutlet A3CalendarMonthView *calendarView;
@property (nonatomic, strong) IBOutlet UILabel *yearLabel;
@property (nonatomic, strong) IBOutlet UILabel *monthLabel;

- (IBAction)buttonPreviousYearPressed;
- (IBAction)buttonNextYearPressed;
- (IBAction)buttonPreviousMonthPressed;
- (IBAction)buttonNextMonthPressed;

@end

@implementation A3PhoneHomeCalendarMonthViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)updateLabels {
	self.yearLabel.text = [NSString stringWithFormat:@"%d", self.calendarView.year];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	self.monthLabel.text = [[dateFormatter monthSymbols] objectAtIndex:(NSUInteger)(self.calendarView.month - 1)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	[self updateLabels];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonPreviousYearPressed {
	[self.calendarView gotoPreviousYear];
	[self updateLabels];
}

- (IBAction)buttonNextYearPressed {
	[self.calendarView gotoNextYear];
	[self updateLabels];
}

- (IBAction)buttonPreviousMonthPressed {
	[self.calendarView gotoPreviousMonth];
	[self updateLabels];
}

- (IBAction)buttonNextMonthPressed {
	[self.calendarView gotoNextMonth];
	[self updateLabels];
}


@end
