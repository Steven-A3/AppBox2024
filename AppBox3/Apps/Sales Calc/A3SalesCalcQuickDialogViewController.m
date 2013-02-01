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
#import "common.h"
#import "A3CurrencyKeyboardViewController.h"
#import "EKKeyboardAvoidingScrollViewManager.h"
#import "A3UserDefaults.h"
#import "SalesCalcHistory.h"
#import "UIView+Screenshot.h"
#import "UIView+Genie.h"
#import "SalesCalcHistory.h"
#import "A3AppDelegate.h"
#import "A3Categories.h"
#import "A3SalesCalcHistoryViewController.h"
#import "KGDiscreetAlertView.h"

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

@property (nonatomic, strong) A3CurrencyKeyboardViewController *keyboardViewController;
@property (nonatomic, weak) QEntryTableViewCell *activeEntryTableViewCell;
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

- (NSString *)defaultCurrencyCode {
	return [[NSUserDefaults standardUserDefaults] objectForKey:A3SalesCalcDefaultCurrencyCode];
}

- (NSNumberFormatter *)currencyNumberFormatter {
	if (nil == _currencyNumberFormatter) {
		_currencyNumberFormatter = [[NSNumberFormatter alloc] init];
		[_currencyNumberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	}
	return _currencyNumberFormatter;
}

- (NSNumberFormatter *)percentNumberFormatter {
	if (nil == _percentNumberFormatter) {
		_percentNumberFormatter = [[NSNumberFormatter alloc] init];
		[_percentNumberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
		[_percentNumberFormatter setMaximumFractionDigits:3];
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
		_calculatorType = [storedValue unsignedIntegerValue];
	}
	return _calculatorType;
}

- (A3SalesCalcKnownValue)knownValue {
	NSNumber *storedValue = [[NSUserDefaults standardUserDefaults] objectForKey:A3SalesCalcDefaultSavedKnownValue];
	if (nil == storedValue) {
		return A3SalesCalcKnownValueOriginalPrice;
	}
	return [storedValue unsignedIntegerValue];
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

- (void)putUserDefaultForKey:(NSString *)key withValue:(id) value {
	[[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	// Custom initialization
    self = [super initWithNibName:nil bundle:nil];
	if (self) {
		[self buildRoot];
	}
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.view.backgroundColor = [UIColor clearColor];
	self.quickDialogTableView.backgroundView = nil;
	self.quickDialogTableView.backgroundColor = [UIColor clearColor];

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
	_originalPriceValueLabel.textAlignment = UITextAlignmentRight;
	[tableHeaderView addSubview:_originalPriceValueLabel];

	_percentBarChart = [[A3HorizontalBarChartView alloc] initWithFrame:CGRectMake(offsetX, offsetY, APP_VIEW_WIDTH - offsetX * 2.0f, chartHeight)];
	[tableHeaderView addSubview:_percentBarChart];

	_salePriceValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetX + 10.0, offsetY, 200.0, chartHeight)];
	_salePriceValueLabel.backgroundColor = [UIColor clearColor];
	_salePriceValueLabel.textColor = [UIColor whiteColor];
	_salePriceValueLabel.font = [UIFont boldSystemFontOfSize:22.0];
	_salePriceValueLabel.textAlignment = UITextAlignmentLeft;
	[tableHeaderView addSubview:_salePriceValueLabel];

	_amountSavedValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(APP_VIEW_WIDTH - _rightMargin - 200.0, offsetY, 200.0, chartHeight)];
	_amountSavedValueLabel.backgroundColor = [UIColor clearColor];
	_amountSavedValueLabel.textColor = [UIColor whiteColor];
	_amountSavedValueLabel.font = [UIFont boldSystemFontOfSize:22.0];
	_amountSavedValueLabel.textAlignment = UITextAlignmentRight;
	[tableHeaderView addSubview:_amountSavedValueLabel];

	self.quickDialogTableView.tableHeaderView = tableHeaderView;
	self.quickDialogTableView.styleProvider = self;
	self.quickDialogTableView.backgroundView = nil;
	self.quickDialogTableView.backgroundColor = [UIColor colorWithRed:248.0f/255.0f green:248.0f/255.0f blue:248.0f/255.0f alpha:1.0f];
	self.quickDialogTableView.rowHeight = 58.0f;
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

	BOOL isOriginalPrice, isAdvanced;

	if ([fetchedObjects count]) {
		SalesCalcHistory *lastHistory = [fetchedObjects objectAtIndex:0];

		isOriginalPrice = [self isOriginalPrice];
		isAdvanced = _calculatorType == A3SalesCalculatorTypeAdvanced;

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
	QRootElement *newRoot = [[QRadioElement alloc] init];
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
	[self resetNumberSection:section2];
	[newRoot addSection:section2];

	self.root = newRoot;
}

- (void)resetNumberSection:(QSection *)section {
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
	[self putUserDefaultForKey:A3SalesCalcDefaultCalculatorType withValue:[NSNumber numberWithUnsignedInteger:_calculatorType]];

	[self buildRoot];

	[self.quickDialogTableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 1)] withRowAnimation:UITableViewRowAnimationBottom];
	[self calculateSalePrice];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[[EKKeyboardAvoidingScrollViewManager sharedInstance] registerScrollViewForKeyboardAvoiding:self.quickDialogTableView];

	[self registerForKeyboardNotifications];

	[self calculateSalePrice];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];

	[self addDataToHistory];

	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];

	[[EKKeyboardAvoidingScrollViewManager sharedInstance] unregisterScrollViewFromKeyboardAvoiding:self.quickDialogTableView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - QuickDialogStyleProvider

- (UIColor *)darkBlueColor {
	return [UIColor colorWithRed:40.0f/255.0f green:72.0f/255.0f blue:114.0f/255.0f alpha:1.0f];
}

- (UIColor *)grayColor {
	return [UIColor colorWithRed:115.0f/255.0f green:115.0f/255.0f blue:115.0f/255.0f alpha:1.0f];
}

- (void)cell:(UITableViewCell *)cell willAppearForElement:(QElement *)element atIndexPath:(NSIndexPath *)indexPath {
//	cell.backgroundColor = [UIColor colorWithRed:248.0f/255.0f green:248.0f/255.0f blue:248.0f/255.0f alpha:1.0f];
	cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.95];

	switch (indexPath.section) {
		case 0:
			cell.textLabel.font = [UIFont boldSystemFontOfSize:25.0f];
			if ([element.parentSection isKindOfClass:[QRadioSection class]]) {
				QRadioSection *radioSection = (QRadioSection *)element.parentSection;
				if (radioSection.selected == indexPath.row) {
					cell.textLabel.textColor = [self darkBlueColor];
				} else {
					cell.textLabel.textColor = [self grayColor];
				}
			}
			break;
		case 1:
			if ([element isKindOfClass:[QButtonElement class]]) {
				cell.textLabel.textColor = [self darkBlueColor];
				cell.textLabel.font = [UIFont boldSystemFontOfSize:25.0];
			} else {
				cell.textLabel.textColor = [self grayColor];
				cell.textLabel.font = [UIFont systemFontOfSize:25.0f];
			}
			if ([cell isKindOfClass:[QEntryTableViewCell class]]) {
				QEntryTableViewCell *entryTableViewCell = (QEntryTableViewCell *)cell;
				[entryTableViewCell.textField setFont:[UIFont boldSystemFontOfSize:25.0f]];
				entryTableViewCell.textField.inputView = self.keyboardViewController.view;
			}
			break;
	}
}

-(void) sectionHeaderWillAppearForSection:(QSection *)section atIndex:(NSInteger)indexPath {
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

- (void)QEntryDidBeginEditingElement:(QEntryElement *)element  andCell:(QEntryTableViewCell *)cell {
    _keyboardViewController.keyInputDelegate = cell.textField;
	_keyboardViewController.entryTableViewCell = cell;
    cell.textField.inputAccessoryView = nil;

	_activeEntryTableViewCell = cell;

	NSUInteger index = [_keys indexOfObject:element.key];
	if ([self entryIndexIsForNumbers:index]) {
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

- (NSString *)currencyFormattedString:(NSString *)source {
	if ([source floatValue] == 0.0) return @"";
	return [self.currencyNumberFormatter stringFromNumber:[NSNumber numberWithFloat:[source floatValue]]];
}

- (NSString *)percentFormattedString:(NSString *)source {
	if ([source floatValue] == 0.0) return @"";
	return [self.percentNumberFormatter stringFromNumber:[NSNumber numberWithFloat:[source floatValue] / 100.0]];
}

- (void)QEntryEditingChangedForElement:(QEntryElement *)element  andCell:(QEntryTableViewCell *)cell {
	NSUInteger index = [_keys indexOfObject:element.key];
	if (index == 0) {
		// price
		element.textValue = [self currencyFormattedString:cell.textField.text];
		[self putUserDefaultForKey:A3SalesCalcDefaultSavedValuePrice withValue:element.textValue];
	} else if ([element.key isEqualToString:SC_KEY_NOTES]) {
		[self putUserDefaultForKey:A3SalesCalcDefaultSavedValueNotes withValue:cell.textField.text];
	} else {
		element.textValue = [self percentFormattedString:cell.textField.text];
		switch (index) {
			case 1:
				// discount percent
				[self putUserDefaultForKey:A3SalesCalcDefaultSavedValueDiscount withValue:element.textValue];
				break;
			case 2:
				// Additional discount percent
				[self putUserDefaultForKey:A3SalesCalcDefaultSavedValueAdditionalOff withValue:element.textValue];
				break;
			case 3:
				// Tax
				[self putUserDefaultForKey:A3SalesCalcDefaultSavedValueTax withValue:element.textValue];
				break;
		}
	}

	if ([self entryIndexIsForNumbers:index]) {
		[self calculateSalePrice];
	}
}

- (void)QEntryDidEndEditingElement:(QEntryElement *)element andCell:(QEntryTableViewCell *)cell {
	NSUInteger index = [_keys indexOfObject:element.key];
	if (index == 0) {
		// price
		element.textValue = [self currencyFormattedString:cell.textField.text];
		cell.textField.text = element.textValue;
		[self putUserDefaultForKey:A3SalesCalcDefaultSavedValuePrice withValue:element.textValue];
	} else if ([element.key isEqualToString:SC_KEY_NOTES]) {
		element.textValue = cell.textField.text;
		[self putUserDefaultForKey:A3SalesCalcDefaultSavedValueNotes withValue:element.textValue];
	} else {
		element.textValue = [self percentFormattedString:cell.textField.text];
		cell.textField.text = element.textValue;
		switch (index) {
			case 1:
				// discount percent
				[self putUserDefaultForKey:A3SalesCalcDefaultSavedValueDiscount withValue:element.textValue];
				break;
			case 2:
				// Additional discount percent
				[self putUserDefaultForKey:A3SalesCalcDefaultSavedValueAdditionalOff withValue:element.textValue];
				break;
			case 3:
				// Tax
				[self putUserDefaultForKey:A3SalesCalcDefaultSavedValueTax withValue:element.textValue];
				break;
			case 4:
				// Notes
				[self putUserDefaultForKey:A3SalesCalcDefaultSavedValueNotes withValue:element.textValue];
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
											 selector:@selector(keyboardWasShown:)
												 name:UIKeyboardDidShowNotification object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidHide:)
												 name:UIKeyboardDidHideNotification object:nil];}

- (void)keyboardWasShown:(NSNotification*)aNotification {
	if (_activeEntryTableViewCell) {
		NSIndexPath *indexPath = [self.quickDialogTableView indexPathForCell:_activeEntryTableViewCell];

		[self.quickDialogTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	}
}

- (void)keyboardDidHide:(NSNotification*)aNotification {
	[self.quickDialogTableView setContentOffset:CGPointMake(0.0, 0.0)];
}

- (A3CurrencyKeyboardViewController *)keyboardViewController {
	if (nil == _keyboardViewController) {
		_keyboardViewController = [[A3CurrencyKeyboardViewController alloc] initWithNibName:@"A3CurrencyKeyboardViewController" bundle:nil];
		[_keyboardViewController setKeyboardType:A3CurrencyKeyboardTypeCurrency];
	}
	return _keyboardViewController;
}

- (void)onSelectOriginalPrice:(QSelectItemElement *)selectItemElement {
	QRadioSection *parentSection = (QRadioSection *)selectItemElement.parentSection;
	parentSection.selected = 0;
	[self.quickDialogTableView reloadData];

	[self putUserDefaultForKey:A3SalesCalcDefaultSavedKnownValue withValue:[NSNumber numberWithUnsignedInteger:A3SalesCalcKnownValueOriginalPrice]];
	[self calculateSalePrice];
}

- (void)onSelectSalePrice:(QSelectItemElement *)selectItemElement {
	QRadioSection *parentSection = (QRadioSection *)selectItemElement.parentSection;
	parentSection.selected = 1;
	[self.quickDialogTableView reloadData];

	[self putUserDefaultForKey:A3SalesCalcDefaultSavedKnownValue withValue:[NSNumber numberWithUnsignedInteger:A3SalesCaleKnownValueSalePrice]];
	[self calculateSalePrice];
}

- (void)calculateSalePrice {
	QRadioSection *radioSection = (QRadioSection *)[self.root sectionWithKey:SC_KEY_KNOWN_VALUE_SECTION];
	QEntryElement *priceElement = (QEntryElement *)[self.root elementWithKey:SC_KEY_PRICE];
	QEntryElement *discountElement = (QEntryElement *)[self.root elementWithKey:SC_KEY_DISCOUNT];
	QEntryElement *additionalOffElement = (QEntryElement *)[self.root elementWithKey:SC_KEY_ADDITIONAL_OFF];
	QEntryElement *taxElement = (QEntryElement *)[self.root elementWithKey:SC_KEY_TAX];

	float originalPrice, salePrice, discount, additionalOff, tax, amountSaved;

	discount = [discountElement.textValue floatValueEx];
	if (radioSection.selected == 0) {
		// Know original price, get sale price
		originalPrice = [priceElement.textValue floatValueEx];

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
		salePrice = [priceElement.textValue floatValueEx];
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

	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	_salePriceValueLabel.text = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:salePrice]];
	_amountSavedValueLabel.text = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:amountSaved]];
	_originalPriceValueLabel.text = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:originalPrice]];

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
	[self putUserDefaultForKey:A3SalesCalcDefaultCalculatorType withValue:[NSNumber numberWithUnsignedInteger:_calculatorType]];

	[self putUserDefaultForKey:A3SalesCalcDefaultSavedKnownValue withValue:[NSNumber numberWithUnsignedInteger:history.isOriginalPrice ? A3SalesCalcKnownValueOriginalPrice : A3SalesCaleKnownValueSalePrice]];

	[self putUserDefaultForKey:A3SalesCalcDefaultSavedValuePrice withValue:history.isOriginalPrice ? history.originalPrice : history.salePrice];
	[self putUserDefaultForKey:A3SalesCalcDefaultSavedValueDiscount withValue:history.discount];
	[self putUserDefaultForKey:A3SalesCalcDefaultSavedValueAdditionalOff withValue:history.additionaloff];
	[self putUserDefaultForKey:A3SalesCalcDefaultSavedValueTax withValue:history.tax];
	[self putUserDefaultForKey:A3SalesCalcDefaultSavedValueNotes withValue:history.notes];

	[self buildRoot];

	[self.quickDialogTableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationBottom];

	[self calculateSalePrice];
}

@end
