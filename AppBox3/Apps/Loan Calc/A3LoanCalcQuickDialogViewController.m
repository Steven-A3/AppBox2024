//
//  A3LoanCalcQuickDialogViewController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/16/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalcQuickDialogViewController.h"
#import "A3LoanCalcPieChartViewController.h"
#import "A3UIStyle.h"
#import "A3UIKit.h"
#import "CommonUIDefinitions.h"
#import "common.h"

#define A3LC_KEY_CALCULATION_FOR		@"CalculationFor"
#define A3LC_KEY_PRINCIPAL				@"Principal"
#define A3LC_KEY_DOWN_PAYMENT 			@"DownPayment"
#define A3LC_KEY_TERM					@"Term"
#define A3LC_KEY_INTEREST_RATE			@"InterestRate"
#define A3LC_KEY_FREQUENCY				@"Frequency"
#define A3LC_KEY_START_DATE				@"StartDate"
#define A3LC_KEY_NOTES					@"Notes"
#define A3LC_KEY_EXTRA_PAYMENTS_MONTHLY	@"ExtraPaymentsMonthly"
#define A3LC_KEY_EXTRA_PAYMENTS_YEARLY	@"ExtraPaymentsYearly"
#define A3LC_KEY_EXTRA_PAYMENTS_ONETIME @"ExtraPaymentsOneTime"

typedef NS_ENUM(NSUInteger, A3LoanCalculatorCalculationFor) {
	A3_LCCF_MonthlyPayment = 1,
	A3_LCCF_DownPayment,
	A3_LCCF_Principal,
	A3_LCCF_TermYears,
	A3_LCCF_TermMonths
};

typedef NS_ENUM(NSUInteger , A3LoanCalculatorType) {
	A3LoanCalculatorTypeSimple = 1,
	A3LoanCalculatorTypeAdvanced = 2
};

#define A3LC_CONTROLLER_NAME		@"A3LoanCalcQuickDialogViewController"

@interface A3LoanCalcQuickDialogViewController ()

@property (nonatomic, strong) QRootElement *rootElement;
@property (nonatomic)	A3LoanCalculatorType calculatorType;
@property (nonatomic)	A3LoanCalculatorCalculationFor calculationFor;
@property (nonatomic, strong) NSNumberFormatter *currencyNumberFormatter, *percentNumberFormatter;
@property (nonatomic, strong) A3LoanCalcPieChartViewController *tableHeaderViewController;
@property (nonatomic) BOOL showsDownPayment;

@end

@implementation A3LoanCalcQuickDialogViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		_calculatorType = A3LoanCalculatorTypeAdvanced;
		_calculationFor = A3_LCCF_MonthlyPayment;
		_showsDownPayment = YES;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)applyCommonAttributes {
	for (QSection *section in self.rootElement.sections) {
		for (QElement *element in section.elements) {
			element.height = A3_CALCULATOR_APP_ROW_HEIGHT;
			if ([element isKindOfClass:[QEntryElement class]]) {
				((QEntryElement *)element).delegate = self;
			}
		}
	}
}

- (QRootElement *)rootElement {
	if (nil == _rootElement) {
		QSection *section1 = [[QSection alloc] init];
		QLabelElement *section1element = [[QLabelElement alloc] initWithTitle:@"calculation for" Value:@"$193.052.00"];
		section1element.key = A3LC_KEY_CALCULATION_FOR;
		[section1 addElement:section1element];

		// Section 2: Input values
		QSection *section2 = [[QSection alloc] init];

		if (_calculationFor != A3_LCCF_Principal) [section2 addElement:[self principalElement]];
		if (_showsDownPayment && (_calculationFor != A3_LCCF_DownPayment)) [section2 addElement:[self downPaymentElement]];
		if ((_calculationFor != A3_LCCF_TermMonths) && (_calculationFor != A3_LCCF_TermYears))
			[section2 addElement:[self termElement]];
		if (_calculationFor != A3_LCCF_Principal) [section2 addElement:[self interestRateElement]];

		if (_calculatorType == A3LoanCalculatorTypeAdvanced) {
			[section2 addElement:[self frequencyElement]];
			[section2 addElement:[self startDateElement]];
			[section2 addElement:[self notesElement]];
		}
		[section2 addElement:[self typeChangeButtonElement]];

		// Section 3: Extra Payments
		QSection *section3 = [[QSection alloc] initWithTitle:@"Extra Payments"];
		[section3 addElement:[self extraPaymentMonthly]];
		[section3 addElement:[self extraPaymentYearly]];
		[section3 addElement:[self extraPaymentOneTime]];

		// Root Element
		_rootElement = [[QRootElement alloc] init];
		_rootElement.controllerName = A3LC_CONTROLLER_NAME;
		_rootElement.grouped = YES;
		[_rootElement addSection:section1];
		[_rootElement addSection:section2];
		[_rootElement addSection:section3];
		[self applyCommonAttributes];
	}
	return _rootElement;
}

- (QEntryElement *)extraPaymentOneTime {
	QEntryElement *extraPaymentOneTime = [[QEntryElement alloc] initWithTitle:NSLocalizedString(@"One-Time:", @"One-Time:") Value:@"" Placeholder:[self zeroCurrency]];
	extraPaymentOneTime.key = A3LC_KEY_EXTRA_PAYMENTS_ONETIME;
	return extraPaymentOneTime;
}

- (QEntryElement *)extraPaymentYearly {
	QEntryElement *extraPaymentYearly = [[QEntryElement alloc] initWithTitle:NSLocalizedString(@"Yearly:", @"Yearly:") Value:@"" Placeholder:[self zeroCurrency]];
	extraPaymentYearly.key = A3LC_KEY_EXTRA_PAYMENTS_YEARLY;
	return extraPaymentYearly;
}

- (QEntryElement *)extraPaymentMonthly {
	QEntryElement *extraPaymentMonthly = [[QEntryElement alloc] initWithTitle:NSLocalizedString(@"Monthly:", @"Monthly:") Value:@"" Placeholder:[self zeroCurrency]];
	extraPaymentMonthly.key = A3LC_KEY_EXTRA_PAYMENTS_MONTHLY;
	return extraPaymentMonthly;
}

- (QButtonElement *)typeChangeButtonElement {
	NSString *buttonTitle =	(_calculatorType == A3LoanCalculatorTypeAdvanced) ? @"Simple" : @"Advanced";
	QButtonElement *typeChangeButton = [[QButtonElement alloc] initWithTitle:buttonTitle];
	typeChangeButton.controllerAction = @"onChangeType:";
	return typeChangeButton;
}

- (QEntryElement *)notesElement {
	QEntryElement *notes = [[QEntryElement alloc] initWithTitle:NSLocalizedString(@"Notes:", @"Notes:") Value:@"" Placeholder:@"(Optional)"];
	notes.key = A3LC_KEY_NOTES;
	return notes;
}

- (QEntryElement *)startDateElement {
	QEntryElement *startDate = [[QEntryElement alloc] initWithTitle:NSLocalizedString(@"Start Date:", @"Start Date:") Value:@"" Placeholder:[A3UIKit mediumStyleDateString:[NSDate date]]];
	startDate.key = A3LC_KEY_START_DATE;
	startDate.height = A3_CALCULATOR_APP_ROW_HEIGHT;
	return startDate;
}

- (QEntryElement *)frequencyElement {
	QEntryElement *frequency = [[QEntryElement alloc] initWithTitle:NSLocalizedString(@"Frequency:", @"Frequency:") Value:@"" Placeholder:@"Monthly"];
	frequency.key = A3LC_KEY_FREQUENCY;
	frequency.height = A3_CALCULATOR_APP_ROW_HEIGHT;
	return frequency;
}

- (QEntryElement *)interestRateElement {
	QEntryElement *interestRate = [[QEntryElement alloc] initWithTitle:NSLocalizedString(@"Interest Rate:", @"Interest Rate:") Value:@"" Placeholder:@"Annual 0%"];
	interestRate.key = A3LC_KEY_INTEREST_RATE;
	return interestRate;
}

- (QEntryElement *)principalElement {
	QEntryElement *principalElement = [[QEntryElement alloc] initWithTitle:NSLocalizedString(@"Principal:", @"Principal") Value:@"" Placeholder:@"$0.00"];
	principalElement.key = A3LC_KEY_PRINCIPAL;
	return principalElement;
}

- (QEntryElement *)termElement {
	QEntryElement *termElement = [[QEntryElement alloc] initWithTitle:NSLocalizedString(@"Term:", @"Term:") Value:@"" Placeholder:@"years or months"];
	termElement.key = A3LC_KEY_TERM;
	return termElement;
}

- (QEntryElement *)downPaymentElement {
	QEntryElement *downPaymentElement = [[QEntryElement alloc] initWithTitle:@"Down Payment" Value:@"" Placeholder:[self zeroCurrency]];
	downPaymentElement.key = A3LC_KEY_DOWN_PAYMENT;
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
}

- (void)configureSection2Cell:(UITableViewCell *)cell withElement:(QElement *)element {
	cell.textLabel.font = [A3UIStyle fontForTableViewEntryCellLabel];
	cell.textLabel.textColor = [A3UIStyle colorForTableViewCellLabelNormal];
	if ([cell isKindOfClass:[QEntryTableViewCell class]]) {
		[self applyEntryCellAttribute:(QEntryTableViewCell *)cell];
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
		[self applyEntryCellAttribute:(QEntryTableViewCell *) cell];
	}
}

- (void)configureSectionZeroCell:(UITableViewCell *)cell withElement:(QElement *)element {
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(178.0, 15.0, 300.0, 30.0)];
	valueLabel.backgroundColor = [UIColor clearColor];
	valueLabel.font = [UIFont boldSystemFontOfSize:25.0];
	valueLabel.textColor = [UIColor blackColor];
	switch (_calculationFor) {
		case A3_LCCF_DownPayment:
			valueLabel.text = @"Down Payment";
			break;
		case A3_LCCF_MonthlyPayment:
			valueLabel.text = @"Monthly Payment";
			break;
		case A3_LCCF_Principal:
			valueLabel.text = @"Principal";
			break;
		case A3_LCCF_TermYears:
			valueLabel.text = @"Term(Years)";
			break;
		case A3_LCCF_TermMonths:
			valueLabel.text = @"Term(Months)";
			break;
	}
	[cell.contentView addSubview:valueLabel];
	cell.textLabel.font = [A3UIStyle fontForTableViewEntryCellLabel];
	cell.textLabel.textColor = [A3UIStyle colorForTableViewCellLabelNormal];
	cell.detailTextLabel.font = [UIFont systemFontOfSize:20.0];
	CGRect frame = cell.detailTextLabel.frame;
	frame.origin.y -= 10.0;
	cell.detailTextLabel.frame = frame;
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

#pragma mark - Entry Cell delegate

- (void)QEntryDidBeginEditingElement:(QEntryElement *)element  andCell:(QEntryTableViewCell *)cell {
	cell.backgroundColor = [UIColor whiteColor];
}

- (void)QEntryDidEndEditingElement:(QEntryElement *)element andCell:(QEntryTableViewCell *)cell {
	cell.backgroundColor = [A3UIStyle contentsBackgroundColor];
}

#pragma mark - Button actions

- (void)onChangeType:(QButtonElement *)buttonElement {
	UITableViewCell *cell = [self.quickDialogTableView cellForElement:buttonElement];
	[self.quickDialogTableView deselectRowAtIndexPath:[self.quickDialogTableView indexPathForCell:cell] animated:YES];

	QSection *section = [self.root.sections objectAtIndex:1];
	NSUInteger insertIndex = _showsDownPayment ? 4 : 3;
	if (_calculatorType == A3LoanCalculatorTypeSimple) {
		_calculatorType = A3LoanCalculatorTypeAdvanced;

		_rootElement = nil;
		self.root = [self rootElement];

		NSArray *addedRows = @[[NSIndexPath indexPathForRow:insertIndex inSection:1], [NSIndexPath indexPathForRow:insertIndex + 1 inSection:1], [NSIndexPath indexPathForRow:insertIndex + 2 inSection:1], [NSIndexPath indexPathForRow:insertIndex + 3 inSection:1]];
		[self.quickDialogTableView reloadRowsAtIndexPaths:addedRows withRowAnimation:UITableViewRowAnimationBottom];
	}
	else
	{
		[section.elements removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(insertIndex,2)]];
		[self.quickDialogTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:insertIndex inSection:1], [NSIndexPath indexPathForRow:insertIndex + 1 inSection:1]] withRowAnimation:UITableViewRowAnimationMiddle];
		buttonElement.title = @"Advanced";
		[self.quickDialogTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_showsDownPayment?5:4 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];

		_calculatorType = A3LoanCalculatorTypeSimple;
	}
}

@end
