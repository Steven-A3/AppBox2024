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
#import "EKKeyboardAvoidingScrollViewManager.h"
#import "A3UserDefaults.h"
#import "SalesCalcHistory.h"
#import "A3AppDelegate.h"
#import "KGDiscreetAlertView.h"
#import "A3UIKit.h"
#import "A3UIStyle.h"
#import "NSString+conversion.h"
#import "A3HorizontalBarContainerView.h"
#import "UIViewController+A3AppCategory.h"

@interface A3SalesCalcQuickDialogViewController ()

@property (nonatomic, strong) NSArray *keys;
@property (nonatomic) A3SalesCalculatorType calculatorType;
@property (nonatomic) CGFloat rowHeight;

@end


@implementation A3SalesCalcQuickDialogViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	// Custom initialization
	self = [super initWithNibName:nil bundle:nil];
	if (self) {
		if (DEVICE_IPAD) {
			_rowHeight = 58.0;
		} else {
			_rowHeight = 44.0;
		}

		[self buildRoot];
	}
	return self;
}

- (void)assignRowHeightToElementInSection:(QSection *)section {
	for (QElement *element in section.elements) {
		element.height = _rowHeight;
	}
}

- (A3SalesCalculatorType)calculatorType {
	NSNumber *storedValue = [[NSUserDefaults standardUserDefaults] objectForKey:A3SalesCalcDefaultCalculatorType];
	if (nil == storedValue) {
		_calculatorType = A3SalesCalculatorTypeAdvanced;
	} else {
		_calculatorType = (A3SalesCalculatorType) [storedValue unsignedIntegerValue];
	}
	return _calculatorType;
}

- (A3SalesCalcKnownValue)knownValue {
	NSNumber *storedValue = [[NSUserDefaults standardUserDefaults] objectForKey:A3SalesCalcDefaultSavedKnownValue];
	if (nil == storedValue) {
		return A3SalesCalcKnownValueOriginalPrice;
	}
	return (A3SalesCalcKnownValue) [storedValue unsignedIntegerValue];
}

- (NSString *)savedValueForPrice {
	return [self getUserDefaultForKey:A3SalesCalcDefaultSavedValuePrice];
}

- (NSString *)savedValueForDiscount {
	return [self getUserDefaultForKey:A3SalesCalcDefaultSavedValueDiscount];
}

- (NSString *)savedValueForAdditionalOff {
	return [self getUserDefaultForKey:A3SalesCalcDefaultSavedValueAdditionalOff];
}

- (NSString *)savedValueForTax {
	return [self getUserDefaultForKey:A3SalesCalcDefaultSavedValueTax];
}

- (NSString *)savedValueForNotes {
	return [self getUserDefaultForKey:A3SalesCalcDefaultSavedValueNotes];
}

- (NSString *)getUserDefaultForKey:(NSString *)key {
	NSString *defaultValue;
	defaultValue = [[NSUserDefaults standardUserDefaults] objectForKey:key];
	return nil == defaultValue ? @"" : defaultValue;
}

- (NSArray *)keys {
	if (nil == _keys) {
		_keys = @[SC_KEY_PRICE, SC_KEY_DISCOUNT, SC_KEY_ADDITIONAL_OFF, SC_KEY_TAX, SC_KEY_NOTES];
	}
	return _keys;
}

- (BOOL)isOriginalPrice {
	QRadioSection *radioSection = (QRadioSection *)[self.root sectionWithKey:SC_KEY_KNOWN_VALUE_SECTION];
	return (radioSection.selected == A3SalesCalcKnownValueOriginalPrice);
}

- (A3HorizontalBarContainerView *)tableHeaderView {
	if (nil == _tableHeaderView) {
		_tableHeaderView = [[A3HorizontalBarContainerView alloc] initWithFrame:CGRectZero];
	}
	return _tableHeaderView;
}

- (NSString *)discountString {
	QEntryElement *entryElement;
	entryElement = (QEntryElement *)[self.root elementWithKey:SC_KEY_DISCOUNT];
	return entryElement.textValue;
}

- (NSString *)additionalOffString {
	QEntryElement *entryElement;
	entryElement = (QEntryElement *)[self.root elementWithKey:SC_KEY_ADDITIONAL_OFF];
	return entryElement.textValue;
}

- (NSString *)taxString {
	QEntryElement *entryElement;
	entryElement = (QEntryElement *)[self.root elementWithKey:SC_KEY_TAX];
	return entryElement.textValue;
}

- (NSString *)notesString {
	QEntryElement *entryElement;
	entryElement = (QEntryElement *)[self.root elementWithKey:SC_KEY_NOTES];
	return entryElement.textValue;
}

- (BOOL)addDataToHistory {
	NSManagedObjectContext *managedObjectContext = [[A3AppDelegate instance] managedObjectContext];

	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"SalesCalcHistory" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdDate" ascending:NO];
	[fetchRequest setSortDescriptors:@[sortDescriptor]];
	[fetchRequest setFetchLimit:1];
	NSError *error;
	NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];

	QEntryElement *priceElement = (QEntryElement *)[self.root elementWithKey:SC_KEY_PRICE];
	QEntryElement *discountElement = (QEntryElement *)[self.root elementWithKey:SC_KEY_DISCOUNT];

	float price, discount;

	price = [priceElement.textValue floatValueEx];
	discount = [discountElement.textValue floatValueEx];

	if (price == 0.0 || discount == 0.0)
		return NO;

	BOOL isOriginalPrice = YES, isAdvanced;
	isAdvanced = _calculatorType == A3SalesCalculatorTypeAdvanced;

	if ([fetchedObjects count]) {
		SalesCalcHistory *lastHistory = [fetchedObjects objectAtIndex:0];

		isOriginalPrice = [self isOriginalPrice];

		if (lastHistory && [lastHistory isKindOfClass:[SalesCalcHistory class]]) {
			if ((lastHistory.isOriginalPrice == isOriginalPrice) &&
					(lastHistory.isAdvanced == isAdvanced) &&
					[lastHistory.salePrice isEqualToString:self.tableHeaderView.chartLeftValueLabel.text] &&
					[lastHistory.originalPrice isEqualToString:self.tableHeaderView.bottomValueLabel.text] &&
					[lastHistory.amountSaved isEqualToString:self.tableHeaderView.chartRightValueLabel.text] &&
					[lastHistory.discount isEqualToString:[self discountString]] &&
					[lastHistory.additionaloff isEqualToString:[self additionalOffString]] &&
					[lastHistory.tax isEqualToString:[self taxString]] &&
					[lastHistory.notes isEqualToString:[self notesString]] )
				return NO;
		}
	}

	SalesCalcHistory *history = [NSEntityDescription insertNewObjectForEntityForName:@"SalesCalcHistory" inManagedObjectContext:managedObjectContext];

	history.isOriginalPrice = isOriginalPrice;
	history.isAdvanced = isAdvanced;
	history.createdDate = [[NSDate date] timeIntervalSinceReferenceDate];

	history.salePrice = self.tableHeaderView.chartLeftValueLabel.text;
	history.originalPrice = self.tableHeaderView.bottomValueLabel.text;
	history.amountSaved = self.tableHeaderView.chartRightValueLabel.text;
	history.discount = [self discountString];
	history.additionaloff = [self additionalOffString];
	history.tax = [self taxString];
	history.notes = [self notesString];

	[managedObjectContext save:&error];

	return YES;
}

- (void)addHistoryWithAlertView {
	if ([self addDataToHistory]) {
		[KGDiscreetAlertView showDiscreetAlertWithText:@"Calculation added to History" inView:self.parentViewController.view];
	}
}

- (QEntryElement *)additionalOffElement {
	QEntryElement *additionalOff = [[QEntryElement alloc] initWithTitle:@"Additional Off:" Value:[self savedValueForAdditionalOff] Placeholder:@"0%"];
	additionalOff.key = SC_KEY_ADDITIONAL_OFF;
	additionalOff.height = _rowHeight;
	additionalOff.delegate = self;
	return additionalOff;
}

- (QEntryElement *)taxElement {
	QEntryElement *tax = [[QEntryElement alloc] initWithTitle:@"Tax:" Value:[self savedValueForTax] Placeholder:@"0%"];
	tax.height = _rowHeight;
	tax.key = SC_KEY_TAX;
	tax.delegate = self;
	return tax;
}

- (void)buildRoot {
	QRootElement *newRoot = [[QRootElement alloc] init];
	newRoot.controllerName = @"A3SalesCalcQuickDialogViewController";
	newRoot.title = @"Sales Calc";
	newRoot.grouped = YES;

	QRadioSection *section0 = [[QRadioSection alloc] initWithItems:@[@"Original Price", @"Sale Price"] selected:[self knownValue] title:@"Select Known Value"];
	section0.key = SC_KEY_KNOWN_VALUE_SECTION;
	QSelectItemElement *section0Row0 = [section0.elements objectAtIndex:0];
	section0Row0.controllerAction = @"onSelectOriginalPrice:";
	QSelectItemElement *section0Row1 = [section0.elements objectAtIndex:1];
	section0Row1.controllerAction = @"onSelectSalePrice:";
	[self assignRowHeightToElementInSection:section0];
	[newRoot addSection:section0];

	QSection *section1 = [[QSection alloc] init];
	section1.key = SC_KEY_NUMBER_SECTION;
	[self buildNumberSection:section1];
	[newRoot addSection:section1];

	self.root = newRoot;
}

- (void)buildNumberSection:(QSection *)section {
	QEntryElement *price = [[QEntryElement alloc] initWithTitle:@"Price:" Value:[self savedValueForPrice] Placeholder:@"$0.00 USD"];
	price.key = SC_KEY_PRICE;
	price.delegate = self;
	[section addElement:price];

	QEntryElement *discount = [[QEntryElement alloc] initWithTitle:@"Discount:" Value:[self savedValueForDiscount] Placeholder:@"0%"];
	discount.key = SC_KEY_DISCOUNT;
	discount.delegate = self;
	[section addElement:discount];

	if (self.calculatorType == A3SalesCalculatorTypeAdvanced) {
		[section addElement:[self additionalOffElement]];
		[section addElement:[self taxElement]];
	}

	QEntryElement *notes = [[QEntryElement alloc] initWithTitle:@"Notes" Value:[self savedValueForNotes] Placeholder:@"(Optional)"];
	notes.key = SC_KEY_NOTES;
	notes.delegate = self;
	[section addElement:notes];

	NSString *buttonTitle = _calculatorType == A3SalesCalculatorTypeAdvanced ? @"Simple" : @"Advanced";
	QButtonElement *simple = [[QButtonElement alloc] initWithTitle:buttonTitle];
	[simple setControllerAction:@"onSimpleAdvanced:"];
	[section addElement:simple];

	[self assignRowHeightToElementInSection:section];
}

- (void)onSimpleAdvanced:(QButtonElement *)element {
	UITableViewCell *cell = [self.quickDialogTableView cellForElement:element];
	[self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexPathForCell:cell] animated:YES];

	NSUInteger index = 2;
	QSection *section = [self.root.sections objectAtIndex:1];
	NSArray *changedRows = @[[NSIndexPath indexPathForRow:index inSection:1], [NSIndexPath indexPathForRow:index + 1 inSection:1]];
	if (_calculatorType == A3SalesCalculatorTypeAdvanced) {

		[section.elements removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, 2)]];
		[self.quickDialogTableView deleteRowsAtIndexPaths:changedRows withRowAnimation:UITableViewRowAnimationBottom];
		element.title = @"Advanced";

		_calculatorType = A3SalesCalculatorTypeSimple;
	} else {
		[section insertElement:[self additionalOffElement] atIndex:index];
		[section insertElement:[self taxElement] atIndex:index + 1];
		[self.quickDialogTableView insertRowsAtIndexPaths:changedRows withRowAnimation:UITableViewRowAnimationBottom];
		element.title = @"Simple";

		_calculatorType = A3SalesCalculatorTypeAdvanced;
	}
	cell.textLabel.text = element.title;

	[A3UIKit setUserDefaults:[NSNumber numberWithUnsignedInteger:_calculatorType] forKey:A3SalesCalcDefaultCalculatorType];

	[self calculateSalePrice];
}

#pragma mark -- Override UIViewController

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	self.quickDialogTableView.styleProvider = self;
	self.quickDialogTableView.backgroundView = nil;
	self.quickDialogTableView.backgroundColor = [A3UIStyle contentsBackgroundColor];

	self.quickDialogTableView.tableHeaderView = self.tableHeaderView;

	[self calculateSalePrice];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];

	[self addDataToHistory];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- QuickDialogStyleProvider

- (void)cell:(UITableViewCell *)cell willAppearForElement:(QElement *)element atIndexPath:(NSIndexPath *)indexPath {
	cell.backgroundColor = [A3UIStyle contentsBackgroundColor];

	switch (indexPath.section) {
		case 0:
			cell.textLabel.font = [A3UIStyle fontForTableViewCellLabel];
			if ([element.parentSection isKindOfClass:[QRadioSection class]]) {
				QRadioSection *radioSection = (QRadioSection *)element.parentSection;
				if (radioSection.selected == indexPath.row) {
					cell.textLabel.textColor = [A3UIStyle colorForTableViewCellLabelSelected];
				} else {
					cell.textLabel.textColor = [A3UIStyle colorForTableViewCellLabelNormal];
				}
			}
			break;
		case 1:
			if ([element isKindOfClass:[QButtonElement class]]) {
				cell.textLabel.font = [A3UIStyle fontForTableViewEntryCellTextField];
				cell.textLabel.textColor = [A3UIStyle colorForTableViewCellButton];
			} else {
				cell.textLabel.font = [A3UIStyle fontForTableViewEntryCellLabel];
				cell.textLabel.textColor = [A3UIStyle colorForTableViewCellLabelNormal];
			}
			if ([cell isKindOfClass:[QEntryTableViewCell class]]) {
				QEntryTableViewCell *entryTableViewCell = (QEntryTableViewCell *)cell;
				[entryTableViewCell.textField setFont:[A3UIStyle fontForTableViewEntryCellTextField]];
				entryTableViewCell.textField.textAlignment = NSTextAlignmentLeft;
			}
			break;
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

- (NSString *)currencyFormattedString:(NSString *)source {
	if ([source floatValue] == 0.0) return @"";
	return [self.currencyNumberFormatter stringFromNumber:[NSNumber numberWithFloat:[source floatValue]]];
}

- (NSString *)percentFormattedString:(NSString *)source {
	if ([source floatValue] == 0.0) return @"";
	return [self.percentNumberFormatter stringFromNumber:[NSNumber numberWithFloat:[source floatValue] / 100.0]];
}

- (void)QEntryDidBeginEditingElement:(QEntryElement *)element  andCell:(QEntryTableViewCell *)cell {
    cell.backgroundColor = [UIColor whiteColor];
    
	NSUInteger index = [self.keys indexOfObject:element.key];

	self.editingElement = element;

	if ([self entryIndexIsForNumbers:index]) {
		cell.textField.inputView = self.numberKeyboardViewController.view;
		self.numberKeyboardViewController.keyInputDelegate = cell.textField;
		self.self.numberKeyboardViewController.entryTableViewCell = cell;
		if ([element.key isEqualToString:SC_KEY_PRICE]) {
			self.numberKeyboardViewController.currencyCode = [self defaultCurrencyCode];
			[self.numberKeyboardViewController setKeyboardType:A3NumberKeyboardTypeCurrency];
		} else {
			[self.numberKeyboardViewController setKeyboardType:A3NumberKeyboardTypePercent];
		}
		NSNumberFormatter *decimalStyleFormatter = [[NSNumberFormatter alloc] init];
		[decimalStyleFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[decimalStyleFormatter setUsesGroupingSeparator:NO];

		float value = [cell.textField.text floatValueEx];
		if (value != 0.0) {
			cell.textField.text = [decimalStyleFormatter stringFromNumber:[NSNumber numberWithDouble:value]];
		} else {
			cell.textField.text = @"";
		}
	}
	cell.textField.inputAccessoryView = nil;
}

- (void)QEntryEditingChangedForElement:(QEntryElement *)element  andCell:(QEntryTableViewCell *)cell {
    NSUInteger index = [self.keys indexOfObject:element.key];
	if (index == 0) {
		// price
		element.textValue = [self currencyFormattedString:cell.textField.text];
		[A3UIKit setUserDefaults:element.textValue forKey:A3SalesCalcDefaultSavedValuePrice];
	} else if ([element.key isEqualToString:SC_KEY_NOTES]) {
		[A3UIKit setUserDefaults:cell.textField.text forKey:A3SalesCalcDefaultSavedValueNotes];
	} else {
		element.textValue = [self percentFormattedString:cell.textField.text];
		switch (index) {
			case 1:
				// discount percent
				[A3UIKit setUserDefaults:element.textValue forKey:A3SalesCalcDefaultSavedValueDiscount];
				break;
			case 2:
				// Additional discount percent
				[A3UIKit setUserDefaults:element.textValue forKey:A3SalesCalcDefaultSavedValueAdditionalOff];
				break;
			case 3:
				// Tax
				[A3UIKit setUserDefaults:element.textValue forKey:A3SalesCalcDefaultSavedValueTax];
				break;
		}
	}

	if ([self entryIndexIsForNumbers:index]) {
		[self calculateSalePrice];
	}
}

- (void)QEntryDidEndEditingElement:(QEntryElement *)element andCell:(QEntryTableViewCell *)cell {
	cell.backgroundColor = [A3UIStyle contentsBackgroundColor];

	self.editingElement = nil;

	NSUInteger index = [self.keys indexOfObject:element.key];
	if (index == 0) {
		// price
		element.textValue = [self currencyFormattedString:cell.textField.text];
		cell.textField.text = element.textValue;
		[A3UIKit setUserDefaults:A3SalesCalcDefaultSavedValuePrice forKey:element.textValue];
	} else if ([element.key isEqualToString:SC_KEY_NOTES]) {
		element.textValue = cell.textField.text;
		[A3UIKit setUserDefaults:element.textValue forKey:A3SalesCalcDefaultSavedValueNotes];
	} else {
		element.textValue = [self percentFormattedString:cell.textField.text];
		cell.textField.text = element.textValue;
		switch (index) {
			case 1:
				// discount percent
				[A3UIKit setUserDefaults:element.textValue forKey:A3SalesCalcDefaultSavedValueDiscount];
				break;
			case 2:
				// Additional discount percent
				[A3UIKit setUserDefaults:element.textValue forKey:A3SalesCalcDefaultSavedValueAdditionalOff];
				break;
			case 3:
				// Tax
				[A3UIKit setUserDefaults:element.textValue forKey:A3SalesCalcDefaultSavedValueTax];
				break;
			case 4:
				// Notes
				[A3UIKit setUserDefaults:element.textValue forKey:A3SalesCalcDefaultSavedValueNotes];
				break;
		}
	}

	if ([self entryIndexIsForNumbers:index]) {
		[self calculateSalePrice];
	}

	[self addHistoryWithAlertView];
}

- (void)onSelectOriginalPrice:(QSelectItemElement *)selectItemElement {
	QRadioSection *parentSection = (QRadioSection *)selectItemElement.parentSection;
	parentSection.selected = 0;
	[self.quickDialogTableView reloadData];

	[A3UIKit setUserDefaults:[NSNumber numberWithUnsignedInteger:A3SalesCalcKnownValueOriginalPrice] forKey:A3SalesCalcDefaultSavedKnownValue];
	[self calculateSalePrice];
}

- (void)onSelectSalePrice:(QSelectItemElement *)selectItemElement {
	QRadioSection *parentSection = (QRadioSection *)selectItemElement.parentSection;
	parentSection.selected = 1;
	[self.quickDialogTableView reloadData];

	[A3UIKit setUserDefaults:[NSNumber numberWithUnsignedInteger:A3SalesCaleKnownValueSalePrice] forKey:A3SalesCalcDefaultSavedKnownValue];
	[self calculateSalePrice];
}

- (void)reloadPriceElement {
	// Re-assign priceElement textField.
	QEntryElement *priceElement = (QEntryElement *)[self.root elementWithKey:SC_KEY_PRICE];
	float price;
	price = [priceElement.textValue floatValueEx];
	priceElement.textValue = price != 0 ? [self.currencyNumberFormatter stringFromNumber:[NSNumber numberWithDouble:price]] : @"";
	priceElement.placeholder = [self.currencyNumberFormatter stringFromNumber:[NSNumber numberWithDouble:0.0]];
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

		if (self.calculatorType == A3SalesCalculatorTypeSimple) {
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
		if (self.calculatorType == A3SalesCalculatorTypeSimple) {
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

	self.tableHeaderView.chartLeftValueLabel.text = [self.currencyNumberFormatter stringFromNumber:[NSNumber numberWithDouble:salePrice]];
	self.tableHeaderView.chartRightValueLabel.text = [self.currencyNumberFormatter stringFromNumber:[NSNumber numberWithDouble:amountSaved]];
	[self.tableHeaderView setBottomLabelText:[self.currencyNumberFormatter stringFromNumber:[NSNumber numberWithDouble:originalPrice]]];

	self.tableHeaderView.percentBarChart.leftValue = salePrice;
	self.tableHeaderView.percentBarChart.rightValue = amountSaved;
	[self.tableHeaderView.percentBarChart setNeedsDisplay];
}

- (void)applyCurrentContentsWithSalesCalcHistory:(SalesCalcHistory *)history {
	_calculatorType = history.isAdvanced ? A3SalesCalculatorTypeAdvanced : A3SalesCalculatorTypeSimple;
	[A3UIKit setUserDefaults:[NSNumber numberWithUnsignedInteger:_calculatorType] forKey:A3SalesCalcDefaultCalculatorType];

	[A3UIKit setUserDefaults:[NSNumber numberWithUnsignedInteger:history.isOriginalPrice ? A3SalesCalcKnownValueOriginalPrice : A3SalesCaleKnownValueSalePrice] forKey:A3SalesCalcDefaultSavedKnownValue];
	[A3UIKit setUserDefaults:history.isOriginalPrice ? history.originalPrice : history.salePrice forKey:A3SalesCalcDefaultSavedValuePrice];
	[A3UIKit setUserDefaults:history.discount forKey:A3SalesCalcDefaultSavedValueDiscount];
	[A3UIKit setUserDefaults:history.additionaloff forKey:A3SalesCalcDefaultSavedValueAdditionalOff];
	[A3UIKit setUserDefaults:history.tax forKey:A3SalesCalcDefaultSavedValueTax];
	[A3UIKit setUserDefaults:history.notes forKey:A3SalesCalcDefaultSavedValueNotes];

	[self calculateSalePrice];
	[self reloadPriceElement];
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
	[A3UIKit setUserDefaults:selectedCurrencyCode forKey:A3SalesCalcDefaultCurrencyCode];

	[[[A3AppDelegate instance] paperFoldMenuViewController] removeRightWingViewController];

	self.currencyNumberFormatter = nil;
	[self calculateSalePrice];
	[self reloadPriceElement];
}

@end
