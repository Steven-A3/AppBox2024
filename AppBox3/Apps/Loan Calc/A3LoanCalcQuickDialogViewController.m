//  A3LoanCalcQuickDialogViewController.m
//  AppBox3
//
//
//  Created by Byeong Kwon Kwak on 2/16/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcQuickDialogViewController.h"
#import "A3UIKit.h"
#import "CommonUIDefinitions.h"
#import "A3AppDelegate.h"
#import "A3LoanCalcString.h"
#import "A3Formatter.h"
#import "A3ButtonTextField.h"
#import "QEntryTableViewCell+Extension.h"
#import "common.h"
#import "NSString+conversion.h"
#import "UIViewController+A3AppCategory.h"
#import "A3UIDevice.h"
#import "A3LoanCalcPieChartController.h"
#import "NSManagedObject+Clone.h"


#define A3LC_CONTROLLER_NAME		@"A3LoanCalcQuickDialogViewController"

#define A3LC_TAG_CALCULATION_FOR_VALUE 7667001	// L = 76, 67 = C, 001 = id for view tag

@interface A3LoanCalcQuickDialogViewController ()
@property (nonatomic, strong)	NSMutableDictionary *enumForEntryKeys;
@property (nonatomic, weak)		QEntryElement *editingElement;
@property (nonatomic, strong)	UILabel *temporaryLabelForEditing;
@property (nonatomic, strong)	A3ButtonTextField *extraPaymentYearlyMonth, *extraPaymentOneTimeYearMonth;

@end

@implementation A3LoanCalcQuickDialogViewController

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

	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	self.quickDialogTableView.tableHeaderView = self.tableHeaderView;
	[self reloadGraphView];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];

	[self addDataToHistory];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

	FNLOGRECT(self.view.frame);
}

- (A3LoanCalcPieChartController *)chartController {
	if (nil == _chartController) {
		_chartController = [[A3LoanCalcPieChartController alloc] init];
		_chartController.backgroundColor = self.tableViewBackgroundColor;
	}
	return _chartController;
}

- (UIView *)tableHeaderView {
	return nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

	[self.quickDialogTableView reloadData];
}

- (A3LoanCalcPreferences *)preferences {
	if (nil == _preferences) {
		_preferences = [[A3LoanCalcPreferences alloc] init];
	}
	return _preferences;
}

- (QElement *)calculationForElement {
	return nil;
}

- (QSection *)mainSection {
	// Section : Input values
	QSection *section = [[QSection alloc] init];

	A3LoanCalcCalculationFor calculationFor = self.preferences.calculationFor;

	switch (calculationFor) {
		case A3_LCCF_MonthlyPayment:
			[section addElement:[self principalElement]];
			if (self.preferences.showDownPayment) [section addElement:[self downPaymentElement]];
			[section addElement:[self termElement]];
			break;
		case A3_LCCF_DownPayment:
			[section addElement:[self principalElement]];
			[section addElement:[self monthlyPaymentElement]];
			[section addElement:[self termElement]];
			break;
		case A3_LCCF_Principal:
			if (self.preferences.showDownPayment) [section addElement:[self downPaymentElement]];
			[section addElement:[self monthlyPaymentElement]];
			[section addElement:[self termElement]];
			break;
		case A3_LCCF_TermYears:
		case A3_LCCF_TermMonths:
			[section addElement:[self principalElement]];
			if (self.preferences.showDownPayment) [section addElement:[self downPaymentElement]];
			[section addElement:[self monthlyPaymentElement]];
			break;
	}

	[section addElement:[self interestRateElement]];

	if (self.preferences.showAdvanced) {
		[section addElement:[self frequencyElement]];
		[section addElement:[self startDateElement]];
		[section addElement:[self notesElement]];
	}
	[section addElement:[self typeChangeButtonElement]];
	return section;
}

- (QRootElement *)rootElement {
	QRootElement *root = [[QRootElement alloc] init];

	_enumForEntryKeys = [[NSMutableDictionary alloc] init];

	root.controllerName = A3LC_CONTROLLER_NAME;
	root.grouped = YES;

	QSection *section1 = [[QSection alloc] init];
	[section1 addElement:self.calculationForElement];

	[root addSection:section1];
	[root addSection:self.mainSection];

	if (self.preferences.showExtraPayment) {
		// Section 3: Extra Payments
		QSection *section3 = [[QSection alloc] initWithTitle:@"Extra Payments"];
		[section3 addElement:[self extraPaymentMonthly]];
		[section3 addElement:[self extraPaymentYearly]];
		[section3 addElement:[self extraPaymentOneTime]];

		[root addSection:section3];
	}

	return root;
}

// Section 3
- (QEntryElement *)extraPaymentOneTime {
	A3CurrencyEntryElement *extraPaymentOneTime = [[A3CurrencyEntryElement alloc] initWithTitle:NSLocalizedString(@"One-Time", @"One-Time") Value:@"" Placeholder:[self zeroCurrency]];
	extraPaymentOneTime.key = A3LC_KEY_EXTRA_PAYMENT_ONETIME;
	extraPaymentOneTime.delegate = self;
	extraPaymentOneTime.cellStyleDelegate = self;
	[_enumForEntryKeys setObject:[NSNumber numberWithUnsignedInteger:A3LCEntryExtraPaymentOneTime] forKey:A3LC_KEY_EXTRA_PAYMENT_ONETIME];
	return extraPaymentOneTime;
}

- (QEntryElement *)extraPaymentYearly {
	A3CurrencyEntryElement *extraPaymentYearly = [[A3CurrencyEntryElement alloc] initWithTitle:NSLocalizedString(@"Yearly", @"Yearly") Value:@"" Placeholder:[self zeroCurrency]];
	extraPaymentYearly.key = A3LC_KEY_EXTRA_PAYMENT_YEARLY;
	extraPaymentYearly.delegate = self;
	extraPaymentYearly.cellStyleDelegate = self;
	[_enumForEntryKeys setObject:[NSNumber numberWithUnsignedInteger:A3LCEntryExtraPaymentYearly] forKey:A3LC_KEY_EXTRA_PAYMENT_YEARLY];
	return extraPaymentYearly;
}

- (QEntryElement *)extraPaymentMonthly {
	A3CurrencyEntryElement *extraPaymentMonthly = [[A3CurrencyEntryElement alloc] initWithTitle:NSLocalizedString(@"Monthly", @"Monthly") Value:@"" Placeholder:[self zeroCurrency]];
	extraPaymentMonthly.key = A3LC_KEY_EXTRA_PAYMENT_MONTHLY;
	extraPaymentMonthly.delegate = self;
	extraPaymentMonthly.cellStyleDelegate = self;
	[_enumForEntryKeys setObject:[NSNumber numberWithUnsignedInteger:A3LCEntryExtraPaymentMonthly] forKey:A3LC_KEY_EXTRA_PAYMENT_MONTHLY];
	return extraPaymentMonthly;
}

- (QButtonElement *)typeChangeButtonElement {
	NSString *buttonTitle =	self.preferences.showAdvanced ? @"Simple" : @"Advanced";
	A3ButtonElement *simpleAdvancedButton = [[A3ButtonElement alloc] initWithTitle:buttonTitle];
	simpleAdvancedButton.cellStyleDelegate = self;
	simpleAdvancedButton.key = A3LC_KEY_SIMPLE_ADVANCED;
	simpleAdvancedButton.onSelected = ^{
		[self onSimpleAdvanced];
	};
	return simpleAdvancedButton;
}

- (QEntryElement *)notesElement {
	A3EntryElement *notes = [[A3EntryElement alloc] initWithTitle:NSLocalizedString(@"Notes", @"Notes") Value:@"" Placeholder:@"(Optional)"];
	notes.key = A3LC_KEY_NOTES;
	notes.delegate = self;
	notes.cellStyleDelegate = self;
	[_enumForEntryKeys setObject:[NSNumber numberWithUnsignedInteger:A3LCEntryNotes] forKey:A3LC_KEY_NOTES];
	return notes;
}

- (QEntryElement *)startDateElement {
	A3DateEntryElement *startDate = [[A3DateEntryElement alloc] initWithTitle:NSLocalizedString(@"Start Date", @"Start Date") Value:@"" Placeholder:[A3UIKit mediumStyleDateString:[NSDate date]]];
	startDate.key = A3LC_KEY_START_DATE;
	startDate.delegate = self;
	startDate.cellStyleDelegate = self;
	[_enumForEntryKeys setObject:[NSNumber numberWithUnsignedInteger:A3LCEntryStartDate] forKey:A3LC_KEY_START_DATE];
	return startDate;
}

- (QEntryElement *)frequencyElement {
	A3FrequencyEntryElement *frequency = [[A3FrequencyEntryElement alloc] initWithTitle:NSLocalizedString(@"Frequency", @"Frequency") Value:@"" Placeholder:@"Monthly"];
	frequency.key = A3LC_KEY_FREQUENCY;
	frequency.delegate = self;
	frequency.cellStyleDelegate = self;
	[_enumForEntryKeys setObject:[NSNumber numberWithUnsignedInteger:A3LCEntryFrequency] forKey:A3LC_KEY_FREQUENCY];
	return frequency;
}

- (QEntryElement *)interestRateElement {
	A3InterestEntryElement *interestRate = [[A3InterestEntryElement alloc] initWithTitle:NSLocalizedString(@"Interest Rate", @"Interest Rate") Value:@"" Placeholder:@"Annual 0%"];
	interestRate.key = A3LC_KEY_INTEREST_RATE;
	interestRate.delegate = self;
	interestRate.cellStyleDelegate = self;
	[_enumForEntryKeys setObject:[NSNumber numberWithUnsignedInteger:A3LCEntryInterestRate] forKey:A3LC_KEY_INTEREST_RATE];
	return interestRate;
}

- (QEntryElement *)principalElement {
	A3CurrencyEntryElement *principalElement = [[A3CurrencyEntryElement alloc] initWithTitle:NSLocalizedString(@"Principal", @"Principal") Value:@"" Placeholder:@"$0.00"];
	principalElement.key = A3LC_KEY_PRINCIPAL;
	principalElement.delegate = self;
	principalElement.cellStyleDelegate = self;
	[_enumForEntryKeys setObject:[NSNumber numberWithUnsignedInteger:A3LCEntryPrincipal] forKey:A3LC_KEY_PRINCIPAL];
	return principalElement;
}

- (QEntryElement *)monthlyPaymentElement {
	A3CurrencyEntryElement *monthlyPaymentElement = [[A3CurrencyEntryElement alloc] initWithTitle:@"Monthly Payment" Value:@"" Placeholder:@"$0.00"];
	monthlyPaymentElement.key = A3LC_KEY_MONTHLY_PAYMENT;
	monthlyPaymentElement.delegate = self;
	monthlyPaymentElement.cellStyleDelegate = self;
	[_enumForEntryKeys setObject:[NSNumber numberWithUnsignedInteger:A3LCEntryMonthlyPayment] forKey:A3LC_KEY_MONTHLY_PAYMENT];
	return monthlyPaymentElement;
}

- (QEntryElement *)termElement {
	A3TermEntryElement *termElement = [[A3TermEntryElement alloc] initWithTitle:NSLocalizedString(@"Term", @"Term") Value:@"" Placeholder:@"years or months"];
	termElement.key = A3LC_KEY_TERM;
	termElement.delegate = self;
	termElement.cellStyleDelegate = self;
	[_enumForEntryKeys setObject:[NSNumber numberWithUnsignedInteger:A3LCEntryTerm] forKey:A3LC_KEY_TERM];
	return termElement;
}

- (QEntryElement *)downPaymentElement {
	A3CurrencyEntryElement *downPaymentElement = [[A3CurrencyEntryElement alloc] initWithTitle:@"Down Payment" Value:@"" Placeholder:[self zeroCurrency]];
	downPaymentElement.key = A3LC_KEY_DOWN_PAYMENT;
	downPaymentElement.delegate = self;
	downPaymentElement.cellStyleDelegate = self;
	[_enumForEntryKeys setObject:[NSNumber numberWithUnsignedInteger:A3LCEntryDownPayment] forKey:A3LC_KEY_DOWN_PAYMENT];
	return downPaymentElement;
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
	[super cell:cell willAppearForElement:element atIndexPath:indexPath];

	cell.accessoryView = nil;

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

- (void)configureSection2Cell:(UITableViewCell *)cell withElement:(QElement *)element {
	if ([element.key isEqualToString:A3LC_KEY_EXTRA_PAYMENT_YEARLY]) {
		cell.accessoryView = self.extraPaymentYearlyMonth;
	} else if ([element.key isEqualToString:A3LC_KEY_EXTRA_PAYMENT_ONETIME]) {
		cell.accessoryView = self.extraPaymentOneTimeYearMonth;
	}
}

- (void)configureSection1Cell:(UITableViewCell *)cell withElement:(QElement *)element {

	if ([cell isKindOfClass:[QEntryTableViewCell class]]) {
		LoanCalcHistory *object = self.editingObject;

		QEntryTableViewCell *entryTableViewCell = (QEntryTableViewCell *)cell;

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
	QSection *section = [self.quickDialogTableView.root.sections objectAtIndex:0];
	if ([section.elements count] == 1) {
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	if (DEVICE_IPAD) {
		cell.textLabel.font = [UIFont systemFontOfSize:25.0];

		A3LabelElement *labelElement = (A3LabelElement *) element;
		UILabel *valueLabel = (UILabel *) [cell.contentView viewWithTag:A3LC_TAG_CALCULATION_FOR_VALUE];
		if ([labelElement.centerValue length]) {
			if (nil == valueLabel) {
				valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(196.0, 15.0, 300.0, 30.0)];
				valueLabel.tag = A3LC_TAG_CALCULATION_FOR_VALUE;
				valueLabel.backgroundColor = [UIColor clearColor];
				valueLabel.font = [UIFont boldSystemFontOfSize:25.0];
				valueLabel.textColor = [UIColor blackColor];
				[cell.contentView addSubview:valueLabel];
			}
			valueLabel.text = labelElement.centerValue;
		} else {
			valueLabel.text = nil;
		}
	}
}


#pragma mark -
#pragma mark - Override UIViewController

- (void)keyboardDidHide:(NSNotification*)aNotification {
	self.dateKeyboardViewController = nil;
	self.numberKeyboardViewController = nil;
	self.dateKeyboardViewController = nil;
}

- (void)keyboardDidShow:(NSNotification *)notification {
	if ([_extraPaymentYearlyMonth isFirstResponder]) {
		[self scrollToRowAtElementWithKey:A3LC_KEY_EXTRA_PAYMENT_YEARLY];
	} else if ([_extraPaymentOneTimeYearMonth isFirstResponder]) {
		[self scrollToRowAtElementWithKey:A3LC_KEY_EXTRA_PAYMENT_ONETIME];
	} else {
		NSIndexPath *indexPath = [self.editingElement getIndexPath];
		if (indexPath.section == 2) {
			[self scrollToRowAtElementWithKey:self.editingElement.key];
		}
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
	FNLOG(@"Check");
	[super QEntryDidBeginEditingElement:element andCell:cell];

	LoanCalcHistory *object = self.editingObject;

	A3LoanCalculatorEntry entry = (A3LoanCalculatorEntry) [[_enumForEntryKeys objectForKey:element.key] unsignedIntegerValue];
	switch (entry) {
		case A3LCEntryPrincipal:
		case A3LCEntryMonthlyPayment:
		case A3LCEntryDownPayment:
			break;
		case A3LCEntryTerm: {
			self.numberKeyboardViewController.bigButton1.selected = !object.termTypeMonth.boolValue;
			self.numberKeyboardViewController.bigButton2.selected = object.termTypeMonth.boolValue;
			break;
		}
		case A3LCEntryInterestRate: {
			self.numberKeyboardViewController.bigButton1.selected = object.interestRatePerYear.boolValue;
			self.numberKeyboardViewController.bigButton1.selected = !object.interestRatePerYear.boolValue;
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

			[self.frequencyKeyboardViewController setSelectedFrequency:object.frequency];
			break;
		}
		case A3LCEntryStartDate: {
			if (object.startDate == nil) {
				object.startDate = [NSDate date];
			}
			[self prepareTemporaryEditingLabelForCell:cell];
			self.dateKeyboardViewController.displayLabel = _temporaryLabelForEditing;
			self.dateKeyboardViewController.date = object.startDate;

			cell.textField.text = [A3Formatter mediumStyleDateStringFromDate:object.startDate];
			_temporaryLabelForEditing.text = cell.textField.text;
			[cell.textField addSubview:_temporaryLabelForEditing];

			break;
		}
		case A3LCEntryNotes:break;
		case A3LCEntryExtraPaymentMonthly:break;
		case A3LCEntryExtraPaymentYearly:break;
		case A3LCEntryExtraPaymentOneTime:break;
		default:break;
	}
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
	FNLOG(@"%d", object.hasChanges);
	[self calculate];
	FNLOG(@"%d", object.hasChanges);
}

- (void)QEntryDidEndEditingElement:(QEntryElement *)element andCell:(QEntryTableViewCell *)cell {
	[super QEntryDidEndEditingElement:element andCell:cell];

	LoanCalcHistory *object = self.editingObject;

	A3LoanCalculatorEntry entry = (A3LoanCalculatorEntry) [[_enumForEntryKeys objectForKey:element.key] unsignedIntegerValue];
	switch (entry) {
		case A3LCEntryPrincipal:
		case A3LCEntryMonthlyPayment:
		case A3LCEntryDownPayment:
		case A3LCEntryExtraPaymentMonthly:
		case A3LCEntryExtraPaymentYearly:
		case A3LCEntryExtraPaymentOneTime:
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
			object.frequency = self.frequencyKeyboardViewController.selectedFrequency;
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
	FNLOG(@"%d", _editingObject.hasChanges);
	[self calculate];
	FNLOG(@"%d", _editingObject.hasChanges);

	[self addDataToHistory];
}

- (void)updateTermValueFromTextField:(QEntryElement *)termElement text:(NSString *)text object:(LoanCalcHistory *)object {
	NSNumberFormatter *decimalStyleNumberFormatter = [[NSNumberFormatter alloc] init];
	[decimalStyleNumberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	float value = [text floatValue];
	object.termTypeMonth = [NSNumber numberWithBool:self.numberKeyboardViewController.bigButton2.selected];
	if (value == 0.0) {
		termElement.textValue = @"";
	} else {
		termElement.textValue = self.numberKeyboardViewController.bigButton1.selected ?
				[A3LoanCalcString stringFromTermInYears:value] : [A3LoanCalcString stringFromTermInMonths:value];
	}
	object.term = termElement.textValue;
}

- (void)updateInterestValueFromTextField:(QEntryElement *)element text:(NSString *)text object:(LoanCalcHistory *)object {
	float value = [text floatValue] / 100.0;
	object.interestRatePerYear = [NSNumber numberWithBool:self.numberKeyboardViewController.bigButton1.selected];
	if (value != 0.0) {
		NSString *termType = self.numberKeyboardViewController.bigButton1.selected ? @"Annual" : @"Monthly";
		element.textValue = [NSString stringWithFormat:@"%@ %@", termType, [self.percentFormatter stringFromNumber:[NSNumber numberWithFloat:value]]];
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
	_temporaryLabelForEditing.textAlignment = UITextAlignmentRight;
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

- (void)clearButtonPressed {
	if (self.editingElement) {
		QEntryTableViewCell *cell = (QEntryTableViewCell *)[self.quickDialogTableView cellForElement:self.editingElement];
		cell.textField.text = @"";
		self.editingElement.textValue = @"";
		[self.editingObject setValue:@"" forKey:self.editingElement.key];
	}
}

#pragma mark - Button actions

- (void)onSimpleAdvanced {
	[_extraPaymentYearlyMonth resignFirstResponder];
	[_extraPaymentOneTimeYearMonth resignFirstResponder];

	QButtonElement *buttonElement = (QButtonElement *) [self.root elementWithKey:A3LC_KEY_SIMPLE_ADVANCED];
	UITableViewCell *cell = [self.quickDialogTableView cellForElement:buttonElement];
	[self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexPathForCell:cell] animated:YES];

	QSection *section = [self.quickDialogTableView.root.sections objectAtIndex:1];
	NSUInteger insertIndex = self.preferences.showDownPayment ? 4 : 3;
	if (!self.preferences.showAdvanced) {
		[section insertElement:[self frequencyElement] atIndex:insertIndex];
		[section insertElement:[self startDateElement] atIndex:insertIndex + 1];
		[section insertElement:[self notesElement] atIndex:insertIndex + 2];

		NSArray *addedRows = @[[NSIndexPath indexPathForRow:insertIndex inSection:1], [NSIndexPath indexPathForRow:insertIndex + 1 inSection:1], [NSIndexPath indexPathForRow:insertIndex + 2 inSection:1]];
		[self.quickDialogTableView insertRowsAtIndexPaths:addedRows withRowAnimation:UITableViewRowAnimationBottom];

		[self.preferences setShowAdvanced:YES];
		buttonElement.title = @"Simple";
	}
	else
	{
		[section.elements removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(insertIndex,3)]];
		[self.quickDialogTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:insertIndex inSection:1], [NSIndexPath indexPathForRow:insertIndex + 1 inSection:1], [NSIndexPath indexPathForRow:insertIndex + 2 inSection:1]] withRowAnimation:UITableViewRowAnimationMiddle];

		buttonElement.title = @"Advanced";
		[self.preferences setShowAdvanced:NO];
	}
	cell.textLabel.text = buttonElement.title;
}

- (BOOL)prevAvailableForElement:(QEntryElement *)element {
	return ![element.key isEqualToString:A3LC_KEY_PRINCIPAL];
}

- (BOOL)nextAvailableForElement:(QEntryElement *)element {
	if (self.preferences.showExtraPayment) {
		return ![_extraPaymentOneTimeYearMonth isFirstResponder];
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

- (void)A3KeyboardDoneButtonPressed {
	if (self.editingElement) {
		QEntryTableViewCell *cell = (QEntryTableViewCell *)[self.quickDialogTableView cellForElement:self.editingElement];
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
		textField.inputView = self.dateKeyboardViewController.view;
		self.dateKeyboardViewController.workingMode = A3DateKeyboardWorkingModeMonth;
	} else if (textField == _extraPaymentOneTimeYearMonth) {
		textField.inputView = self.dateKeyboardViewController.view;
		self.dateKeyboardViewController.workingMode = A3DateKeyboardWorkingModeYearMonth;
	}
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {

}

- (void)reloadGraphView {
	self.chartController.totalAmount = _editingObject.totalAmount;
	self.chartController.principal =
			[NSNumber numberWithFloat:_editingObject.principal.floatValueEx];
	self.chartController.totalInterest =
			_editingObject.totalInterest;
	self.chartController.monthlyPayment = [NSNumber numberWithFloat:_editingObject.monthlyPayment.floatValueEx];
	self.chartController.monthlyAverageInterest = _editingObject.monthlyAverageInterest;
}

- (NSString *)valueForCalculationForField {
	NSString *value;
	[self.editingObject calculate];
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
	return value;
}

- (void)calculate {
	[self reloadResultRowWithValue:self.valueForCalculationForField];
	[self reloadGraphView];
}

- (void)reloadResultRowWithValue:(NSString *)value {
	QSection *section = [self.quickDialogTableView.root.sections objectAtIndex:0];
	QLabelElement *element = [section.elements objectAtIndex:0];
	element.value = value;
	[self.quickDialogTableView reloadCellForElements:element, nil];
}

#pragma mark -- OnSelectCalculationFor

- (NSArray *)calculationForCandidates {
	BOOL showDownPayment = [self.preferences showDownPayment];
	NSMutableArray *candidate = [NSMutableArray arrayWithArray:@[
			@(A3_LCCF_MonthlyPayment),
			@(A3_LCCF_DownPayment),
			@(A3_LCCF_Principal),
			@(A3_LCCF_TermYears),
			@(A3_LCCF_TermMonths)
	]
	];
	if (!showDownPayment) [candidate removeObjectAtIndex:1];
	return candidate;
}

- (void)onSelectCalculationFor {
	QSection *section = [self.quickDialogTableView.root.sections objectAtIndex:0];

	if ([section.elements count] == 1) {
		A3LoanCalcCalculationFor calculationFor = [self.preferences calculationFor];
		NSMutableArray *rowsToInsert = [[NSMutableArray alloc] initWithCapacity:4];

		NSArray *candidate = [self calculationForCandidates];
		NSUInteger insertIndex = 0;
		for (NSNumber *item in candidate) {
			if ([item unsignedIntegerValue] == calculationFor) {
				insertIndex++;
				continue;
			}
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:insertIndex inSection:0];
			[rowsToInsert addObject:indexPath];

			A3LabelElement *element = [[A3LabelElement alloc] initWithTitle:@"" Value:@""];
			if (DEVICE_IPAD) {
				element.title = @"";
				element.centerValue = [A3LoanCalcString stringFromCalculationFor:item.unsignedIntegerValue];
			} else {
				element.title = [A3LoanCalcString stringFromCalculationFor:item.unsignedIntegerValue];
			}
			element.key = A3LC_KEY_CALCULATION_FOR;
			element.onSelected = ^{
				A3LoanCalcCalculationFor selected = (A3LoanCalcCalculationFor) item.unsignedIntegerValue;
				[self onSelectedCalculationForCandidate:selected];
			};
			[section insertElement:element atIndex:insertIndex];

			insertIndex++;
		}
		[self.quickDialogTableView insertRowsAtIndexPaths:rowsToInsert withRowAnimation:UITableViewRowAnimationBottom];
	}
}

- (void)onSelectedCalculationForCandidate:(A3LoanCalcCalculationFor)selected {
	FNLOG(@"%d", selected);
	NSArray *candidates = [self calculationForCandidates];
	NSMutableArray *rowsToDelete = [[NSMutableArray alloc] initWithCapacity:5];
	NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];

	NSUInteger index = 0;
	for (;index < [candidates count];index++) {
		if (selected == [[candidates objectAtIndex:index] unsignedIntegerValue]) {
			continue;
		}
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
		[rowsToDelete addObject:indexPath];
		[indexSet addIndex:index];
	}
	FNLOG(@"%@ %@", indexSet, rowsToDelete);

	QSection *section = [self.quickDialogTableView.root.sections objectAtIndex:0];
	[section.elements removeObjectsAtIndexes:indexSet];

	[self.quickDialogTableView deleteRowsAtIndexPaths:rowsToDelete withRowAnimation:UITableViewRowAnimationBottom];
	[self.preferences setCalculationFor:selected];

	A3LabelElement *selectedElement = [section.elements lastObject];
	if (DEVICE_IPAD) {
		selectedElement.title = @"calculation for";
	}
	selectedElement.onSelected = ^{
		[self onSelectCalculationFor];
	};
	[self.quickDialogTableView reloadCellForElements:selectedElement, nil];

	[self.quickDialogTableView.root.sections replaceObjectAtIndex:1 withObject:self.mainSection];
	[self.quickDialogTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];

	[self calculate];
}

- (BOOL)addDataToHistory {
	FNLOG(@"%@, %d", _editingObject.principal, _editingObject.hasChanges);

	if (![_editingObject hasChanges]) {
		return NO;
	}

	NSManagedObjectContext *managedObjectContext = [[A3AppDelegate instance] managedObjectContext];
	NSError *error;

	LoanCalcHistory *historyObject = (LoanCalcHistory *) [_editingObject cloneInContext:managedObjectContext];
	historyObject.created = [NSDate date];
	historyObject.editing = @NO;

	[managedObjectContext save:&error];

	FNLOG();

	return YES;
}

@end
