//
//  A3SalesCalcQuickDialogViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 11/17/12.
//  Copyright (c) 2012 ALLABOUTAPPS. All rights reserved.
//

#import "A3SalesCalcQuickDialogViewController.h"
#import "CommonUIDefinitions.h"
#import "A3UIDevice.h"
#import "A3HorizontalBarChartView.h"
#import "EKKeyboardAvoidingScrollViewManager.h"
#import "A3UserDefaults.h"
#import "SalesCalcHistory.h"
#import "A3AppDelegate.h"
#import "A3Categories.h"
#import "KGDiscreetAlertView.h"
#import "A3UIKit.h"
#import "A3UIStyle.h"

typedef NS_ENUM(NSUInteger, A3SalesCalculatorType) {
	A3SalesCalculatorTypeSimple = 1,
	A3SalesCalculatorTypeAdvanced
};

typedef NS_ENUM(NSUInteger, A3SalesCalcEntryItemIndex) {
	A3SalesCalcEntryIndexPrice = 0,
	A3SalesCalcEntryIndexDiscount,
	A3SalesCalcEntryIndexAdditionalOff,
	A3SalesCalcEntryIndexTax,
	A3SalesCalcEntryIndexNotes,
};

typedef NS_ENUM(NSUInteger, A3SalesCalcKnownValue) {
	A3SalesCalcKnownValueOriginalPrice = 0,
	A3SalesCaleKnownValueSalePrice,
};

@interface A3SalesCalcQuickDialogViewController ()

@property (nonatomic, strong) A3NumberKeyboardViewController *keyboardViewController;
@property (nonatomic, weak) QEntryElement *editingElement;
@property (nonatomic, strong) NSArray *keys;
@property (nonatomic, strong) A3HorizontalBarChartView *percentBarChart;
@property (nonatomic, strong) UILabel *originalPriceLabel, *originalPriceValueLabel;
@property (nonatomic, strong) UILabel *salePriceValueLabel, *amountSavedValueLabel;
@property (nonatomic) A3SalesCalculatorType calculatorType;
@property (nonatomic) CGFloat rightMargin;
@property (nonatomic, strong) NSNumberFormatter *currencyNumberFormatter, *percentNumberFormatter;

@end

#define	SC_KEY_PRICE				@"PRICE"
#define SC_KEY_DISCOUNT				@"DISCOUNT"
#define SC_KEY_ADDITIONAL_OFF		@"ADDITIONAL_OFF"
#define SC_KEY_TAX					@"TAX"
#define SC_KEY_NOTES				@"NOTES"
#define SC_KEY_KNOWN_VALUE_SECTION	@"KNOWN_VALUE_SECTION"
#define SC_KEY_NUMBER_SECTION		@"NUMBERS_SECTION"

@implementation A3SalesCalcQuickDialogViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	// Custom initialization
	self = [super initWithNibName:nil bundle:nil];
	if (self) {
		[self buildRoot];
	}
	return self;
}

- (NSString *)defaultCurrencyCode {
	NSString *code = [[NSUserDefaults standardUserDefaults] objectForKey:A3SalesCalcDefaultCurrencyCode];
	if (![code length]) {
		NSLocale *locale = [NSLocale currentLocale];
		code = [locale objectForKey:NSLocaleCurrencyCode];
		[[NSUserDefaults standardUserDefaults] setObject:code forKey:A3SalesCalcDefaultCurrencyCode];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	return code;
}

- (NSNumberFormatter *)currencyNumberFormatter {
	if (nil == _currencyNumberFormatter) {
        _currencyNumberFormatter = [A3UIKit currencyNumberFormatter];
		[_currencyNumberFormatter setCurrencyCode:[self defaultCurrencyCode]];
	}
	return _currencyNumberFormatter;
}

- (NSNumberFormatter *)percentNumberFormatter {
	if (nil == _percentNumberFormatter) {
		_percentNumberFormatter = [A3UIKit percentNumberFormatter];
	}
	return _percentNumberFormatter;
}

- (void)assignRowHeightToElementInSection:(QSection *)section {
	CGFloat rowHeight = 58.0f;
	for (QElement *element in section.elements) {
		element.height = rowHeight;
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

- (void)viewDidLoad {
	[super viewDidLoad];

	self.view.backgroundColor = [UIColor clearColor];

	_rightMargin = 44.0 + 10.0;
	_keys = @[SC_KEY_PRICE, SC_KEY_DISCOUNT, SC_KEY_ADDITIONAL_OFF, SC_KEY_TAX, SC_KEY_NOTES];

	UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, APP_VIEW_WIDTH, 120.0f)];
	CGFloat offsetX = 44.0f, offsetY = 38.0f;
	CGFloat chartHeight = 44.0f;
	CGFloat chartWidth = APP_VIEW_WIDTH - offsetX * 2.0f;
	CGFloat labelHeight = 23.0f;
	UIColor *chartLabelColor = [UIColor colorWithRed:73.0f/255.0f green:74.0f/255.0f blue:73.0f/255.0f alpha:1.0f];
	UIFont *chartLabelFont = [UIFont boldSystemFontOfSize:18.0f];

	UILabel *labelLeftTop = [[UILabel alloc] initWithFrame:CGRectMake(offsetX + chartHeight / 2.0f, 12.0f, chartWidth / 2.0f - chartHeight / 2.0f, labelHeight)];
	labelLeftTop.backgroundColor = [UIColor clearColor];
	labelLeftTop.font = chartLabelFont;
	labelLeftTop.textColor = chartLabelColor;
	labelLeftTop.text = @"Sale Price";
	[tableHeaderView addSubview:labelLeftTop];

	UILabel *labelRightTop = [[UILabel alloc] initWithFrame:CGRectMake(offsetX + chartWidth / 2.0f, 12.0f, chartWidth / 2.0f - chartHeight/ 2.0f, labelHeight)];
	labelRightTop.backgroundColor = [UIColor clearColor];
	labelRightTop.font = chartLabelFont;
	labelRightTop.textColor = chartLabelColor;
	labelRightTop.textAlignment = NSTextAlignmentRight;
	labelRightTop.text = @"Amount Saved";
	[tableHeaderView addSubview:labelRightTop];

	_originalPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, offsetY + chartHeight + 5.0f, chartWidth - chartHeight / 2.0f, labelHeight)];
	_originalPriceLabel.backgroundColor = [UIColor clearColor];
	_originalPriceLabel.font = chartLabelFont;
	_originalPriceLabel.textColor = chartLabelColor;
	_originalPriceLabel.textAlignment = NSTextAlignmentRight;
	_originalPriceLabel.text = @"Original Price";
	[tableHeaderView addSubview:_originalPriceLabel];

	_originalPriceValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(APP_VIEW_WIDTH - _rightMargin - 200.0, offsetY + chartHeight + 5.0, 200.0, labelHeight)];
	_originalPriceValueLabel.backgroundColor = [UIColor clearColor];
	_originalPriceValueLabel.font = [UIFont boldSystemFontOfSize:20.0];
	_originalPriceValueLabel.textColor = chartLabelColor;
	_originalPriceValueLabel.textAlignment = NSTextAlignmentRight;
	[tableHeaderView addSubview:_originalPriceValueLabel];

	_percentBarChart = [[A3HorizontalBarChartView alloc] initWithFrame:CGRectMake(offsetX, offsetY, APP_VIEW_WIDTH - offsetX * 2.0f, chartHeight)];
	[tableHeaderView addSubview:_percentBarChart];

	_salePriceValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetX + 10.0, offsetY, 200.0, chartHeight)];
	_salePriceValueLabel.backgroundColor = [UIColor clearColor];
	_salePriceValueLabel.textColor = [UIColor whiteColor];
	_salePriceValueLabel.font = [UIFont boldSystemFontOfSize:22.0];
	_salePriceValueLabel.textAlignment = NSTextAlignmentLeft;
	[tableHeaderView addSubview:_salePriceValueLabel];

	_amountSavedValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(APP_VIEW_WIDTH - _rightMargin - 200.0, offsetY, 200.0, chartHeight)];
	_amountSavedValueLabel.backgroundColor = [UIColor clearColor];
	_amountSavedValueLabel.textColor = [UIColor whiteColor];
	_amountSavedValueLabel.font = [UIFont boldSystemFontOfSize:22.0];
	_amountSavedValueLabel.textAlignment = NSTextAlignmentRight;
	[tableHeaderView addSubview:_amountSavedValueLabel];

	self.quickDialogTableView.tableHeaderView = tableHeaderView;
	self.quickDialogTableView.styleProvider = self;
	self.quickDialogTableView.backgroundView = nil;
	self.quickDialogTableView.backgroundColor = [A3UIStyle contentsBackgroundColor];
}

- (BOOL)isOriginalPrice {
	QRadioSection *radioSection = (QRadioSection *)[self.root sectionWithKey:SC_KEY_KNOWN_VALUE_SECTION];
	return (radioSection.selected == A3SalesCalcKnownValueOriginalPrice);
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
					[lastHistory.salePrice isEqualToString:self.salePriceValueLabel.text] &&
					[lastHistory.originalPrice isEqualToString:self.originalPriceValueLabel.text] &&
					[lastHistory.amountSaved isEqualToString:self.amountSavedValueLabel.text] &&
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

	history.salePrice = self.salePriceValueLabel.text;
	history.originalPrice = self.originalPriceValueLabel.text;
	history.amountSaved = self.amountSavedValueLabel.text;
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
	additionalOff.delegate = self;
	return additionalOff;
}

- (QEntryElement *)taxElement {
	QEntryElement *tax = [[QEntryElement alloc] initWithTitle:@"Tax:" Value:[self savedValueForTax] Placeholder:@"0%"];
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

	QSection *section2 = [[QSection alloc] init];
	section2.key = SC_KEY_NUMBER_SECTION;
	[self buildNumberSection:section2];
	[newRoot addSection:section2];

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
	[simple setControllerAction:@"onChangeType:"];
	[section addElement:simple];

	[self assignRowHeightToElementInSection:section];
}

- (void)onChangeType:(QButtonElement *)element {
	if (_calculatorType == A3SalesCalculatorTypeAdvanced) {
		_calculatorType = A3SalesCalculatorTypeSimple;
	} else {
		_calculatorType = A3SalesCalculatorTypeAdvanced;
	}
	[A3UIKit setUserDefaults:[NSNumber numberWithUnsignedInteger:_calculatorType] forKey:A3SalesCalcDefaultCalculatorType];

	[self buildRoot];

	[self.quickDialogTableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 1)] withRowAnimation:UITableViewRowAnimationBottom];
	[self calculateSalePrice];
}

#pragma mark --
#pragma mark -- Override UIViewController


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[[EKKeyboardAvoidingScrollViewManager sharedInstance] registerScrollViewForKeyboardAvoiding:self.quickDialogTableView];

	[self registerForKeyboardNotifications];

	[self calculateSalePrice];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];

	[self addDataToHistory];

	[[EKKeyboardAvoidingScrollViewManager sharedInstance] unregisterScrollViewFromKeyboardAvoiding:self.quickDialogTableView];

	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --
#pragma mark - QuickDialogStyleProvider

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
				cell.textLabel.textColor = [A3UIStyle colorForTableViewCellLabelSelected];
			} else {
				cell.textLabel.textColor = [A3UIStyle colorForTableViewCellLabelNormal];
			}
			cell.textLabel.font = [A3UIStyle fontForTableViewEntryCellLabel];
			if ([cell isKindOfClass:[QEntryTableViewCell class]]) {
				QEntryTableViewCell *entryTableViewCell = (QEntryTableViewCell *)cell;
				[entryTableViewCell.textField setFont:[A3UIStyle fontForTableViewEntryCellTextField]];
			}
			break;
	}
}

-(void)sectionHeaderWillAppearForSection:(QSection *)section atIndex:(NSInteger)index {
	if ([section.key isEqualToString:SC_KEY_KNOWN_VALUE_SECTION]) {
		UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, APP_VIEW_WIDTH, 44.0f)];
		UILabel *sectionText = [[UILabel alloc] initWithFrame:CGRectMake(64.0f, 0.0f, APP_VIEW_WIDTH - 64.0f * 2.0f, 44.0f)];
		sectionText.backgroundColor = [UIColor clearColor];
		sectionText.font = [UIFont boldSystemFontOfSize:24.0f];
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
    
	NSUInteger index = [_keys indexOfObject:element.key];

	_editingElement = element;

	if ([self entryIndexIsForNumbers:index]) {
		cell.textField.inputView = self.keyboardViewController.view;
		_keyboardViewController.keyInputDelegate = cell.textField;
		_keyboardViewController.entryTableViewCell = cell;
		if ([element.key isEqualToString:SC_KEY_PRICE]) {
			_keyboardViewController.currencyCode = [self defaultCurrencyCode];
			[_keyboardViewController setKeyboardType:A3NumberKeyboardTypeCurrency];
		} else {
			[_keyboardViewController setKeyboardType:A3NumberKeyboardTypePercent];
		}
		cell.textField.inputAccessoryView = nil;

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
}

- (void)QEntryEditingChangedForElement:(QEntryElement *)element  andCell:(QEntryTableViewCell *)cell {
    NSUInteger index = [_keys indexOfObject:element.key];
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

	_editingElement = nil;

	NSUInteger index = [_keys indexOfObject:element.key];
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

- (void)registerForKeyboardNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidShow:)
												 name:UIKeyboardDidShowNotification object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidHide:)
												 name:UIKeyboardDidHideNotification object:nil];
}

- (void)keyboardDidShow:(NSNotification*)aNotification {
	if (_editingElement) {
		UITableViewCell *cell = [self.quickDialogTableView cellForElement:_editingElement];
		NSIndexPath *indexPath = [self.quickDialogTableView indexPathForCell:cell];

		[self.quickDialogTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	}
}

- (void)keyboardDidHide:(NSNotification*)aNotification {
	[self.quickDialogTableView setContentOffset:CGPointMake(0.0, 0.0)];
}

- (A3NumberKeyboardViewController *)keyboardViewController {
	if (nil == _keyboardViewController) {
		_keyboardViewController = [[A3NumberKeyboardViewController alloc] initWithNibName:@"A3NumberKeyboardViewController" bundle:nil];
		_keyboardViewController.delegate = self;
	}
	return _keyboardViewController;
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
	[self.quickDialogTableView reloadCellForElements:priceElement];
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

	_salePriceValueLabel.text = [self.currencyNumberFormatter stringFromNumber:[NSNumber numberWithDouble:salePrice]];
	_amountSavedValueLabel.text = [_currencyNumberFormatter stringFromNumber:[NSNumber numberWithDouble:amountSaved]];
	_originalPriceValueLabel.text = [_currencyNumberFormatter stringFromNumber:[NSNumber numberWithDouble:originalPrice]];

	CGSize sizeForLabel = [_originalPriceLabel.text sizeWithFont:_originalPriceLabel.font];
	CGSize sizeForValue = [_originalPriceValueLabel.text sizeWithFont:_originalPriceValueLabel.font];
	CGRect labelFrame = _originalPriceLabel.frame;
	labelFrame.origin.x = APP_VIEW_WIDTH - _rightMargin - 10.0 - sizeForValue.width - sizeForLabel.width;
	labelFrame.size.width = sizeForLabel.width;
	[_originalPriceLabel setFrame:labelFrame];

	_percentBarChart.leftValue = salePrice;
	_percentBarChart.rightValue = amountSaved;
	[_percentBarChart setNeedsDisplay];
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

	[self buildRoot];

	[self.quickDialogTableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationBottom];

	[self calculateSalePrice];
	[self reloadPriceElement];
}

- (void)presentCurrencySelectViewController {
	A3CurrencySelectViewController *viewController = [[A3CurrencySelectViewController alloc] initWithNibName:nil bundle:nil];
	CGRect frame = [A3UIDevice deviceOrientationIsPortrait] ? CGRectMake(0.0, 0.0, 320.0, 1004.0) : CGRectMake(0.0, 0.0, 320.0, 748.0);
	viewController.view.frame = frame;
	viewController.delegate = self;
	UINavigationController *tempNavigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
	frame = [A3UIDevice deviceOrientationIsPortrait] ? CGRectMake(768.0, 0.0, 320.0, 1004.0) : CGRectMake(1024.0, 0.0, 320.0, 748.0);
	tempNavigationController.view.frame = frame;

	[[[A3AppDelegate instance] paperFoldMenuViewController] presentRightWingWithViewController:tempNavigationController];
}

- (void)handleBigButton1 {
	if ([_editingElement.key isEqualToString:SC_KEY_PRICE]) {
		QEntryTableViewCell *cell = (QEntryTableViewCell *)[self.quickDialogTableView cellForElement:_editingElement];
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

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

	[_keyboardViewController rotateToInterfaceOrientation:toInterfaceOrientation];
}


@end
