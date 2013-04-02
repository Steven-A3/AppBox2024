//  A3LoanCalcQuickDialogViewController.m
//  AppBox3
//
//
//  Created by Byeong Kwon Kwak on 2/16/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcQuickDialogViewController.h"
#import "A3LoanCalcPieChartViewController.h"
#import "A3UIStyle.h"
#import "A3UIKit.h"
#import "CommonUIDefinitions.h"
#import "EKKeyboardAvoidingScrollViewManager.h"
#import "LoanCalcHistory.h"
#import "A3AppDelegate.h"
#import "A3LoanCalcString.h"
#import "A3Formatter.h"
#import "A3ButtonTextField.h"
#import "QEntryTableViewCell+Extension.h"
#import "common.h"
#import "LoanCalcHistory+calculation.h"
#import "NSString+conversion.h"


#define A3LC_CONTROLLER_NAME		@"A3LoanCalcQuickDialogViewController"

#define A3LC_TAG_CALCULATION_FOR_VALUE 7667001	// L = 76, 67 = C, 001 = id for view tag

@interface A3LoanCalcQuickDialogViewController () <UITextFieldDelegate>
@property (nonatomic, strong)	A3LoanCalcPreferences *preferences;
@property (nonatomic, strong) 	QRootElement *rootElement;
@property (nonatomic, strong) 	NSNumberFormatter *currencyNumberFormatter, *percentNumberFormatter;
@property (nonatomic, strong) 	A3LoanCalcPieChartViewController *tableHeaderViewController;
@property (nonatomic, strong)	NSMutableArray *keysForCurrency;
@property (nonatomic, strong)	NSMutableDictionary *enumForEntryKeys;
@property (nonatomic, strong)	A3NumberKeyboardViewController *numberKeyboardViewController;
@property (nonatomic, strong)	A3FrequencyKeyboardViewController *frequencyKeyboardViewController;
@property (nonatomic, strong)	A3DateKeyboardViewController *dateKeyboardViewController;
@property (nonatomic, strong)	A3DateKeyboardViewController *dateKeyboardForMonthInput;
@property (nonatomic, strong)	A3DateKeyboardViewController *dateKeyboardForYearMonthInput;
@property (nonatomic, weak)		QEntryElement *editingElement;
@property (nonatomic, strong)	LoanCalcHistory *editingObject;
@property (nonatomic, strong)	UILabel *temporaryLabelForEditing;
@property (nonatomic, strong)	A3ButtonTextField *extraPaymentYearlyMonth, *extraPaymentOneTimeYearMonth;

@end

@implementation A3LoanCalcQuickDialogViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

		self.root = [self rootElement];
	}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view.
	self.quickDialogTableView.backgroundView = nil;
	self.quickDialogTableView.backgroundColor = [A3UIStyle contentsBackgroundColor];
	self.quickDialogTableView.tableHeaderView = self.tableHeaderViewController.view;
	self.quickDialogTableView.styleProvider = self;

	[self reloadGraphView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)applyCommonAttributes {
	for (QSection *section in self.rootElement.sections) {
		for (QElement *element in section.elements) {
			element.height = A3_LOAN_CALC_ROW_HEIGHT;
			if ([element isKindOfClass:[QEntryElement class]]) {
				((QEntryElement *)element).delegate = self;
			}
		}
	}
}

- (void)reloadContents {
	if (_editingObject) {
		_editingObject.showDownPayment = [NSNumber numberWithBool:self.preferences.showDownPayment];
		_editingObject.showExtraPayment = [NSNumber numberWithBool:_preferences.showExtraPayment];
		_editingObject.useSimpleInterest = [NSNumber numberWithBool:_preferences.useSimpleInterest];
		_editingObject.showAdvanced = [NSNumber numberWithBool:_preferences.showAdvanced];
		_editingObject.calculationFor = [NSNumber numberWithUnsignedInteger:_preferences.calculationFor];

		[self calculate];

		NSManagedObjectContext *managedObjectContext = [[A3AppDelegate instance] managedObjectContext];
		NSError *error;
		[managedObjectContext save:&error];
	}

	_rootElement = nil;
	self.root = [self rootElement];
	[self.quickDialogTableView reloadData];
}

- (A3LoanCalcPreferences *)preferences {
	if (nil == _preferences) {
		_preferences = [[A3LoanCalcPreferences alloc] init];
	}
	return _preferences;
}

- (NSString *)stringForCalculation {
	NSString *string = @"";
	LoanCalcHistory *object = self.editingObject;
	switch ((A3LoanCalcCalculationFor)[object.calculationFor unsignedIntegerValue]) {
		case A3_LCCF_MonthlyPayment:
			string = object.monthlyPayment;
			break;
		case A3_LCCF_DownPayment:
			string = object.downPayment;
			break;
		case A3_LCCF_Principal:
			string = object.principal;
			break;
		case A3_LCCF_TermYears:
		case A3_LCCF_TermMonths:
			string = object.term;
			break;
	}
	FNLOG(@"%@", string);
	return string;
}

- (QRootElement *)rootElement {
	if (nil == _rootElement) {
		_keysForCurrency = [[NSMutableArray alloc] init];
		_enumForEntryKeys = [[NSMutableDictionary alloc] init];

		_rootElement = [[QRootElement alloc] init];
		_rootElement.controllerName = A3LC_CONTROLLER_NAME;
		_rootElement.grouped = YES;

		QSection *section1 = [[QSection alloc] init];
		QLabelElement *section1element = [[QLabelElement alloc] initWithTitle:@"calculation for" Value:self.stringForCalculation];
		section1element.key = A3LC_KEY_CALCULATION_FOR;
		[section1 addElement:section1element];

		// Section 2: Input values
		QSection *section2 = [[QSection alloc] init];

		A3LoanCalcCalculationFor calculationFor = self.preferences.calculationFor;

		switch (calculationFor) {
			case A3_LCCF_MonthlyPayment:
				[section2 addElement:[self principalElement]];
				if (self.preferences.showDownPayment) [section2 addElement:[self downPaymentElement]];
				[section2 addElement:[self termElement]];
				break;
			case A3_LCCF_DownPayment:
				[section2 addElement:[self principalElement]];
				[section2 addElement:[self monthlyPaymentElement]];
				[section2 addElement:[self termElement]];
				break;
			case A3_LCCF_Principal:
				if (self.preferences.showDownPayment) [section2 addElement:[self downPaymentElement]];
				[section2 addElement:[self monthlyPaymentElement]];
				[section2 addElement:[self termElement]];
				break;
			case A3_LCCF_TermYears:
			case A3_LCCF_TermMonths:
				[section2 addElement:[self principalElement]];
				if (self.preferences.showDownPayment) [section2 addElement:[self downPaymentElement]];
				[section2 addElement:[self monthlyPaymentElement]];
				break;
		}

		[section2 addElement:[self interestRateElement]];

		if (self.preferences.showAdvanced) {
			[section2 addElement:[self frequencyElement]];
			[section2 addElement:[self startDateElement]];
			[section2 addElement:[self notesElement]];
		}
		[section2 addElement:[self typeChangeButtonElement]];

		[_rootElement addSection:section1];
		[_rootElement addSection:section2];

		if (self.preferences.showExtraPayment) {
			// Section 3: Extra Payments
			QSection *section3 = [[QSection alloc] initWithTitle:@"Extra Payments"];
			[section3 addElement:[self extraPaymentMonthly]];
			[section3 addElement:[self extraPaymentYearly]];
			[section3 addElement:[self extraPaymentOneTime]];

			[_rootElement addSection:section3];
		}

		[self applyCommonAttributes];
	}
	return _rootElement;
}

// Section 3
- (QEntryElement *)extraPaymentOneTime {
	QEntryElement *extraPaymentOneTime = [[QEntryElement alloc] initWithTitle:NSLocalizedString(@"One-Time:", @"One-Time:") Value:@"" Placeholder:[self zeroCurrency]];
	extraPaymentOneTime.key = A3LC_KEY_EXTRA_PAYMENT_ONETIME;
	extraPaymentOneTime.delegate = self;
	[_keysForCurrency addObject:extraPaymentOneTime.key];
	[_enumForEntryKeys setObject:[NSNumber numberWithUnsignedInteger:A3LCEntryExtraPaymentOneTime] forKey:A3LC_KEY_EXTRA_PAYMENT_ONETIME];
	return extraPaymentOneTime;
}

- (QEntryElement *)extraPaymentYearly {
	QEntryElement *extraPaymentYearly = [[QEntryElement alloc] initWithTitle:NSLocalizedString(@"Yearly:", @"Yearly:") Value:@"" Placeholder:[self zeroCurrency]];
	extraPaymentYearly.key = A3LC_KEY_EXTRA_PAYMENT_YEARLY;
	extraPaymentYearly.delegate = self;
	[_keysForCurrency addObject:extraPaymentYearly.key];
	[_enumForEntryKeys setObject:[NSNumber numberWithUnsignedInteger:A3LCEntryExtraPaymentYearly] forKey:A3LC_KEY_EXTRA_PAYMENT_YEARLY];
	return extraPaymentYearly;
}

- (QEntryElement *)extraPaymentMonthly {
	QEntryElement *extraPaymentMonthly = [[QEntryElement alloc] initWithTitle:NSLocalizedString(@"Monthly:", @"Monthly:") Value:@"" Placeholder:[self zeroCurrency]];
	extraPaymentMonthly.key = A3LC_KEY_EXTRA_PAYMENT_MONTHLY;
	extraPaymentMonthly.delegate = self;
	[_keysForCurrency addObject:extraPaymentMonthly.key];
	[_enumForEntryKeys setObject:[NSNumber numberWithUnsignedInteger:A3LCEntryExtraPaymentMonthly] forKey:A3LC_KEY_EXTRA_PAYMENT_MONTHLY];
	return extraPaymentMonthly;
}

- (QButtonElement *)typeChangeButtonElement {
	NSString *buttonTitle =	self.preferences.showAdvanced ? @"Simple" : @"Advanced";
	QButtonElement *typeChangeButton = [[QButtonElement alloc] initWithTitle:buttonTitle];
	typeChangeButton.controllerAction = @"onSimpleAdvanced:";
	return typeChangeButton;
}

- (QEntryElement *)notesElement {
	QEntryElement *notes = [[QEntryElement alloc] initWithTitle:NSLocalizedString(@"Notes:", @"Notes:") Value:@"" Placeholder:@"(Optional)"];
	notes.key = A3LC_KEY_NOTES;
	notes.height = A3_LOAN_CALC_ROW_HEIGHT;
	notes.delegate = self;
	[_enumForEntryKeys setObject:[NSNumber numberWithUnsignedInteger:A3LCEntryNotes] forKey:A3LC_KEY_NOTES];
	return notes;
}

- (QEntryElement *)startDateElement {
	QEntryElement *startDate = [[QEntryElement alloc] initWithTitle:NSLocalizedString(@"Start Date:", @"Start Date:") Value:@"" Placeholder:[A3UIKit mediumStyleDateString:[NSDate date]]];
	startDate.key = A3LC_KEY_START_DATE;
	startDate.height = A3_LOAN_CALC_ROW_HEIGHT;
	startDate.delegate = self;
	[_enumForEntryKeys setObject:[NSNumber numberWithUnsignedInteger:A3LCEntryStartDate] forKey:A3LC_KEY_START_DATE];
	return startDate;
}

- (QEntryElement *)frequencyElement {
	QEntryElement *frequency = [[QEntryElement alloc] initWithTitle:NSLocalizedString(@"Frequency:", @"Frequency:") Value:@"" Placeholder:@"Monthly"];
	frequency.key = A3LC_KEY_FREQUENCY;
	frequency.height = A3_LOAN_CALC_ROW_HEIGHT;
	frequency.delegate = self;
	[_enumForEntryKeys setObject:[NSNumber numberWithUnsignedInteger:A3LCEntryFrequency] forKey:A3LC_KEY_FREQUENCY];
	return frequency;
}

- (QEntryElement *)interestRateElement {
	QEntryElement *interestRate = [[QEntryElement alloc] initWithTitle:NSLocalizedString(@"Interest Rate:", @"Interest Rate:") Value:@"" Placeholder:@"Annual 0%"];
	interestRate.key = A3LC_KEY_INTEREST_RATE;
	interestRate.delegate = self;
	[_enumForEntryKeys setObject:[NSNumber numberWithUnsignedInteger:A3LCEntryInterestRate] forKey:A3LC_KEY_INTEREST_RATE];
	return interestRate;
}

- (QEntryElement *)principalElement {
	QEntryElement *principalElement = [[QEntryElement alloc] initWithTitle:NSLocalizedString(@"Principal:", @"Principal") Value:@"" Placeholder:@"$0.00"];
	principalElement.key = A3LC_KEY_PRINCIPAL;
	principalElement.delegate = self;
	[_keysForCurrency addObject:principalElement.key];
	[_enumForEntryKeys setObject:[NSNumber numberWithUnsignedInteger:A3LCEntryPrincipal] forKey:A3LC_KEY_PRINCIPAL];
	return principalElement;
}

- (QEntryElement *)monthlyPaymentElement {
	QEntryElement *monthlyPaymentElement = [[QEntryElement alloc] initWithTitle:@"Monthly Payment:" Value:@"" Placeholder:@"$0.00"];
	monthlyPaymentElement.key = A3LC_KEY_MONTHLY_PAYMENT;
	monthlyPaymentElement.delegate = self;
	[_keysForCurrency addObject:monthlyPaymentElement.key];
	[_enumForEntryKeys setObject:[NSNumber numberWithUnsignedInteger:A3LCEntryMonthlyPayment] forKey:A3LC_KEY_MONTHLY_PAYMENT];
	return monthlyPaymentElement;
}

- (QEntryElement *)termElement {
	QEntryElement *termElement = [[QEntryElement alloc] initWithTitle:NSLocalizedString(@"Term:", @"Term:") Value:@"" Placeholder:@"years or months"];
	termElement.key = A3LC_KEY_TERM;
	termElement.delegate = self;
	[_enumForEntryKeys setObject:[NSNumber numberWithUnsignedInteger:A3LCEntryTerm] forKey:A3LC_KEY_TERM];
	return termElement;
}

- (QEntryElement *)downPaymentElement {
	QEntryElement *downPaymentElement = [[QEntryElement alloc] initWithTitle:@"Down Payment:" Value:@"" Placeholder:[self zeroCurrency]];
	downPaymentElement.key = A3LC_KEY_DOWN_PAYMENT;
	downPaymentElement.delegate = self;
	[_keysForCurrency addObject:downPaymentElement.key];
	[_enumForEntryKeys setObject:[NSNumber numberWithUnsignedInteger:A3LCEntryDownPayment] forKey:A3LC_KEY_DOWN_PAYMENT];
	return downPaymentElement;
}

- (NSString *)zeroCurrency {
	return [self.currencyNumberFormatter stringFromNumber:[NSNumber numberWithFloat:0.0]];
}

- (NSNumberFormatter *)currencyNumberFormatter {
	if (nil == _currencyNumberFormatter) {
		_currencyNumberFormatter = [A3UIKit currencyNumberFormatter];
	}
	return _currencyNumberFormatter;
}

- (NSNumberFormatter *)percentNumberFormatter {
	if (nil == _percentNumberFormatter) {
		_percentNumberFormatter = [A3UIKit percentNumberFormatter];
	}
	return _percentNumberFormatter;
}

- (A3LoanCalcPieChartViewController *)tableHeaderViewController {
	if (nil == _tableHeaderViewController) {
		_tableHeaderViewController = [[A3LoanCalcPieChartViewController alloc] initWithNibName:@"A3LoanCalcPieChartViewController" bundle:nil];
	}
	return _tableHeaderViewController;
}

- (A3NumberKeyboardViewController *)numberKeyboardViewController {
	if (nil == _numberKeyboardViewController) {
		_numberKeyboardViewController = [[A3NumberKeyboardViewController alloc] initWithNibName:@"A3NumberKeyboardViewController" bundle:nil];
		_numberKeyboardViewController.delegate = self;
	}
	return _numberKeyboardViewController;
}

- (A3FrequencyKeyboardViewController *)frequencyKeyboardViewController {
	if (nil == _frequencyKeyboardViewController) {
		_frequencyKeyboardViewController = [[A3FrequencyKeyboardViewController alloc] initWithNibName:@"A3FrequencyKeyboardViewController" bundle:nil];
		_frequencyKeyboardViewController.delegate = self;
	}
	return _frequencyKeyboardViewController;
}

- (A3DateKeyboardViewController *)dateKeyboardViewController {
	if (nil == _dateKeyboardViewController) {
		_dateKeyboardViewController = [[A3DateKeyboardViewController alloc] initWithNibName:@"A3DateKeyboardViewController" bundle:nil];
		_dateKeyboardViewController.workingMode = A3DateKeyboardWorkingModeYearMonthDay;
		_dateKeyboardViewController.delegate = self;
	}
	return _dateKeyboardViewController;
}

- (A3DateKeyboardViewController *)dateKeyboardForMonthInput {
	if (nil == _dateKeyboardForMonthInput) {
		_dateKeyboardForMonthInput = [[A3DateKeyboardViewController alloc] initWithNibName:@"A3DateKeyboardViewController" bundle:nil];
		_dateKeyboardForMonthInput.workingMode = A3DateKeyboardWorkingModeMonth;
		_dateKeyboardForMonthInput.delegate = self;
	}
	return _dateKeyboardForMonthInput;
}

- (A3DateKeyboardViewController *)dateKeyboardForYearMonthInput {
	if (nil == _dateKeyboardForYearMonthInput) {
		_dateKeyboardForYearMonthInput = [[A3DateKeyboardViewController alloc] initWithNibName:@"A3DateKeyboardViewController" bundle:nil];
		_dateKeyboardForYearMonthInput.workingMode = A3DateKeyboardWorkingModeYearMonth;
		_dateKeyboardForYearMonthInput.delegate = self;
	}
	return _dateKeyboardForYearMonthInput;
}

- (LoanCalcHistory *)editingObject {
	if (nil == _editingObject) {
		NSManagedObjectContext *managedObjectContext = [[A3AppDelegate instance] managedObjectContext];
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"LoanCalcHistory" inManagedObjectContext:managedObjectContext];
		[fetchRequest setEntity:entity];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(editing == YES) and (location == 'S')"];
		[fetchRequest setPredicate:predicate];
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:NO];
		[fetchRequest setSortDescriptors:@[sortDescriptor]];
		[fetchRequest setFetchLimit:1];
		NSError *error;
		NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
		if ([fetchedObjects count]) {
			_editingObject = [fetchedObjects objectAtIndex:0];
			[self.preferences setCalculationFor:(A3LoanCalcCalculationFor)[_editingObject.calculationFor unsignedIntegerValue]];
			[_preferences setShowDownPayment:[_editingObject.showDownPayment boolValue]];
			[_preferences setShowExtraPayment:[_editingObject.showExtraPayment boolValue]];
			[_preferences setShowAdvanced:[_editingObject.showAdvanced boolValue]];
			[_preferences setUseSimpleInterest:[_editingObject.useSimpleInterest boolValue]];
		} else {
			_editingObject = [NSEntityDescription insertNewObjectForEntityForName:@"LoanCalcHistory" inManagedObjectContext:managedObjectContext];
            [_editingObject initializeValues];
		}
	}
	return _editingObject;
}

- (A3ButtonTextField *)extraPaymentYearlyMonth {
	if (nil == _extraPaymentYearlyMonth) {
		_extraPaymentYearlyMonth = [[A3ButtonTextField alloc] initWithFrame:CGRectMake(0.0, 0.0, 96.0, 32.0)];
		_extraPaymentYearlyMonth.text = @"";
		_extraPaymentYearlyMonth.placeholder = [A3Formatter fullStyleMonthSymbolFromDate:[NSDate date]];
		_extraPaymentYearlyMonth.textAlignment = NSTextAlignmentCenter;
		_extraPaymentYearlyMonth.font = [UIFont boldSystemFontOfSize:14.0];
		_extraPaymentYearlyMonth.delegate = self;
	}
	return _extraPaymentYearlyMonth;
}

- (A3ButtonTextField *)extraPaymentOneTimeYearMonth {
	if (nil == _extraPaymentOneTimeYearMonth) {
		_extraPaymentOneTimeYearMonth = [[A3ButtonTextField alloc] initWithFrame:CGRectMake(0.0, 0.0, 132.0, 32.0)];
		_extraPaymentOneTimeYearMonth.text = @"";
		_extraPaymentOneTimeYearMonth.placeholder = [A3Formatter fullStyleYearMonthStringFromDate:[NSDate date]];
		_extraPaymentOneTimeYearMonth.textAlignment = NSTextAlignmentCenter;
		_extraPaymentOneTimeYearMonth.font = [UIFont boldSystemFontOfSize:14.0];
		_extraPaymentOneTimeYearMonth.delegate = self;
	}
	return _extraPaymentOneTimeYearMonth;
}


#pragma mark - QuickDialogStyleProvider

- (void)cell:(UITableViewCell *)cell willAppearForElement:(QElement *)element atIndexPath:(NSIndexPath *)indexPath {
	cell.backgroundColor = [A3UIStyle contentsBackgroundColor];

	switch (indexPath.section) {
		case 0:
			[self configureSectionZeroCell:cell withElement:element];
			break;
		case 1:
			[self configureSection1Cell:cell withElement:element];
			break;
		case 2:
			[self configureSection2Cell:cell withElement:element];
			break;
		default:
			break;
	}
}

- (void)applyEntryCellAttribute:(QEntryTableViewCell *)cell {
	cell.textField.font = [A3UIStyle fontForTableViewEntryCellTextField];
	cell.textField.textColor = [A3UIStyle colorForTableViewCellLabelSelected];
	cell.textField.textAlignment = NSTextAlignmentLeft;
}

- (void)configureSection2Cell:(UITableViewCell *)cell withElement:(QElement *)element {
	cell.textLabel.font = [A3UIStyle fontForTableViewEntryCellLabel];
	cell.textLabel.textColor = [A3UIStyle colorForTableViewCellLabelNormal];
	if ([cell isKindOfClass:[QEntryTableViewCell class]]) {
		[self applyEntryCellAttribute:(QEntryTableViewCell *)cell];
	}
	if ([element.key isEqualToString:A3LC_KEY_EXTRA_PAYMENT_YEARLY]) {
		cell.accessoryView = self.extraPaymentYearlyMonth;
	} else if ([element.key isEqualToString:A3LC_KEY_EXTRA_PAYMENT_ONETIME]) {
		cell.accessoryView = self.extraPaymentOneTimeYearMonth;
	}
}

- (void)configureSection1Cell:(UITableViewCell *)cell withElement:(QElement *)element {
	if ([element isKindOfClass:[QButtonElement class]]) {
		cell.textLabel.font = [A3UIStyle fontForTableViewEntryCellTextField];
		cell.textLabel.textColor = [A3UIStyle colorForTableViewCellLabelSelected];
	} else {
		cell.textLabel.font = [A3UIStyle fontForTableViewEntryCellLabel];
		cell.textLabel.textColor = [A3UIStyle colorForTableViewCellLabelNormal];
	}

	if ([cell isKindOfClass:[QEntryTableViewCell class]]) {
		LoanCalcHistory *object = self.editingObject;

		QEntryTableViewCell *entryTableViewCell = (QEntryTableViewCell *)cell;
		[self applyEntryCellAttribute:entryTableViewCell];

		if ([element.key isEqualToString:A3LC_KEY_START_DATE]) {
			if (object.startDate) {
				entryTableViewCell.textField.text = [A3Formatter mediumStyleDateStringFromDate:object.startDate];
			}
		}
		else if ([element.key isEqualToString:A3LC_KEY_FREQUENCY]) {
			entryTableViewCell.textField.text = [A3LoanCalcString stringForFrequencyValue:object.frequency];
		}
		else {
			entryTableViewCell.textField.text = [object valueForKey:element.key];
		}
	}

}

- (void)configureSectionZeroCell:(UITableViewCell *)cell withElement:(QElement *)element {
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	UILabel *valueLabel = (UILabel *)[cell.contentView viewWithTag:A3LC_TAG_CALCULATION_FOR_VALUE];
	if (nil == valueLabel) {
		valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(178.0, 15.0, 300.0, 30.0)];
		valueLabel.tag = A3LC_TAG_CALCULATION_FOR_VALUE;
		valueLabel.backgroundColor = [UIColor clearColor];
		valueLabel.font = [UIFont boldSystemFontOfSize:25.0];
		valueLabel.textColor = [UIColor blackColor];
		[cell.contentView addSubview:valueLabel];
	}
	valueLabel.text = [A3LoanCalcString stringFromCalculationFor:self.preferences.calculationFor];
	cell.textLabel.font = [A3UIStyle fontForTableViewEntryCellLabel];
	cell.textLabel.textColor = [A3UIStyle colorForTableViewCellLabelNormal];
	cell.detailTextLabel.font = [UIFont systemFontOfSize:20.0];
}

-(void)sectionHeaderWillAppearForSection:(QSection *)section atIndex:(NSInteger)index {
	if (index == 2) {
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

#pragma mark -
#pragma mark - Override UIViewController

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[[EKKeyboardAvoidingScrollViewManager sharedInstance] registerScrollViewForKeyboardAvoiding:self.quickDialogTableView];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidShow:)
												 name:UIKeyboardDidShowNotification object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidHide:)
												 name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];

	[[EKKeyboardAvoidingScrollViewManager sharedInstance] unregisterScrollViewFromKeyboardAvoiding:self.quickDialogTableView];

	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardDidHide:(NSNotification*)aNotification {
	_dateKeyboardViewController = nil;
	_numberKeyboardViewController = nil;
	_frequencyKeyboardViewController = nil;
}

- (void)keyboardDidShow:(NSNotification *)notification {
	if ([_extraPaymentYearlyMonth isFirstResponder]) {
		[self scrollToRowAtElementWithKey:A3LC_KEY_EXTRA_PAYMENT_YEARLY];
	} else if ([_extraPaymentOneTimeYearMonth isFirstResponder]) {
		[self scrollToRowAtElementWithKey:A3LC_KEY_EXTRA_PAYMENT_ONETIME];
	}
}

- (void)scrollToRowAtElementWithKey:(NSString *)key {
	QElement *element = [self.quickDialogTableView.root elementWithKey:key];
	UITableViewCell *cell = [self.quickDialogTableView cellForElement:element];
	NSIndexPath *indexPath = [self.quickDialogTableView indexPathForCell:cell];

	[self.quickDialogTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

#pragma mark - Entry Cell delegate

- (void)QEntryDidBeginEditingElement:(QEntryElement *)element  andCell:(QEntryTableViewCell *)cell {
	_editingElement = element;
	cell.backgroundColor = [UIColor whiteColor];

	if ([_keysForCurrency indexOfObject:element.key] != NSNotFound) {
		cell.textField.inputView = self.numberKeyboardViewController.view;
		_numberKeyboardViewController.keyInputDelegate = cell.textField;
		_numberKeyboardViewController.entryTableViewCell = cell;
		_numberKeyboardViewController.element = element;
		_numberKeyboardViewController.keyboardType = A3NumberKeyboardTypeCurrency;

		cell.textField.text = [cell.textField.text stringByDecimalConversion];

		[_numberKeyboardViewController reloadPrevNextButtons];
	}

	LoanCalcHistory *object = self.editingObject;

	A3LoanCalculatorEntry entry = (A3LoanCalculatorEntry) [[_enumForEntryKeys objectForKey:element.key] unsignedIntegerValue];
	switch (entry) {
		case A3LCEntryPrincipal:
		case A3LCEntryMonthlyPayment:
		case A3LCEntryDownPayment:
			break;
		case A3LCEntryTerm: {
			[self prepareYearMonthInput:cell];
			_numberKeyboardViewController.keyboardType = A3NumberKeyboardTypeMonthYear;
			_numberKeyboardViewController.bigButton1.selected = !object.termTypeMonth.boolValue;
			_numberKeyboardViewController.bigButton2.selected = object.termTypeMonth.boolValue;
			_numberKeyboardViewController.entryTableViewCell = cell;
			_numberKeyboardViewController.element = element;
			[_numberKeyboardViewController reloadPrevNextButtons];
			break;
		}
		case A3LCEntryInterestRate: {
			[self prepareYearMonthInput:cell];
			_numberKeyboardViewController.keyboardType = A3NumberKeyboardTypeInterestRate;
			_numberKeyboardViewController.bigButton1.selected = object.interestRatePerYear.boolValue;
			_numberKeyboardViewController.bigButton1.selected = !object.interestRatePerYear.boolValue;
			_numberKeyboardViewController.entryTableViewCell = cell;
			_numberKeyboardViewController.element = element;
			[_numberKeyboardViewController reloadPrevNextButtons];
			break;
		}
		case A3LCEntryFrequency: {
			[self prepareTemporaryEditingLabelForCell:cell];
			if ([object.frequency unsignedIntegerValue] == 0) {
				object.frequency = [NSNumber numberWithUnsignedInteger:A3LoanCalcFrequencyMonthly];
			}
			cell.textField.text = [A3LoanCalcString stringForFrequencyValue:object.frequency];
			_temporaryLabelForEditing.text = cell.textField.text;
			[cell.textField addSubview:_temporaryLabelForEditing];

			cell.textField.clearButtonMode = UITextFieldViewModeNever;

			cell.textField.inputView = self.frequencyKeyboardViewController.view;
			_frequencyKeyboardViewController.entryTableViewCell = cell;
			_frequencyKeyboardViewController.element = element;
			[_frequencyKeyboardViewController setSelectedFrequency:object.frequency];
			[_frequencyKeyboardViewController reloadPrevNextButtons];
			break;
		}
		case A3LCEntryStartDate: {
			if (object.startDate == nil) {
				object.startDate = [NSDate date];
			}
			cell.textField.inputView = self.dateKeyboardViewController.view;
			[self prepareTemporaryEditingLabelForCell:cell];
			_dateKeyboardViewController.element = element;
			_dateKeyboardViewController.entryTableViewCell = cell;
			_dateKeyboardViewController.displayLabel = _temporaryLabelForEditing;
			_dateKeyboardViewController.date = object.startDate;
			[_dateKeyboardViewController resetToDefaultState];

			cell.textField.text = [A3Formatter mediumStyleDateStringFromDate:object.startDate];
			_temporaryLabelForEditing.text = cell.textField.text;
			[cell.textField addSubview:_temporaryLabelForEditing];

			cell.textField.clearButtonMode = UITextFieldViewModeNever;

			[_dateKeyboardForMonthInput reloadPrevNextButtons];
			break;
		}
		case A3LCEntryNotes:break;
		case A3LCEntryExtraPaymentMonthly:break;
		case A3LCEntryExtraPaymentYearly:break;
		case A3LCEntryExtraPaymentOneTime:break;
		default:break;
	}
	cell.textField.inputAccessoryView = nil;
}

- (void)QEntryEditingChangedForElement:(QEntryElement *)element andCell:(QEntryTableViewCell *)cell {
	LoanCalcHistory *object = self.editingObject;

	A3LoanCalculatorEntry entry = (A3LoanCalculatorEntry) [[_enumForEntryKeys objectForKey:element.key] unsignedIntegerValue];
	switch (entry) {
		case A3LCEntryPrincipal:
		case A3LCEntryMonthlyPayment:
		case A3LCEntryDownPayment:
		case A3LCEntryExtraPaymentMonthly:
		case A3LCEntryExtraPaymentYearly:
		case A3LCEntryExtraPaymentOneTime:
			element.textValue = [self currencyFormattedString:cell.textField.text];
			[object setValue:element.textValue forKey:element.key];
			break;
		case A3LCEntryTerm:
			[self updateTermValueFromTextField:element text:cell.textField.text object:object];
			break;
		case A3LCEntryInterestRate:
			[self updateInterestValueFromTextField:element text:cell.textField.text object:object];
			break;
		case A3LCEntryNotes:
			[object setValue:cell.textField.text forKey:element.key];
			break;
		case A3LCEntryFrequency:
		case A3LCEntryStartDate:
		default:
			break;
	}
	[self calculate];
}

- (void)QEntryDidEndEditingElement:(QEntryElement *)element andCell:(QEntryTableViewCell *)cell {
	_editingElement = nil;
	cell.backgroundColor = [A3UIStyle contentsBackgroundColor];

	LoanCalcHistory *object = self.editingObject;

	A3LoanCalculatorEntry entry = (A3LoanCalculatorEntry) [[_enumForEntryKeys objectForKey:element.key] unsignedIntegerValue];
	switch (entry) {
		case A3LCEntryPrincipal:
		case A3LCEntryMonthlyPayment:
		case A3LCEntryDownPayment:
		case A3LCEntryExtraPaymentMonthly:
		case A3LCEntryExtraPaymentYearly:
		case A3LCEntryExtraPaymentOneTime:
			element.textValue = [self currencyFormattedString:cell.textField.text];
			cell.textField.text = element.textValue;

			[object setValue:element.textValue forKey:element.key];
			break;
		case A3LCEntryTerm:
			[self updateTermValueFromTextField:element text:cell.textField.text object:object];
			cell.textField.text = element.textValue;
			break;
		case A3LCEntryInterestRate: {
			[self updateInterestValueFromTextField:element text:cell.textField.text object:object];
			cell.textField.text = element.textValue;
			break;
		}
		case A3LCEntryFrequency:{
			object.frequency = _frequencyKeyboardViewController.selectedFrequency;
			cell.textField.text = [A3LoanCalcString stringForFrequencyValue:object.frequency];
			[_temporaryLabelForEditing removeFromSuperview];
			_temporaryLabelForEditing = nil;
			break;
		}
		case A3LCEntryStartDate:
		{
			[_temporaryLabelForEditing removeFromSuperview];
			_temporaryLabelForEditing = nil;
			break;
		}
		case A3LCEntryNotes:
			[object setValue:cell.textField.text forKey:element.key];
			break;
		default:break;
	}
	[self calculate];
}

- (void)updateTermValueFromTextField:(QEntryElement *)termElement text:(NSString *)text object:(LoanCalcHistory *)object {
	NSNumberFormatter *decimalStyleNumberFormatter = [[NSNumberFormatter alloc] init];
	[decimalStyleNumberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	float value = [text floatValue];
	object.termTypeMonth = [NSNumber numberWithBool:_numberKeyboardViewController.bigButton2.selected];
	if (value == 0.0) {
		termElement.textValue = @"";
	} else {
		termElement.textValue = _numberKeyboardViewController.bigButton1.selected ?
				[A3LoanCalcString stringFromTermInYears:value] : [A3LoanCalcString stringFromTermInMonths:value];
	}
	object.term = termElement.textValue;
}

- (void)updateInterestValueFromTextField:(QEntryElement *)element text:(NSString *)text object:(LoanCalcHistory *)object {
	float value = [text floatValue] / 100.0;
	object.interestRatePerYear = [NSNumber numberWithBool:_numberKeyboardViewController.bigButton1.selected];
	if (value != 0.0) {
		NSString *termType = _numberKeyboardViewController.bigButton1.selected ? @"Annual" : @"Monthly";
		element.textValue = [NSString stringWithFormat:@"%@ %@", termType, [self.percentNumberFormatter stringFromNumber:[NSNumber numberWithFloat:value]]];
	} else {
		element.textValue = @"";
	}
	object.interestRate = element.textValue;
}

- (void)prepareTemporaryEditingLabelForCell:(QEntryTableViewCell *)cell {
	_temporaryLabelForEditing = [[UILabel alloc] initWithFrame:cell.textField.bounds];
	_temporaryLabelForEditing.backgroundColor = [UIColor whiteColor];
	_temporaryLabelForEditing.textColor = cell.textField.textColor;
	_temporaryLabelForEditing.font = cell.textField.font;
 }

- (void)dateKeyboardValueChangedDate:(NSDate *)date element:(QEntryElement *)element {
	if ([element.key isEqualToString:A3LC_KEY_START_DATE]) {
		self.editingObject.startDate = date;
		QEntryTableViewCell *cell = (QEntryTableViewCell *) [self.quickDialogTableView cellForElement:element];
		cell.textField.text = [A3Formatter mediumStyleDateStringFromDate:date];
	} else if ([_extraPaymentYearlyMonth isFirstResponder]) {
		_extraPaymentYearlyMonth.text = [A3Formatter fullStyleMonthSymbolFromDate:date];
	} else if ([_extraPaymentOneTimeYearMonth isFirstResponder]) {
		_extraPaymentOneTimeYearMonth.text = [A3Formatter fullStyleYearMonthStringFromDate:date];
	}
}

- (void)frequencySelected:(NSNumber *)frequencyObject cell:(QEntryTableViewCell *)cell {
	self.editingObject.frequency = frequencyObject;
	cell.textField.text = [A3LoanCalcString stringForFrequencyValue:frequencyObject];
	_temporaryLabelForEditing.text = cell.textField.text;
}

- (void)prepareYearMonthInput:(QEntryTableViewCell *)cell {
	cell.textField.inputView = self.numberKeyboardViewController.view;
	_numberKeyboardViewController.keyInputDelegate = cell.textField;
	_numberKeyboardViewController.entryTableViewCell = cell;
    
	cell.textField.text = [cell.textField.text stringByDecimalConversion];
}

- (NSString *)currencyFormattedString:(NSString *)source {
	if ([source floatValue] == 0.0) return @"";
	return [self.currencyNumberFormatter stringFromNumber:[NSNumber numberWithFloat:[source floatValue]]];
}

- (void)clearButtonPressed {
	if (_editingElement) {
		QEntryTableViewCell *cell = (QEntryTableViewCell *)[self.quickDialogTableView cellForElement:_editingElement];
		cell.textField.text = @"";
		_editingElement.textValue = @"";
		[self.editingObject setValue:@"" forKey:_editingElement.key];
	}
}

#pragma mark - Button actions

- (void)onSimpleAdvanced:(QButtonElement *)buttonElement {
	[_extraPaymentYearlyMonth resignFirstResponder];
	[_extraPaymentOneTimeYearMonth resignFirstResponder];

	UITableViewCell *cell = [self.quickDialogTableView cellForElement:buttonElement];
	[self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexPathForCell:cell] animated:YES];

	QSection *section = [self.root.sections objectAtIndex:1];
	NSUInteger insertIndex = self.preferences.showDownPayment ? 4 : 3;
	if (!self.preferences.showAdvanced) {
		[section insertElement:[self frequencyElement] atIndex:insertIndex];
		[section insertElement:[self startDateElement] atIndex:insertIndex + 1];
		[section insertElement:[self notesElement] atIndex:insertIndex + 2];

		NSArray *addedRows = @[[NSIndexPath indexPathForRow:insertIndex inSection:1], [NSIndexPath indexPathForRow:insertIndex + 1 inSection:1], [NSIndexPath indexPathForRow:insertIndex + 2 inSection:1]];
		[self.quickDialogTableView insertRowsAtIndexPaths:addedRows withRowAnimation:UITableViewRowAnimationBottom];

		[self.preferences setShowAdvanced:YES];
		cell.textLabel.text = @"Simple";
	}
	else
	{
		[section.elements removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(insertIndex,3)]];
		[self.quickDialogTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:insertIndex inSection:1], [NSIndexPath indexPathForRow:insertIndex + 1 inSection:1], [NSIndexPath indexPathForRow:insertIndex + 2 inSection:1]] withRowAnimation:UITableViewRowAnimationMiddle];

		cell.textLabel.text = @"Advanced";
		[self.preferences setShowAdvanced:NO];
	}
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

	[_frequencyKeyboardViewController rotateToInterfaceOrientation:toInterfaceOrientation];
	[_numberKeyboardViewController rotateToInterfaceOrientation:toInterfaceOrientation];
	[_dateKeyboardViewController rotateToInterfaceOrientation:toInterfaceOrientation];
}

- (BOOL)prevAvailableForElement:(QEntryElement *)element {
	return ![element.key isEqualToString:A3LC_KEY_PRINCIPAL];
}

- (BOOL)nextAvailableForElement:(QEntryElement *)element {
	if (self.preferences.showExtraPayment) {
		return _dateKeyboardForYearMonthInput == nil;
	}
	if (self.preferences.showAdvanced) {
		return ![element.key isEqualToString:A3LC_KEY_NOTES];
	}
	return ![element.key isEqualToString:A3LC_KEY_INTEREST_RATE];
}

- (void)nextButtonPressedWithElement:(QEntryElement *)element {
	if ([element.key isEqualToString:A3LC_KEY_EXTRA_PAYMENT_YEARLY]) {
		[_extraPaymentYearlyMonth becomeFirstResponder];
	} else if ([element.key isEqualToString:A3LC_KEY_EXTRA_PAYMENT_ONETIME]) {
		[_extraPaymentOneTimeYearMonth becomeFirstResponder];
	} else if ([_extraPaymentYearlyMonth isFirstResponder]) {
		QElement *oneTimeElement = [self.quickDialogTableView.root elementWithKey:A3LC_KEY_EXTRA_PAYMENT_ONETIME];
		QEntryTableViewCell *cell = (QEntryTableViewCell *) [self.quickDialogTableView cellForElement:oneTimeElement];
		[cell becomeFirstResponder];
	} else {
		QEntryTableViewCell *cell = (QEntryTableViewCell *)[self.quickDialogTableView cellForElement:element];
		[cell handlePrevNextWithForNext:YES];
	}
}

- (void)prevButtonPressedWithElement:(QEntryElement *)element {
	if ([element.key isEqualToString:A3LC_KEY_EXTRA_PAYMENT_ONETIME]) {
		[_extraPaymentYearlyMonth becomeFirstResponder];
	} else if ([_extraPaymentOneTimeYearMonth isFirstResponder]) {
		QElement *prevElement = [self.quickDialogTableView.root elementWithKey:A3LC_KEY_EXTRA_PAYMENT_ONETIME];
		QEntryTableViewCell *cell = (QEntryTableViewCell *)[self.quickDialogTableView cellForElement:prevElement];
		[cell becomeFirstResponder];
	} else if ([_extraPaymentYearlyMonth isFirstResponder]) {
		QElement *prevElement = [self.quickDialogTableView.root elementWithKey:A3LC_KEY_EXTRA_PAYMENT_YEARLY];
		QEntryTableViewCell *cell = (QEntryTableViewCell *)[self.quickDialogTableView cellForElement:prevElement];
		[cell becomeFirstResponder];
	} else {
		QEntryTableViewCell *cell = (QEntryTableViewCell *)[self.quickDialogTableView cellForElement:element];
		[cell handlePrevNextWithForNext:NO];
	}
}

- (void)A3KeyboardViewControllerDoneButtonPressed {
	if (_editingElement) {
		QEntryTableViewCell *cell = (QEntryTableViewCell *)[self.quickDialogTableView cellForElement:_editingElement];
		[cell handleActionBarDone:nil];
	} else if ([_extraPaymentYearlyMonth isFirstResponder]) {
		[_extraPaymentYearlyMonth resignFirstResponder];
	} else if ([_extraPaymentOneTimeYearMonth isFirstResponder]) {
		[_extraPaymentOneTimeYearMonth resignFirstResponder];
	}
}

#pragma mark - Implement UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	if (textField == _extraPaymentYearlyMonth) {
		textField.inputView = self.dateKeyboardForMonthInput.view;
	} else if (textField == _extraPaymentOneTimeYearMonth) {
		textField.inputView = self.dateKeyboardForYearMonthInput.view;
	}
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if (textField == _extraPaymentYearlyMonth) {
		_dateKeyboardForMonthInput = nil;
	} else if (textField == _extraPaymentOneTimeYearMonth) {
		_dateKeyboardForYearMonthInput = nil;
	}
}

- (void)reloadGraphView {
	LoanCalcHistory *object = self.editingObject;
	float principal = [object.principal floatValueEx];
	float monthlyPayment = [object.monthlyPayment floatValueEx];
	float termInMonth = self.editingObject.termInMonth;
	float totalAmount = monthlyPayment * termInMonth;
	float totalInterest = totalAmount - principal;
	float monthlyAverageInterest = totalInterest / termInMonth;

	_tableHeaderViewController.totalAmount = [NSNumber numberWithFloat:totalAmount];
	_tableHeaderViewController.principal = [NSNumber numberWithFloat:principal];
	_tableHeaderViewController.totalInterest = [NSNumber numberWithFloat:totalInterest];
	_tableHeaderViewController.monthlyPayment = [NSNumber numberWithFloat:monthlyPayment];
	_tableHeaderViewController.monthlyAverageInterest = [NSNumber numberWithFloat:monthlyAverageInterest];
	[_tableHeaderViewController reloadData];
}

- (void)calculate {
	[self.editingObject calculate];
	NSString *value;
	switch (self.preferences.calculationFor) {
		case A3_LCCF_MonthlyPayment:
			value = _editingObject.monthlyPayment;
			break;
		case A3_LCCF_Principal:
			value = _editingObject.principal;
			break;
		case A3_LCCF_DownPayment:
			value = _editingObject.downPayment;
			break;
		case A3_LCCF_TermMonths:
		case A3_LCCF_TermYears:
			value = _editingObject.term;
			break;
	}
	[self reloadResultRowWithValue:value];
	[self reloadGraphView];
}

- (void)reloadResultRowWithValue:(NSString *)value {
	QSection *section = [self.root.sections objectAtIndex:0];
	QLabelElement *element = [section.elements objectAtIndex:0];
	element.value = value;
	[self.quickDialogTableView reloadCellForElements:element, nil];
}

@end
