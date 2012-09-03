//
//  A3CalendarWeekViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 8/9/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "A3CalendarWeekViewController.h"
#import "A3CalendarWeekHeaderView.h"
#import "A3CalendarWeekView.h"
#import "A3CalendarWeekViewMetrics.h"
#import "A3CalendarWeekTodayMarkView.h"
#import "A3Utilities.h"
#import "common.h"

@interface A3CalendarWeekViewController ()

@property (nonatomic, strong) IBOutlet A3CalendarWeekHeaderView	*headerView;
@property (nonatomic, strong) IBOutlet A3CalendarWeekView *weekView;
@property (nonatomic, strong) A3CalendarWeekTodayMarkView *todayMarkView;
@property (nonatomic, strong) UIView *bottomLine;
@property (nonatomic, strong) IBOutlet UILabel *centerMonthDayLabel;
@property (nonatomic, strong) IBOutlet UILabel *rightTopMonthLabel;
@property (nonatomic, strong) IBOutlet UILabel *yearLabel;

@end

@implementation A3CalendarWeekViewController
@synthesize bottomLine = _bottomLine;
@synthesize todayMarkView = _todayMarkView;
@synthesize firstDateOfWeek = _firstDateOfWeek;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		self.firstDateOfWeek = [A3Utilities firstWeekdayOfDate:[NSDate date]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	[self setBottomLineFrame];
	[self setTodayMarkViewFrame];

	[self updateLabels];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];

	[self.headerView setNeedsDisplay];
	[self.weekView setNeedsDisplay];

	FNLOG(@"scrollview width %f, height %f", CGRectGetWidth(self.weekView.frame), CGRectGetHeight(self.weekView.frame));

	[self setBottomLineFrame];
	[self.weekView setContentSize];
	[self setTodayMarkViewFrame];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)setBottomLineFrame {
	CGFloat x = CGRectGetMinX(self.weekView.frame) + A3_CALENDAR_WEEK_VIEW_ROW_HEADER_WIDTH;
	CGFloat y = CGRectGetMaxY(self.weekView.frame);
	CGFloat width = CGRectGetWidth(self.weekView.bounds) - A3_CALENDAR_WEEK_VIEW_ROW_HEADER_WIDTH;

	[self.bottomLine setFrame:CGRectMake(x, y, width, 1.0f)];
}

- (void)setTodayMarkViewFrame {
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [gregorian components:NSDayCalendarUnit fromDate:self.firstDateOfWeek toDate:[NSDate date] options:0];
	NSInteger index = components.day;
	if ((index >= 0) && (index < 7)) {
		index = 6;

		CGFloat columnWidth = (CGRectGetWidth(self.weekView.frame) - A3_CALENDAR_WEEK_VIEW_ROW_HEADER_WIDTH) / 7.0;
		CGFloat x = CGRectGetMinX([self.view bounds]) + CGRectGetMinX(self.weekView.frame) + A3_CALENDAR_WEEK_VIEW_ROW_HEADER_WIDTH + columnWidth * index;
		x = roundf(x);
		CGRect frame = CGRectMake(x, roundf(CGRectGetMinY(self.headerView.frame)), roundf(columnWidth + 0.5f + (index != 6?1.0f:0.0f)), roundf(CGRectGetHeight(self.weekView.frame) + CGRectGetHeight(self.headerView.frame) ) + 1.0f );
		FNLOG(@"todayMarkviewFrame %f, %f, %f, %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
		[self.todayMarkView setFrame:frame];
	} else {
		self.todayMarkView = nil;
	}
}

- (UIView *)bottomLine {
	if (nil == _bottomLine) {
		self.bottomLine = [[UIView alloc] initWithFrame:CGRectZero];
		self.bottomLine.backgroundColor = [UIColor colorWithRed:192.0f/255.0f green:193.0f/255.0f blue:194.0f/255.0f alpha:1.0f];
		[self.view addSubview:self.bottomLine];
	}
	return _bottomLine;
}

- (void)setTodayMarkView:(A3CalendarWeekTodayMarkView *)todayMarkView {
	if (nil == todayMarkView) {
		[_todayMarkView removeFromSuperview];
	}
	_todayMarkView = todayMarkView;
}

- (A3CalendarWeekTodayMarkView *)todayMarkView {
	if (nil == _todayMarkView) {
		_todayMarkView = [[A3CalendarWeekTodayMarkView alloc] initWithFrame:CGRectZero];
		[self.view addSubview:_todayMarkView];
	}
	return _todayMarkView;
}

- (void)setSubviewFrame:(CGRect)frame {
	[self.view setFrame:frame];
	[self setBottomLineFrame];
}

- (void)updateDisplay {
	self.headerView.startDate = self.firstDateOfWeek;

	[self.headerView setNeedsDisplay];
	[self setTodayMarkViewFrame];
	[self updateLabels];
}

- (IBAction)gotoPreviousWeek {
	NSDateComponents *components = [[NSDateComponents alloc] init];
	components.week = -1;

	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	self.firstDateOfWeek = [gregorian dateByAddingComponents:components toDate:self.firstDateOfWeek options:0];

	[self updateDisplay];
}

- (IBAction)gotoNextWeek {
	NSDateComponents *components = [[NSDateComponents alloc] init];
	components.week = 1;

	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	self.firstDateOfWeek = [gregorian dateByAddingComponents:components toDate:self.firstDateOfWeek options:0];

	[self updateDisplay];
}

- (IBAction)gotoPreviousYear {
	NSDateComponents *components = [[NSDateComponents alloc] init];
	components.year = -1;

	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	self.firstDateOfWeek = [gregorian dateByAddingComponents:components toDate:self.firstDateOfWeek options:0];

	[self updateDisplay];
}

- (IBAction)gotoNextYear {
	NSDateComponents *components = [[NSDateComponents alloc] init];
	components.year = 1;

	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	self.firstDateOfWeek = [gregorian dateByAddingComponents:components toDate:self.firstDateOfWeek options:0];

	[self updateDisplay];
}

- (void)updateLabels {
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *addingComponents = [[NSDateComponents alloc] init];
	addingComponents.day = 6;
	NSDate *endDate = [gregorian dateByAddingComponents:addingComponents toDate:self.firstDateOfWeek options:0];

	NSDateComponents *firstComponents = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self.firstDateOfWeek];
	NSDateComponents *endComponents = [gregorian components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:endDate];

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"MMM"];
	if (firstComponents.month == endComponents.month) {
		NSString *monthText = [dateFormatter stringFromDate:self.firstDateOfWeek];
		[dateFormatter setDateFormat:@"d"];
		self.centerMonthDayLabel.text = [NSString stringWithFormat:@"%@ %@ - %@", monthText, [dateFormatter stringFromDate:self.firstDateOfWeek], [dateFormatter stringFromDate:endDate]];
	} else {
		[dateFormatter setDateFormat:@"MMM d"];
		self.centerMonthDayLabel.text = [NSString stringWithFormat:@"%@ - %@", [dateFormatter stringFromDate:self.firstDateOfWeek], [dateFormatter stringFromDate:endDate]];
	}

	[dateFormatter setDateFormat:@"MMMM"];
	self.rightTopMonthLabel.text = [dateFormatter stringFromDate:self.firstDateOfWeek];
	self.yearLabel.text = [NSString stringWithFormat:@"%d", firstComponents.year];
}

- (void)setFirstDateOfWeek:(NSDate *)firstDateOfWeek {
	_firstDateOfWeek = [A3Utilities firstWeekdayOfDate:firstDateOfWeek];
}

@end
