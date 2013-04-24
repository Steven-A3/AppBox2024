//
//  A3ExpenseListAddBudgetViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 4/18/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "A3ExpenseListAddBudgetViewController.h"
#import "UIViewController+A3AppCategory.h"
#import "A3ExpenseListPreferences.h"
#import "A3UIStyle.h"
#import "A3UIKit.h"
#import "CoolButton.h"
#import "A3BarButton.h"
#import "A3TopGradientBackgroundView.h"

static NSString *A3ExpenseListAddBudgetKeyBugdet = @"Bugdet";
static NSString *A3ExpenseListAddBudgetKeyCategory = @"Category";
static NSString *A3ExpenseListAddBudgetKeyPaymentType = @"Type";
static NSString *A3ExpenseListAddBudgetKeyTitle = @"Title";
static NSString *A3ExpenseListAddBudgetKeyDate = @"Date";
static NSString *A3ExpenseListAddBudgetKeyLocation = @"Location";
static NSString *A3ExpenseListAddBudgetKeyNotes = @"Notes";

@interface A3ExpenseListAddBudgetViewController () <QuickDialogEntryElementDelegate, QuickDialogStyleProvider>
@property (nonatomic, strong) A3QuickDialogController *quickDialogController;
@property (nonatomic, strong) A3ExpenseListPreferences *pref;
@end

@implementation A3ExpenseListAddBudgetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		// Custom initialization

		self.title = @"Add Budget";
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

	self.view.backgroundColor = [A3UIStyle contentsBackgroundColor];

	self.quickDialogController.view.frame = self.view.bounds;

	QuickDialogTableView *tableView = self.quickDialogController.quickDialogTableView;

	tableView.backgroundView = nil;
	tableView.backgroundColor = [UIColor clearColor];
	tableView.styleProvider = self;

	CGRect frame = self.view.bounds;
	frame.size.height = 10.0;
	UIView *headerView = [[UIView alloc] initWithFrame:frame];
	headerView.backgroundColor = [UIColor clearColor];
	tableView.tableHeaderView = headerView;

	[self.view addSubview:self.quickDialogController.view];

	frame = self.view.bounds;
	frame.size.height = 10.0;
	A3TopGradientBackgroundView *backgroundView = [[A3TopGradientBackgroundView alloc] initWithFrame:frame];
	[self.view addSubview:backgroundView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (A3QuickDialogController *)quickDialogController {
	if (nil == _quickDialogController) {
		_quickDialogController = [[A3QuickDialogController alloc] initWithRoot:[self configureRootElements]];
	}
	return _quickDialogController;
}

- (UIBarButtonItem *)doneButton {
	A3BarButton *doneButton = [[A3BarButton alloc] initWithFrame:CGRectZero];
	doneButton.bounds = CGRectMake(0.0, 0.0, 52.0, 30.0);
	[doneButton setTitle:@"Done" forState:UIControlStateNormal];
	[doneButton addTarget:self action:@selector(doneButtonAction) forControlEvents:UIControlEventTouchUpInside];

	return [[UIBarButtonItem alloc] initWithCustomView:doneButton];
}

- (void)doneButtonAction {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (QRootElement *)configureRootElements {
	QSection *section = [[QSection alloc] init];
	[section addElement:[self budgetElement]];
	[section addElement:[self categoryElement]];
	[section addElement:[self paymentType]];
	[section addElement:[self showSimpleAdvancedElement]];

	if ([self.pref addBudgetShowAdvanced]) {
		[self insertAdvanedElement];
	}

	QRootElement *rootElement = [[QRootElement alloc] init];
	rootElement.title = @"Add Budget";
	rootElement.grouped = YES;
	[rootElement addSection:section];

	return rootElement;
}

- (QButtonElement *)showSimpleAdvancedElement {
	QButtonElement *element = [[QButtonElement alloc] init];
	element.title = [self.pref addBudgetShowAdvanced] ? @"Simple" : @"Advanced";
	element.onSelected = ^{
		QuickDialogTableView *tableView = self.quickDialogController.quickDialogTableView;
		NSIndexPath *indexPath = [tableView indexForElement:element];
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
			[self insertAdvanedElement];
			[tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];

			[self.pref setAddBudgetShowAdvanced:YES];
		}
	};
	return element;
}

- (void)insertAdvanedElement {
	QSection *sectionZero = [self.quickDialogController.quickDialogTableView.root.sections objectAtIndex:0];
	if ([sectionZero.elements count] != 4) return;

	[sectionZero insertElement:[self titleElement] atIndex:3];
	[sectionZero insertElement:[self dateElement] atIndex:4];
	[sectionZero insertElement:[self locationElement] atIndex:5];
	[sectionZero insertElement:[self notesElement] atIndex:6];
}

- (void)makeItSimple {
	QSection *sectionZero = [self.quickDialogController.quickDialogTableView.root.sections objectAtIndex:0];
	if ([sectionZero.elements count] != 8) return;

	[sectionZero.elements removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 4)] ];
}

- (QEntryElement *)titleElement {
	QEntryElement *element = [[QEntryElement alloc] initWithTitle:@"Title" Value:@"" Placeholder:@"(Optional)"];
	element.key = A3ExpenseListAddBudgetKeyTitle;
	element.delegate = self;
	return element;
}

- (QDateTimeInlineElement *)dateElement {
	QDateTimeInlineElement *element = [[QDateTimeInlineElement alloc] initWithTitle:@"Date" date:[NSDate date]];
	element.key = A3ExpenseListAddBudgetKeyDate;
	element.delegate = self;
	return element;
}

- (QLabelElement *)locationElement {
	QLabelElement *element = [[QLabelElement alloc] initWithTitle:@"Location" Value:@"Current Location"];
	element.key = A3ExpenseListAddBudgetKeyLocation;
	element.onSelected = ^{
	};
	return element;
}

- (QEntryElement *)notesElement {
	QEntryElement *element = [[QEntryElement alloc] initWithTitle:@"Notes" Value:@"" Placeholder:@"(Optional)"];
	element.key = A3ExpenseListAddBudgetKeyNotes;
	element.delegate = self;
	return element;
}

- (QEntryElement *)budgetElement {
	QEntryElement *element = [[QEntryElement alloc] initWithTitle:@"Budget" Value:@"" Placeholder:[self zeroCurrency]];
	element.key = A3ExpenseListAddBudgetKeyBugdet;
	element.delegate = self;
	return element;
}

- (QRadioElement *)categoryElement {
	QRadioElement *element = [[QRadioElement alloc] initWithItems:@[@""] selected:0 title:@"Category"];
	element.key = A3ExpenseListAddBudgetKeyCategory;
	element.delegate = self;
	element.controllerAction = @"selectCategory";
	return element;
}

- (QEntryElement *)paymentType {
	QEntryElement *element = [[QEntryElement alloc] initWithTitle:@"Payment Type" Value:@"Cash" Placeholder:@""];
	element.key = A3ExpenseListAddBudgetKeyPaymentType;
	element.delegate = self;
	return element;
}

#pragma mark - QuickDialogTableViewStyleProvider

- (void)cell:(UITableViewCell *)cell willAppearForElement:(QElement *)element atIndexPath:(NSIndexPath *)indexPath {
	cell.backgroundColor = [A3UIStyle contentsBackgroundColor];

	if ([cell isKindOfClass:[QEntryTableViewCell class]]) {
		cell.textLabel.font = [A3UIStyle fontForTableViewEntryCellLabel];
		cell.textLabel.textColor = [A3UIStyle colorForTableViewCellLabelNormal];

		QEntryTableViewCell *entryCell = (QEntryTableViewCell *) cell;
		entryCell.textField.font = [A3UIStyle fontForTableViewEntryCellTextField];
		entryCell.textField.textAlignment = NSTextAlignmentLeft;

	} else if ([element isKindOfClass:[QButtonElement class]]) {
		cell.textLabel.font = [A3UIStyle fontForTableViewCellLabel];
		cell.textLabel.textColor = [A3UIStyle colorForTableViewCellButton];
	} else {
		cell.textLabel.font = [A3UIStyle fontForTableViewEntryCellLabel];
		cell.textLabel.textColor = [A3UIStyle colorForTableViewCellLabelNormal];
	}
}

- (A3ExpenseListPreferences *)pref {
	if (nil == _pref) {
		_pref = [[A3ExpenseListPreferences alloc] init];
	}
	return _pref;
}

@end
