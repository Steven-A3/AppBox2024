//
//  A3HolidaysAddToDaysCounterViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 9/2/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3HolidaysAddToDaysCounterViewController.h"
#import "A3UIDevice.h"
#import "UIViewController+NumberKeyboard.h"
#import "HolidayData.h"
#import "HolidayData+Country.h"
#import "UIViewController+tableViewStandardDimension.h"
#import "A3StandardTableViewCell.h"
#import "A3AppDelegate.h"

@interface A3HolidaysAddToDaysCounterViewController ()

@property (nonatomic, strong) NSArray *holidaysForCountry;

@end

@implementation A3HolidaysAddToDaysCounterViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

static NSString *CellIdentifier = @"Cell";

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

	self.navigationItem.prompt = NSLocalizedString(@"Add Holidays to \"Days Counter\" app", @"Add Holidays to \"Days Conter\" app");
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonAction:)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonAction:)];
	self.navigationItem.rightBarButtonItem = doneButton;

	self.title = NSLocalizedString(A3AppName_Holidays, @"Holidays");

	self.tableView.separatorColor = A3UITableViewSeparatorColor;
	self.tableView.separatorInset = A3UITableViewSeparatorInset;
	if ([self.tableView respondsToSelector:@selector(cellLayoutMarginsFollowReadableWidth)]) {
		self.tableView.cellLayoutMarginsFollowReadableWidth = NO;
	}
	[self.tableView registerClass:[A3StandardTableViewCell class] forCellReuseIdentifier:CellIdentifier];

	[self registerContentSizeCategoryDidChangeNotification];
}

- (void)removeObserver {
	[self removeContentSizeCategoryDidChangeNotification];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if ([self isMovingFromParentViewController] || [self isBeingDismissed]) {
		FNLOG();
		[self removeObserver];
	}
}

- (void)dealloc {
	[self removeObserver];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];

	if (self.isMovingFromParentViewController) {
		[self removeObserver];
	}
}

- (void)contentSizeDidChange:(NSNotification *)notification {
	[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doneButtonAction:(UIBarButtonItem *)button {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelButtonAction:(UIBarButtonItem *)button {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setCountryCode:(NSString *)countryCode {
	_countryCode = [countryCode mutableCopy];
	HolidayData *holidayData = [HolidayData new];
	_holidaysForCountry = [holidayData holidaysForCountry:_countryCode year:[HolidayData thisYear] fullSet:NO ];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_holidaysForCountry count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    A3StandardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

	NSDictionary *holiday = self.holidaysForCountry[indexPath.row];

    // Configure the cell...
	cell.textLabel.font = IS_IPHONE ? [UIFont systemFontOfSize:15] : [UIFont systemFontOfSize:17];
	cell.textLabel.text = holiday[kHolidayName];
	cell.accessoryView = [self plusButton];
    
    return cell;
}

- (UIButton *)plusButton {
	UIButton *plusButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[plusButton setImage:[UIImage imageNamed:@"add04"] forState:UIControlStateNormal];
	[plusButton setImage:[UIImage imageNamed:@"add05"] forState:UIControlStateDisabled];
	[plusButton addTarget:self action:@selector(addButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[plusButton sizeToFit];
	return plusButton;
}

- (void)addButtonAction:(UIButton *)button {
	[button setEnabled:!button.enabled];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	UIButton *button = (UIButton *) cell.accessoryView;
	[button setEnabled:!button.enabled];
}

@end
