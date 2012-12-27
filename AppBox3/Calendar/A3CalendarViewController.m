//
//  A3CalendarViewController.m
//  AppBox3
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
#import "A3CalendarWeekViewController.h"
#import "A3CalendarDayViewController.h"
#import "A3CalendarListViewController.h"
#import "A3CalendarYearViewController.h"
#import "A3UIKit.h"

typedef enum {
	A3CalendarViewTypeDay = 0,
	A3CalendarViewTypeWeek,
	A3CalendarViewTypeMonth,
	A3CalendarViewTypeYear,
	A3CalendarViewTypeList
} A3CalendarViewType;

@interface A3CalendarViewController ()

@property (nonatomic, strong) IBOutlet CoolButton *todayButton;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) IBOutlet A3CalendarBackgroundView *backgroundView;
@property (nonatomic, strong) IBOutlet UIView *calendarView;
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

	self.title = @"Calendar";

	[self.calendarView setBackgroundColor:[UIColor clearColor]];
	[self.todayButton setButtonColor:[UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:222.0f/255.0f alpha:1.0f]];
	[self.segmentedControl setSelectedSegmentIndex:A3CalendarViewTypeMonth];
	[self changeCalendarType:self.segmentedControl];
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
	for (UIViewController *viewController in self.childViewControllers) {
		[[viewController view] removeFromSuperview];
		[viewController removeFromParentViewController];
	}
	switch ((A3CalendarViewType)segmentedControl.selectedSegmentIndex) {
		case A3CalendarViewTypeDay: {
			A3CalendarDayViewController *viewController = [[A3CalendarDayViewController alloc] initWithNibName:@"A3CalendarDayViewController" bundle:nil];
			[viewController.view setFrame:self.calendarView.frame];
			[self addChildViewController:viewController];
			[self.calendarView addSubview:[viewController view]];
			break;
		}
		case A3CalendarViewTypeWeek: {
			A3CalendarWeekViewController *viewController = [[A3CalendarWeekViewController alloc] initWithNibName:@"A3CalendarWeekViewController" bundle:nil];
			[viewController setSubviewFrame:self.calendarView.frame];
			[self addChildViewController:viewController];
			[viewController didMoveToParentViewController:self];
			[self.calendarView addSubview:[viewController view]];
			break;
		}
		case A3CalendarViewTypeMonth: {
			A3CalendarMonthFrameViewController *viewController = [[A3CalendarMonthFrameViewController alloc] initWithNibName:@"A3CalendarMonthFrameView" bundle:nil];
			[viewController.view setFrame:self.calendarView.frame];
			[self addChildViewController:viewController];
			[self.calendarView addSubview:[viewController view]];
			break;
		}
		case A3CalendarViewTypeYear: {
			A3CalendarYearViewController *viewController = [[A3CalendarYearViewController alloc] initWithNibName:@"A3CalendarYearViewController" bundle:nil];
			[viewController.view setFrame:self.calendarView.frame];
			[self addChildViewController:viewController];
			[self.calendarView addSubview:[viewController view]];
			break;
		}
		case A3CalendarViewTypeList: {
			A3CalendarListViewController *viewController = [[A3CalendarListViewController alloc] initWithNibName:@"A3CalendarListViewController" bundle:nil];
			[viewController.view setFrame:self.calendarView.frame];
			[self addChildViewController:viewController];
			[viewController didMoveToParentViewController:self];
			[self.calendarView addSubview:[viewController view]];
			break;
		}
	}
}

@end
