//
//  A3CalendarWeekViewController.m
//  AppBoxPro2
//
//  Created by Byeong Kwon Kwak on 8/9/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3CalendarWeekViewController.h"
#import "A3CalendarWeekHeaderView.h"
#import "A3CalendarWeekView.h"
#import "A3CalendarWeekViewMetrics.h"

@interface A3CalendarWeekViewController ()

@property (nonatomic, strong) IBOutlet A3CalendarWeekHeaderView	*headerView;
@property (nonatomic, strong) IBOutlet A3CalendarWeekView *weekView;

@end

@implementation A3CalendarWeekViewController

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
	CGFloat x = CGRectGetMinX(self.weekView.frame) + A3_CALENDAR_WEEK_VIEW_ROW_HEADER_WIDTH;
	CGFloat y = CGRectGetMaxY(self.weekView.frame);
	CGFloat width = CGRectGetWidth(self.weekView.bounds) - A3_CALENDAR_WEEK_VIEW_ROW_HEADER_WIDTH;
	UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, 1.0f)];
	bottomLine.backgroundColor = [UIColor colorWithRed:192.0f/255.0f green:193.0f/255.0f blue:194.0f/255.0f alpha:1.0f];
	[self.view addSubview:bottomLine];
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
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
