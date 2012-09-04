//
//  A3CalendarYearViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/4/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3CalendarYearViewController.h"
#import "A3CalendarMonthView.h"

@interface A3CalendarYearViewController ()

@end

@implementation A3CalendarYearViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSArray *)monthViews {
	return [[self.view viewWithTag:1000] subviews];
}

- (UIView *)monthParentViewForMonth:(NSInteger)month {
	return [[self monthViews] objectAtIndex:month];
}

- (void)highlightCurrentMonthLabel {
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [gregorian components:NSMonthCalendarUnit|NSYearCalendarUnit fromDate:[NSDate date]];

	UIColor *highlightColor = [UIColor colorWithRed:221.0f/255.0f green:217.0f/255.0f blue:246.0f/255.0f alpha:1.0f];
	UIColor *normalColor = [UIColor colorWithRed:229.0f/255.0f green:229.0f/255.0f blue:229.0f/255.0f alpha:1.0f];
	for (UIView *monthParentView in [self monthViews]) {
		UILabel *monthLabel = [[monthParentView subviews] objectAtIndex:0];
		monthLabel.textColor = components.month == monthParentView.tag ? highlightColor : normalColor;
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

	for (UIView *monthParentView in [self monthViews]) {
		A3CalendarMonthView *monthView = [[monthParentView subviews] objectAtIndex:1];
		monthView.year = 2012;
	}
	[self layoutMonthViewsWithOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
	[self highlightCurrentMonthLabel];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)layoutMonthViewsWithOrientation:(UIInterfaceOrientation)interfaceOrientation {
	CGFloat width = 211.0f, columnSpace = 20.0f, height = 185.0f, rowSpace = 10.0f/* Portrait Only */;
	if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
		// Now Landscape orientation.
		UIView *monthsParentView = [self.view viewWithTag:1000];
		[monthsParentView setFrame:CGRectMake(30.0f, 70.0f, 211.0f*4.0f + 40.0f, 185.0f*3.0f)];
		for (UIView *view in [monthsParentView subviews]) {
			NSInteger index = view.tag - 1;
			[view setFrame:CGRectMake((width + columnSpace) * (CGFloat)(index % 4), height * (CGFloat)(index / 4), width, height)];
			if (view.tag == 4) {
				A3CalendarMonthView *monthView = [[view subviews] objectAtIndex:1];
				monthView.drawWeekdayLabel = YES;
				[monthView setNeedsDisplay];
			}
		}
	} else {
		UIView *monthsParentView = [self.view viewWithTag:1000];
		[monthsParentView setFrame:CGRectMake(20.0f, 100.0f, 211.0f*3.0f + 40.0f, 185.0f*4.0f)];
		for (UIView *view in [monthsParentView subviews]) {
			NSInteger index = view.tag - 1;
			[view setFrame:CGRectMake((width + columnSpace) * (CGFloat)(index % 3), (height + rowSpace) * (CGFloat)(index / 3), width, height)];
			if (view.tag == 4) {
				A3CalendarMonthView *monthView = [[view subviews] objectAtIndex:1];
				monthView.drawWeekdayLabel = NO;
				[monthView setNeedsDisplay];
			}
		}
	}
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

	[self layoutMonthViewsWithOrientation:[[UIApplication sharedApplication] statusBarOrientation] ];
}


@end
