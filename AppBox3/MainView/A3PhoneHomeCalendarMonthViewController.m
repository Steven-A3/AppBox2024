//
//  A3PhoneHomeCalendarMonthViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 11/8/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3PhoneHomeCalendarMonthViewController.h"
#import "A3CalendarMonthView.h"
#import "QuickDialog.h"
#import "A3BookendShapeView.h"
#import "A3UIKit.h"
#import "AutoLayoutShorthand.h"

@interface A3PhoneHomeCalendarMonthViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet A3CalendarMonthView *calendarView;
@property (nonatomic, strong) IBOutlet UILabel *yearLabel;
@property (nonatomic, strong) IBOutlet UILabel *monthLabel;
@property (nonatomic, strong) IBOutlet UITableView *eventTableView;
@property (nonatomic, strong) IBOutlet A3BookendShapeView *bookendShapeView;

@property (nonatomic, strong) QuickDialogController *eventDialogController;

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

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
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

- (void)didMoveToParentViewController:(UIViewController *)parent {
	[super didMoveToParentViewController:parent];
}


#pragma mark -- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"Cell";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

	if(cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
	}

	NSArray *events = @[@"Big Foot", @"Dinner w/John", @"Wide Awake"];
	cell.textLabel.text = events[indexPath.row];
	cell.imageView.image = [UIImage imageNamed:@"icon_purple"];
	cell.detailTextLabel.text = @"all-day";

	return cell;
}

#pragma mark -- UITableViewDelegate


@end
