//
//  A3ExpenseListAddBudgetViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/18/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3ExpenseListAddBudgetViewController.h"
#import "UIViewController+A3AppCategory.h"
#import "A3ExpenseListPreferences.h"
#import "A3BarButton.h"
#import "A3UIDevice.h"
#import "common.h"
#import "A3PaperFoldMenuViewController.h"
#import "A3AppDelegate.h"
#import "A3DatePickerView.h"
#import "A3Formatter.h"

static NSString *A3ExpenseListAddBudgetKeyBugdet = @"Bugdet";
static NSString *A3ExpenseListAddBudgetKeyCategory = @"Category";
static NSString *A3ExpenseListAddBudgetKeyPaymentType = @"Type";
static NSString *A3ExpenseListAddBudgetKeyTitle = @"Title";
static NSString *A3ExpenseListAddBudgetKeyDate = @"Date";
static NSString *A3ExpenseListAddBudgetKeyLocation = @"Location";
static NSString *A3ExpenseListAddBudgetKeyNotes = @"Notes";
static NSString *A3ExpenseListAddBudgetKeyShowSimpleAdvanced = @"SimpleAdvanced";

@interface A3ExpenseListAddBudgetViewController () <QuickDialogEntryElementDelegate, QuickDialogStyleProvider, A3QuickDialogCellStyleDelegate>
@property (nonatomic, strong) A3ExpenseListPreferences *pref;
@property (nonatomic, strong) A3DatePickerView *datePickerView;
@property (nonatomic, strong) UILabel *tempDateLabel;
@end

@implementation A3ExpenseListAddBudgetViewController {
	BOOL	_datePickerAnimationInProgress;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		// Custom initialization

		self.title = @"Add Budget";

		[self addTopGradientLayerToView:self.view];
	}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

	[self setSilverBackgroundImageForNavigationBar];

	self.navigationController.navigationBar.clipsToBounds = YES;
	self.navigationItem.rightBarButtonItem = [self doneButton];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIBarButtonItem *)doneButton {
	A3BarButton *doneButton = [[A3BarButton alloc] initWithFrame:CGRectZero];
	doneButton.bounds = CGRectMake(0.0, 0.0, 52.0, 30.0);
	[doneButton setTitle:@"Done" forState:UIControlStateNormal];
	[doneButton addTarget:self action:@selector(doneButtonAction) forControlEvents:UIControlEventTouchUpInside];

	return [[UIBarButtonItem alloc] initWithCustomView:doneButton];
}

- (void)doneButtonAction {
	if (DEVICE_IPAD){
		A3PaperFoldMenuViewController *paperFoldMenuViewController = [[A3AppDelegate instance] paperFoldMenuViewController];
		[paperFoldMenuViewController removeRightWingViewController];
	} else {
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}

- (UIColor *)tableViewBackgroundColor {
	return [UIColor colorWithRed:241.0/255.0 green:242.0/255.0 blue:243.0/255.0 alpha:1.0];
}

- (UIColor *)colorForCellBackground {
	return [UIColor colorWithRed:247.0 / 255.0 green:247.0 / 255.0 blue:247.0 / 255.0 alpha:1.0];
}

- (QRootElement *)rootElement {
	QSection *section = [[QSection alloc] init];
	[section addElement:[self budgetElement]];
	[section addElement:[self categoryElement]];
	[section addElement:[self paymentType]];
	[section addElement:[self showSimpleAdvancedElement]];

	if ([self.pref addBudgetShowAdvanced]) {
		[self insertAdvanedElement:section ];
	}

	QRootElement *root = [[QRootElement alloc] init];
	root.title = @"Add Budget";
	root.grouped = YES;
	[root addSection:section];

	return root;
}

- (QButtonElement *)showSimpleAdvancedElement {
	A3ButtonElement *element = [[A3ButtonElement alloc] initWithTitle:@""];
	element.title = [self.pref addBudgetShowAdvanced] ? @"Simple" : @"Advanced";
	element.key = A3ExpenseListAddBudgetKeyShowSimpleAdvanced;
	element.cellStyleDelegate = self;
	element.onSelected = ^{
		QuickDialogTableView *tableView = self.quickDialogTableView;
		A3ButtonElement *buttonElement = (A3ButtonElement *) [self.root elementWithKey:A3ExpenseListAddBudgetKeyShowSimpleAdvanced];
		NSIndexPath *indexPath = [tableView indexForElement:buttonElement];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];

		NSArray *indexPaths = @[[NSIndexPath indexPathForRow:3 inSection:0],
				[NSIndexPath indexPathForRow:4 inSection:0],
				[NSIndexPath indexPathForRow:5 inSection:0],
				[NSIndexPath indexPathForRow:6 inSection:0]];
		if (self.pref.addBudgetShowAdvanced) {
			[self makeItSimple];
			[tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];

			[self.pref setAddBudgetShowAdvanced:NO];
		} else {
			QSection *section = [self.quickDialogController.quickDialogTableView.root.sections objectAtIndex:0];
			[self insertAdvanedElement:section ];
			[tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];

			[self.pref setAddBudgetShowAdvanced:YES];
		}
	};
	return element;
}

- (void)insertAdvanedElement:(QSection *)section {
	if ([section.elements count] != 4) return;

	[section insertElement:[self titleElement] atIndex:3];
	[section insertElement:[self dateElement] atIndex:4];
	[section insertElement:[self locationElement] atIndex:5];
	[section insertElement:[self notesElement] atIndex:6];
}

- (void)makeItSimple {
	QSection *sectionZero = [self.quickDialogController.quickDialogTableView.root.sections objectAtIndex:0];
	if ([sectionZero.elements count] != 8) return;

	[sectionZero.elements removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 4)] ];
}

- (QEntryElement *)budgetElement {
	A3CurrencyEntryElement *element = [[A3CurrencyEntryElement alloc] initWithTitle:@"Budget" Value:@"" Placeholder:[self zeroCurrency]];
	element.key = A3ExpenseListAddBudgetKeyBugdet;
	element.delegate = self;
	element.cellStyleDelegate = self;
	return element;
}

- (QEntryElement *)categoryElement {
	A3EntryElement *element = [[A3EntryElement alloc] initWithTitle:@"Category" Value:@"Shopping" Placeholder:@""];
	element.key = A3ExpenseListAddBudgetKeyCategory;
	element.delegate = self;
	element.cellStyleDelegate = self;
	element.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	element.onSelected = ^{
		[self onSelectCategory];
	};

	return element;
}

- (QEntryElement *)paymentType {
	A3EntryElement *element = [[A3EntryElement alloc] initWithTitle:@"Payment Type" Value:@"Cash" Placeholder:@""];
	element.key = A3ExpenseListAddBudgetKeyPaymentType;
	element.delegate = self;
	element.cellStyleDelegate = self;
	return element;
}

- (QEntryElement *)titleElement {
	A3EntryElement *element = [[A3EntryElement alloc] initWithTitle:@"Title" Value:@"" Placeholder:@"(Optional)"];
	element.key = A3ExpenseListAddBudgetKeyTitle;
	element.delegate = self;
	element.cellStyleDelegate = self;
	return element;
}

- (A3EntryElement *)dateElement {
	A3EntryElement *element = [[A3EntryElement alloc] initWithTitle:@"Date" Value:[A3Formatter mediumStyleDateStringFromDate:[NSDate date]] Placeholder:@""];
	element.key = A3ExpenseListAddBudgetKeyDate;
	element.delegate = self;
	element.cellStyleDelegate = self;
	return element;
}

- (QEntryElement *)locationElement {
	A3EntryElement *element = [[A3EntryElement alloc] initWithTitle:@"Location" Value:@"Current Location" Placeholder:@""];
	element.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	element.key = A3ExpenseListAddBudgetKeyLocation;
	element.delegate = self;
	element.cellStyleDelegate = self;
	return element;
}

- (QEntryElement *)notesElement {
	A3EntryElement *element = [[A3EntryElement alloc] initWithTitle:@"Notes" Value:@"" Placeholder:@"(Optional)"];
	element.key = A3ExpenseListAddBudgetKeyNotes;
	element.delegate = self;
	element.cellStyleDelegate = self;
	return element;
}

#pragma mark - QuickDialogTableViewStyleProvider

- (void)cell:(UITableViewCell *)cell willAppearForElement:(QElement *)element atIndexPath:(NSIndexPath *)indexPath {
	[super cell:cell willAppearForElement:element atIndexPath:indexPath];

	if ([element isKindOfClass:[A3SelectItemElement class]]) {
		cell.backgroundColor = [UIColor colorWithRed:227.0 / 255.0 green:228.0 / 255.0 blue:230.0 / 255.0 alpha:1.0];
	} else {
		cell.backgroundColor = [self colorForCellBackground];
	}
}

- (A3ExpenseListPreferences *)pref {
	if (nil == _pref) {
		_pref = [[A3ExpenseListPreferences alloc] init];
	}
	return _pref;
}

#pragma mark -- Font and Colors

- (UIFont *)fontForCellLabel {
	CGFloat fontSize = DEVICE_IPAD ? 18.0 : 17.0;
	return [UIFont boldSystemFontOfSize:fontSize];
}

- (UIFont *)fontForEntryCellLabel {
	CGFloat fontSize = DEVICE_IPAD ? 18.0 : 17.0;
	return [UIFont systemFontOfSize:fontSize];
}

- (UIFont *)fontForEntryCellTextField {
	CGFloat fontSize = DEVICE_IPAD ? 18.0 : 17.0;
	return [UIFont boldSystemFontOfSize:fontSize];
}

- (CGFloat)heightForElement:(QElement *)element {
	return 44.0;
}

#pragma mark -- QEntryElement delegate

- (void)QEntryDidBeginEditingElement:(QEntryElement *)element andCell:(QEntryTableViewCell *)cell {
	[super QEntryDidBeginEditingElement:element andCell:cell];

	if ([element.key isEqualToString:A3ExpenseListAddBudgetKeyDate]) {
		_tempDateLabel = [[UILabel alloc] initWithFrame:cell.textField.frame];
		_tempDateLabel.backgroundColor = [UIColor clearColor];
		_tempDateLabel.font = cell.textField.font;
		_tempDateLabel.textColor = cell.textField.textColor;
		_tempDateLabel.text = cell.textField.text;
		[cell.textField.superview addSubview:_tempDateLabel];
		cell.textField.hidden = YES;
		UIView *unvisibleView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1.0, 1.0)];
		unvisibleView.backgroundColor = [UIColor clearColor];
		cell.textField.inputView = unvisibleView;

		[self presentDatePickerView];
	}
}

- (void)QEntryDidEndEditingElement:(QEntryElement *)element andCell:(QEntryTableViewCell *)cell {
	[super QEntryDidEndEditingElement:element andCell:cell];

	if (!_datePickerAnimationInProgress && [_datePickerView superview]) {
		cell.textField.hidden = NO;
		cell.textField.text = _tempDateLabel.text;
		[_tempDateLabel removeFromSuperview];
		_tempDateLabel = nil;
		[self dismissDatePickerView];
	}
}

#pragma mark -- DatePicker view

- (A3DatePickerView *)datePickerView {
	if (nil == _datePickerView) {
		_datePickerView = [[A3DatePickerView alloc] initWithFrame:CGRectZero];
		[_datePickerView.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
	}
	return _datePickerView;
}

- (void)dateChanged:(UIDatePicker *)picker {
	_tempDateLabel.text = [A3Formatter mediumStyleDateStringFromDate:picker.date];
}

- (void)presentDatePickerView {
	_datePickerAnimationInProgress = YES;

	CGSize size = [self.datePickerView sizeThatFits:CGSizeZero];
	CGRect bounds = self.view.bounds;
	CGRect frame = CGRectMake(bounds.origin.x, bounds.origin.y + bounds.size.height, size.width, size.height);
	_datePickerView.frame = frame;
	[self.view addSubview:_datePickerView];
	[UIView animateWithDuration:0.3 animations:^{

		CGRect newFrame = self.datePickerView.frame;
		newFrame.origin.y -= size.height;
		self.datePickerView.frame = newFrame;
	} completion:^(BOOL finished) {
		_datePickerAnimationInProgress = NO;
	}];
}

- (void)dismissDatePickerView {
	if (_datePickerAnimationInProgress) return;

	[UIView animateWithDuration:0.3 animations:^{
		_datePickerAnimationInProgress = YES;

		CGRect frame = self.datePickerView.frame;
		frame.origin.y += frame.size.height;
		self.datePickerView.frame = frame;
	} completion:^(BOOL finished) {
		[self.datePickerView removeFromSuperview];
		_datePickerView = nil;
		_datePickerAnimationInProgress = NO;
	}];
}

#pragma mark -- Category

- (void)onSelectCategory {
	NSArray *category = @[@"Food", @"Personal", @"Pets", @"School", @"Service", @"Shopping", @"Transportation", @"Travel", @"Utilities", @"Uncategorized"];

	NSInteger numberOfRows = [category count];
	QSection *section = [self.quickDialogTableView.root.sections objectAtIndex:0];
	NSMutableArray *insertObjects = [[NSMutableArray alloc] initWithCapacity:numberOfRows];
	NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:numberOfRows];
	NSInteger row = 2;
	for (NSString *title in category) {
		A3SelectItemElement *element = [[A3SelectItemElement alloc] init];
		element.title = title;
		NSString *item = title;
		element.onSelected = ^{
			[self onSelectCategoryItem:item];
		};
		[insertObjects addObject:element];
		[indexPaths addObject:[NSIndexPath indexPathForRow:row++ inSection:0]];
	}
	[section.elements insertObjects:insertObjects atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, [category count])]];

	[self.quickDialogTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];

}

- (void)onSelectCategoryItem:(NSString *)item {
	QSection *section = [self.quickDialogTableView.root.sections objectAtIndex:0];
	[section.elements removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 10)]];

	NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:10];
	NSInteger row = 2, count = 0;
	for (; count < 10; count++) {
		[indexPaths addObject:[NSIndexPath indexPathForRow:row++ inSection:0]];
	}

	[self.quickDialogTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
}

@end
