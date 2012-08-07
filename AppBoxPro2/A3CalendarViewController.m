//
//  A3CalendarViewController.m
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 7/31/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3CalendarViewController.h"
#import "CoolButton.h"
#import "A3CalendarBackgroundView.h"
#import "A3DatePickerViewController.h"
#import "A3CalendarWeekView.h"
#import "common.h"
#import "A3CalendarMonthFrameViewController.h"

typedef enum {
	A3CalendarViewTypeDay = 0,
	A3CalendarViewTypeWeek,
	A3CalendarViewTypeMonth,
	A3CalendarViewTypeYear,
	A3CalendarViewTypeList
} A3CalendarViewType;

@interface A3CalendarViewController ()

@property (nonatomic, weak) IBOutlet CoolButton *todayButton;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, weak) IBOutlet A3CalendarBackgroundView *backgroundView;
@property (nonatomic, weak) IBOutlet UIView *calendarView;
@property (nonatomic, strong) UIPopoverController *datePickerPopoverController;

@end

@implementation A3CalendarViewController
@synthesize todayButton = _todayButton;
@synthesize segmentedControl = _segmentedControl;
@synthesize datePickerPopoverController = _datePickerPopoverController;


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

	[self.calendarView setBackgroundColor:[UIColor clearColor]];

	// Do any additional setup after loading the view from its nib.
	[self.todayButton setButtonColor:[UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:222.0f/255.0f alpha:1.0f]];

	A3CalendarMonthFrameViewController *viewController = [[A3CalendarMonthFrameViewController alloc] initWithNibName:@"A3CalendarMonthFrameView" bundle:nil];
	[self addChildViewController:viewController];
	[self.calendarView addSubview:[viewController view]];
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

	[self.backgroundView setNeedsDisplay];
}

- (IBAction)jumpToToday {
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *dateComponents = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:[NSDate date]];

//	[self jumpToYear:dateComponents.year month:dateComponents.month];
}

- (IBAction)pickDate:(UIButton *)button {
	A3DatePickerViewController *datePickerViewController = [[A3DatePickerViewController alloc] init];

	self.datePickerPopoverController = [[UIPopoverController alloc] initWithContentViewController:datePickerViewController];
	self.datePickerPopoverController.popoverContentSize = CGSizeMake(320.0f, 216.0f);
	self.datePickerPopoverController.popoverLayoutMargins = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
	self.datePickerPopoverController.delegate = self;
	[self.datePickerPopoverController presentPopoverFromRect:button.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {

}

- (IBAction)changeCalendarType:(UISegmentedControl *)segmentedControl {
	switch ((A3CalendarViewType)segmentedControl.selectedSegmentIndex) {
		case A3CalendarViewTypeDay:
			break;
		case A3CalendarViewTypeWeek: {
			A3CalendarWeekView *weekView = [[A3CalendarWeekView alloc] initWithFrame:CGRectMake(20.0f, 98.0f, 930.0f, 572.0f)];
			weekView.contentsView.startDate = [NSDate date];
			[self.view addSubview:weekView];
			break;
		}
		case A3CalendarViewTypeMonth:
			break;
		case A3CalendarViewTypeYear:
			break;
		case A3CalendarViewTypeList:
			break;
	}
}

@end
