//
//  A3SalesCalcQuickDialogViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 11/17/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3SalesCalcQuickDialogViewController.h"
#import "A3UIDevice.h"
#import "A3HorizontalBarChartView.h"
#import "A3UserDefaults.h"
#import "SalesCalcHistory.h"
#import "A3AppDelegate.h"
#import "A3UIKit.h"
#import "NSString+conversion.h"
#import "A3HorizontalBarContainerView.h"
#import "UIViewController+A3AppCategory.h"
#import "A3SalesCalcHistoryViewController.h"
#import "SalesCalcHistory+controller.h"
#import "NSManagedObject+Clone.h"
#import "common.h"
#import "A3ActionMenuViewController_iPad.h"

@interface A3SalesCalcQuickDialogViewController () <A3SalesCalcQuickDialogDelegate, A3ActionMenuViewControllerDelegate, A3QuickDialogCellStyleDelegate>

@property (nonatomic, strong) NSArray *keys;
@property (nonatomic, strong) SalesCalcHistory *editingObject;

@end

@implementation A3SalesCalcQuickDialogViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	// Custom initialization
	self = [super initWithNibName:nil bundle:nil];
	if (self) {
		[self addTopGradientLayerToView:self.view position:1.0];

		self.title = @"Sales Calc";

	}
	return self;
}

- (SalesCalcHistory *)editingObject {
	if (_editingObject) return _editingObject;

	NSManagedObjectContext *managedObjectContext = [[A3AppDelegate instance] managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"SalesCalcHistory" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"editing == YES"];
	[fetchRequest setPredicate:predicate];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:NO];
	[fetchRequest setSortDescriptors:@[sortDescriptor]];
	[fetchRequest setFetchLimit:1];
	NSError *error;
	NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if ([fetchedObjects count] == 1) {
		_editingObject = [fetchedObjects objectAtIndex:0];
	} else {
		_editingObject = [NSEntityDescription insertNewObjectForEntityForName:@"SalesCalcHistory" inManagedObjectContext:managedObjectContext];
		[_editingObject fillDefaultValues];
	}

	return _editingObject;
}

- (NSArray *)keys {
	if (nil == _keys) {
		_keys = @[SC_KEY_PRICE, SC_KEY_DISCOUNT, SC_KEY_ADDITIONAL_OFF, SC_KEY_TAX, SC_KEY_NOTES];
	}
	return _keys;
}

- (A3HorizontalBarContainerView *)tableHeaderView {
	if (nil == _tableHeaderView) {
		_tableHeaderView = [[A3HorizontalBarContainerView alloc] initWithFrame:CGRectZero];
	}
	return _tableHeaderView;
}

- (BOOL)addDataToHistory {
	if (![_editingObject hasChanges]) {
		return NO;
	}

	NSManagedObjectContext *managedObjectContext = [[A3AppDelegate instance] managedObjectContext];
	NSError *error;

	SalesCalcHistory *historyObject = (SalesCalcHistory *) [_editingObject cloneInContext:managedObjectContext];
	historyObject.created = [NSDate date];
	historyObject.editing = @NO;

	[managedObjectContext save:&error];

	return YES;
}

- (void)addHistoryWithAlertView {
//	if ([self addDataToHistory]) {
//		[KGDiscreetAlertView showDiscreetAlertWithText:@"Calculation added to History" inView:self.parentViewController.view];
//	}
}

- (QEntryElement *)additionalOffElement {
	A3PercentEntryElement *additionalOff = [[A3PercentEntryElement alloc] initWithTitle:@"Additional Off" Value:self.editingObject.additionalOff Placeholder:@"0%"];
	additionalOff.key = SC_KEY_ADDITIONAL_OFF;
	additionalOff.delegate = self;
	additionalOff.cellStyleDelegate = self;
	additionalOff.height = [self heightForElement:additionalOff];
	return additionalOff;
}

- (QEntryElement *)taxElement {
	A3PercentEntryElement *tax = [[A3PercentEntryElement alloc] initWithTitle:@"Tax" Value:self.editingObject.tax Placeholder:@"0%"];
	tax.key = SC_KEY_TAX;
	tax.delegate = self;
	tax.cellStyleDelegate = self;
	tax.height = [self heightForElement:tax];
	return tax;
}

- (QRootElement *)rootElement {
	self.defaultCurrencyCode = [self userCurrencyCodeForKey:A3SalesCalcDefaultUserCurrencyCode];
	FNLOG(@"User Currency Code: %@", self.defaultCurrencyCode);

	QRootElement *newRoot = [[QRootElement alloc] init];
	newRoot.controllerName = @"A3SalesCalcQuickDialogViewController";
	newRoot.title = @"Sales Calc";
	newRoot.grouped = YES;

	QRadioSection *section0 = [[QRadioSection alloc] initWithItems:@[@"Original Price", @"Sale Price"] selected:self.editingObject.isKnownValueOriginalPrice.boolValue ? 0 : 1 title:@"Select Known Value"];
	section0.key = SC_KEY_KNOWN_VALUE_SECTION;
	QSelectItemElement *section0Row0 = [section0.elements objectAtIndex:0];
	section0Row0.height = self.rowHeight;
	section0Row0.onSelected = ^{
		[self switchKnownPriceWithSelection:0];
	};
	QSelectItemElement *section0Row1 = [section0.elements objectAtIndex:1];
	section0Row1.height = self.rowHeight;
	section0Row1.onSelected = ^{
		[self switchKnownPriceWithSelection:1];
	};
	[newRoot addSection:section0];

	QSection *section1 = [[QSection alloc] init];
	section1.key = SC_KEY_NUMBER_SECTION;
	[self buildNumberSection:section1];
	[newRoot addSection:section1];

	return newRoot;
}

- (void)switchKnownPriceWithSelection:(NSUInteger)selection {
	QRadioSection *radioSection = (QRadioSection *) [self.root sectionWithKey:SC_KEY_KNOWN_VALUE_SECTION];
	radioSection.selected = selection;
	[self.quickDialogTableView reloadData];

	[A3UIKit setUserDefaults:selection == 0 ? @YES : @NO forKey:A3SalesCalcDefaultKnownValueOriginalPrice];
	[self calculateSalePrice];
}


- (void)buildNumberSection:(QSection *)section {
	A3CurrencyEntryElement *price = [[A3CurrencyEntryElement alloc] initWithTitle:@"Price" Value:self.editingObject.price Placeholder:self.zeroCurrency];
	price.key = SC_KEY_PRICE;
	price.delegate = self;
	price.cellStyleDelegate = self;
	[section addElement:price];

	A3PercentEntryElement *discount = [[A3PercentEntryElement alloc] initWithTitle:@"Discount" Value:self.editingObject.discount Placeholder:@"0%"];
	discount.key = SC_KEY_DISCOUNT;
	discount.delegate = self;
	discount.cellStyleDelegate = self;
	[section addElement:discount];

	if (self.editingObject.isAdvanced) {
		[section addElement:[self additionalOffElement]];
		[section addElement:[self taxElement]];
	}

	A3EntryElement *notes = [[A3EntryElement alloc] initWithTitle:@"Notes" Value:self.editingObject.notes Placeholder:@"(Optional)"];
	notes.key = SC_KEY_NOTES;
	notes.delegate = self;
	notes.cellStyleDelegate = self;
	[section addElement:notes];

	NSString *buttonTitle = self.editingObject.isAdvanced ? @"Advanced" : @"Simple";
	A3ButtonElement *simple = [[A3ButtonElement alloc] initWithTitle:buttonTitle];
	simple.key = SC_KEY_SIMPLE_ADVANCED;
	simple.onSelected = ^{
		[self onSimpleAdvanced];
	};
	simple.cellStyleDelegate = self;
	[section addElement:simple];
}

- (void)onSimpleAdvanced {
	A3ButtonElement *element = (A3ButtonElement *) [self.root elementWithKey:SC_KEY_SIMPLE_ADVANCED];
	UITableViewCell *cell = [self.quickDialogTableView cellForElement:element];
	[self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexPathForCell:cell] animated:YES];

	NSUInteger index = 2;
	QSection *section = [self.root.sections objectAtIndex:1];
	NSArray *changedRows = @[[NSIndexPath indexPathForRow:index inSection:1], [NSIndexPath indexPathForRow:index + 1 inSection:1]];
	if (self.editingObject.isAdvanced.boolValue) {
		[section.elements removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, 2)]];
		[self.quickDialogTableView deleteRowsAtIndexPaths:changedRows withRowAnimation:UITableViewRowAnimationBottom];
		element.title = @"Advanced";

		_editingObject.isAdvanced = @NO;
	} else {
		[section insertElement:[self additionalOffElement] atIndex:index];
		[section insertElement:[self taxElement] atIndex:index + 1];
		[self.quickDialogTableView insertRowsAtIndexPaths:changedRows withRowAnimation:UITableViewRowAnimationBottom];
		element.title = @"Simple";

		_editingObject.isAdvanced = @YES;
	}
	cell.textLabel.text = element.title;

	[A3UIKit setUserDefaults:_editingObject.isAdvanced forKey:A3SalesCalcDefaultShowAdvanced];

	[self calculateSalePrice];
}

#pragma mark -- UIViewController
- (void)viewDidLoad {
	[super viewDidLoad];

	[self addToolsButtonWithAction:@selector(onActionButton)];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	self.quickDialogTableView.tableHeaderView = self.tableHeaderView;

	[self calculateSalePrice];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];

	[self addDataToHistory];
}

- (void)onActionButton {
	if (DEVICE_IPAD) {
		[self presentActionMenuWithDelegate:self];
		A3ActionMenuViewController_iPad *viewController = (A3ActionMenuViewController_iPad *) self.actionMenuViewController;
		[viewController setImage:@"t_history" selector:@selector(presentHistoryViewController) atIndex:0];
		[viewController setText:@"History" atIndex:0];
	} else {
		[self presentEmptyActionMenu];
		[self addActionIcon:@"t_history" title:@"History" selector:@selector(presentHistoryViewController) atIndex:0];
		[self addActionIcon:@"t_share" title:@"Share" selector:@selector(shareAction) atIndex:0];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)shareAction {

}

- (void)emailAction {

}

- (void)messageAction {

}

- (void)twitterAction {

}

- (void)facebookAction {

}


- (void)presentHistoryViewController {
	A3SalesCalcHistoryViewController *historyViewController = [[A3SalesCalcHistoryViewController alloc] init];
	historyViewController.delegate = self;

	if (DEVICE_IPAD) {
		A3PaperFoldMenuViewController *paperFoldMenuViewController = [[A3AppDelegate instance] paperFoldMenuViewController];
		[paperFoldMenuViewController presentRightWingWithViewController:historyViewController onClose:^{
		}];
	} else {
		[self.navigationController pushViewController:historyViewController animated:YES];
	}
}

- (void)reloadContentsWithObject:(SalesCalcHistory *)history {
	self.editingObject.editing = @NO;
	self.editingObject.created = [NSDate date];

	history.editing = @YES;

	NSError *error;
	[history.managedObjectContext save:&error];

	_editingObject = history;

	[[NSUserDefaults standardUserDefaults] setObject:_editingObject.isKnownValueOriginalPrice forKey:A3SalesCalcDefaultKnownValueOriginalPrice];
	[[NSUserDefaults standardUserDefaults] setObject:_editingObject.isAdvanced forKey:A3SalesCalcDefaultShowAdvanced];
	[[NSUserDefaults standardUserDefaults] synchronize];

	[self.quickDialogTableView reloadData];

	[self calculateSalePrice];
}

#pragma mark -- QuickDialogStyleProvider

- (void)cell:(UITableViewCell *)cell willAppearForElement:(QElement *)element atIndexPath:(NSIndexPath *)indexPath {
	cell.backgroundColor = [self tableViewBackgroundColor];

	if (indexPath.section == 0) {
		cell.textLabel.font = [self fontForCellLabel];
		if ([element isKindOfClass:[QSelectItemElement class]]) {
			QRadioSection *radioSection = (QRadioSection *)element.parentSection;
			if (radioSection.selected == indexPath.row) {
				cell.textLabel.textColor = [self colorForCellLabelSelected];
			} else {
				cell.textLabel.textColor = [self colorForCellLabelNormal];
			}
		}
	}
}

- (void)sectionHeaderWillAppearForSection:(QSection *)section atIndex:(NSInteger)index {
	if ([section.key isEqualToString:SC_KEY_KNOWN_VALUE_SECTION]) {
		CGRect bounds = self.view.bounds;
		CGFloat height, offsetX, fontSize;
		if (DEVICE_IPAD) {
			height = 44.0;
			offsetX = 64.0;
			fontSize = 24.0;
		} else {
			height = 32.0;
			offsetX = 20.0;
			fontSize = 18.0;
		}
		UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, bounds.size.width, height)];
		UILabel *sectionText = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, 0.0f, bounds.size.width - offsetX * 2.0f, height)];
		sectionText.backgroundColor = [UIColor clearColor];
		sectionText.font = [UIFont boldSystemFontOfSize:fontSize];
		sectionText.textColor = [UIColor blackColor];
		sectionText.text = section.title;
		[headerView addSubview:sectionText];

		section.headerView = headerView;
	}
}

- (BOOL)entryIndexIsForNumbers:(NSUInteger) index {
	return (index >= A3SalesCalcEntryIndexPrice) && (index <= A3SalesCalcEntryIndexTax);
}

#pragma mark -- QEntryElement delegate

- (void)QEntryDidBeginEditingElement:(QEntryElement *)element  andCell:(QEntryTableViewCell *)cell {
	[super QEntryDidBeginEditingElement:element andCell:cell];
}

- (void)QEntryEditingChangedForElement:(QEntryElement *)element  andCell:(QEntryTableViewCell *)cell {
    NSUInteger index = [self.keys indexOfObject:element.key];
	if (index == 0) {
		// price
		element.textValue = [self currencyFormattedString:cell.textField.text];
		self.editingObject.price = element.textValue;
	} else if ([element.key isEqualToString:SC_KEY_NOTES]) {
		self.editingObject.notes = cell.textField.text;
	} else {
		element.textValue = [self percentFormattedString:cell.textField.text];
		[self.editingObject setValue:element.textValue forKey:element.key];
	}

	if ([self entryIndexIsForNumbers:index]) {
		[self calculateSalePrice];
	}
}

- (void)QEntryDidEndEditingElement:(QEntryElement *)element andCell:(QEntryTableViewCell *)cell {
	[super QEntryDidEndEditingElement:element andCell:cell];

	NSUInteger index = [self.keys indexOfObject:element.key];
	if (index == 0) {
		// price
		self.editingObject.price = element.textValue;
	} else {
		element.textValue = cell.textField.text;
		[self.editingObject setValue:element.textValue forKey:element.key];
	}

	if ([self entryIndexIsForNumbers:index]) {
		[self calculateSalePrice];
	}

	[self addHistoryWithAlertView];
}

- (void)reloadPriceElement {
	// Re-assign priceElement textField.
	QEntryElement *priceElement = (QEntryElement *)[self.root elementWithKey:SC_KEY_PRICE];
	float price;
	price = [priceElement.textValue floatValueEx];
	priceElement.textValue = price != 0 ? [self.currencyFormatter stringFromNumber:[NSNumber numberWithDouble:price]] : @"";
	priceElement.placeholder = [self.currencyFormatter stringFromNumber:[NSNumber numberWithDouble:0.0]];
	[self.quickDialogTableView reloadCellForElements:priceElement, nil];
}

- (void)calculateSalePrice {
	QRadioSection *radioSection = (QRadioSection *)[self.root sectionWithKey:SC_KEY_KNOWN_VALUE_SECTION];
	QEntryElement *priceElement = (QEntryElement *)[self.root elementWithKey:SC_KEY_PRICE];
	QEntryElement *discountElement = (QEntryElement *)[self.root elementWithKey:SC_KEY_DISCOUNT];
	QEntryElement *additionalOffElement = (QEntryElement *)[self.root elementWithKey:SC_KEY_ADDITIONAL_OFF];
	QEntryElement *taxElement = (QEntryElement *)[self.root elementWithKey:SC_KEY_TAX];

	float price, originalPrice, salePrice, discount, additionalOff, tax, amountSaved;

	price = [priceElement.textValue floatValueEx];
	discount = [discountElement.textValue floatValueEx];
	if (radioSection.selected == 0) {
		// Know original price, get sale price
		originalPrice = price;

		if (!self.editingObject.isAdvanced) {
			salePrice = originalPrice * (1.0 - discount / 100.0);
		} else {
			additionalOff = [additionalOffElement.textValue floatValueEx];
			tax = [taxElement.textValue floatValueEx];
			salePrice = originalPrice * (1.0 - discount / 100.0) * (1.0 - additionalOff / 100.0);
			salePrice -= (salePrice * tax / 100);
		}
	} else {
		// Know sale price, get original price
		salePrice = price;
		if (!self.editingObject.isAdvanced) {
			originalPrice = salePrice / (1.0 - discount / 100.0);
		} else {
			additionalOff = [additionalOffElement.textValue floatValueEx];
			tax = [taxElement.textValue floatValueEx];
			float withoutTax = salePrice / (1.0 + tax / 100.0);
			float withoutAdditionalOff = withoutTax / (1.0 - additionalOff / 100.0);
			originalPrice = withoutAdditionalOff / (1.0 - discount / 100.0);
		}
	}

	amountSaved = originalPrice - salePrice;

	self.editingObject.salePrice = [self.currencyFormatter stringFromNumber:[NSNumber numberWithDouble:salePrice]];
	self.editingObject.amountSaved = [self.currencyFormatter stringFromNumber:[NSNumber numberWithDouble:amountSaved]];
	self.editingObject.originalPrice = [self.currencyFormatter stringFromNumber:[NSNumber numberWithDouble:originalPrice]];

	self.tableHeaderView.chartLeftValueLabel.text = self.editingObject.salePrice;
	self.tableHeaderView.chartRightValueLabel.text = self.editingObject.amountSaved;
	[self.tableHeaderView setBottomLabelText:self.editingObject.originalPrice];

	self.tableHeaderView.percentBarChart.leftValue = salePrice;
	self.tableHeaderView.percentBarChart.rightValue = amountSaved;
	[self.tableHeaderView.percentBarChart setNeedsDisplay];
}

- (void)presentCurrencySelectViewController {
	A3CurrencySelectViewController *viewController = [[A3CurrencySelectViewController alloc] initWithNibName:nil bundle:nil];
	CGRect frame = [A3UIDevice deviceOrientationIsPortrait] ? CGRectMake(0.0, 0.0, 320.0, 1004.0) : CGRectMake(0.0, 0.0, 320.0, 748.0);
	viewController.view.frame = frame;
	viewController.delegate = self;

	if (DEVICE_IPAD) {
		[[[A3AppDelegate instance] paperFoldMenuViewController] presentRightWingWithViewController:viewController onClose:^{
		}];
	} else {
		[self.navigationController pushViewController:viewController animated:YES];
	}
}

- (void)handleBigButton1 {
	if ([self.editingElement.key isEqualToString:SC_KEY_PRICE]) {
		QEntryTableViewCell *cell = (QEntryTableViewCell *)[self.quickDialogTableView cellForElement:self.editingElement];
		[cell.textField resignFirstResponder];

		[self presentCurrencySelectViewController];
	}
}

- (void)currencySelected:(NSString *)selectedCurrencyCode {
	[[[A3AppDelegate instance] paperFoldMenuViewController] removeRightWingViewController];

	[A3UIKit setUserDefaults:selectedCurrencyCode forKey:A3SalesCalcDefaultUserCurrencyCode];
	self.defaultCurrencyCode = [self userCurrencyCodeForKey:A3SalesCalcDefaultUserCurrencyCode];
	self.currencyFormatter = nil;

	// Now translate existing values with selected currency.
	A3CurrencyEntryElement *price = (A3CurrencyEntryElement *) [self.quickDialogTableView.root elementWithKey:SC_KEY_PRICE];
	price.textValue = [self.currencyFormatter stringFromNumber:@([price.textValue floatValueEx])];
	self.editingObject.price = price.textValue;

	[self.quickDialogTableView reloadData];
	[self calculateSalePrice];
}

@end
