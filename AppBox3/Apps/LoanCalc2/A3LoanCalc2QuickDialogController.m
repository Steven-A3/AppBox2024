//
//  A3LoanCalc2QuickDialogController.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/19/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3LoanCalc2QuickDialogController.h"
#import "UIViewController+A3AppCategory.h"
#import "QPickerElement.h"
#import "UIViewController+A3Addition.h"

@interface A3LoanCalc2QuickDialogController () <QuickDialogEntryElementDelegate>

@end

@implementation A3LoanCalc2QuickDialogController

/*! This will make root element inside, don't pass over rootElement
 * \param parameter will be ignored.
 * \returns instance
 */
- (QuickDialogController *)initWithRoot:(QRootElement *)rootElement {
	QRootElement *ownRootElement = [self rootElement];

	self = [super initWithRoot:ownRootElement];
	if (self) {

	}

	return self;
}

- (QRootElement *)rootElement {
	QRootElement *root = [QRootElement new];
	root.grouped = YES;

	[root addSection:[self calculateSection]];
	[root addSection:[self valueSection]];
	[root addSection:[self advancedSection]];
	[root addSection:[self extraPaymentSection]];

	return root;
}

- (QSection *)extraPaymentSection {
	QSection *section = [QSection new];
	[section addElement:[self extraPaymentMonthly]];
	[section addElement:[self extraPaymentYearly]];
	[section addElement:[self extraPaymentOneTime]];
	return section;
}

- (QElement *)extraPaymentOneTime {
	QRootElement *root = [QRootElement new];
	root.title = @"One-Time";
	root.grouped = YES;
	QSection *section = [QSection new];
	[section addElement:[self extraPaymentAmounts]];
	[section addElement:[self extraPaymentOneTimeDate]];
	return root;
}

- (QElement *)extraPaymentOneTimeDate {
	QEntryElement *element = [QEntryElement new];
	element.delegate = self;
	return element;
}

- (QElement *)extraPaymentYearly {
	QRootElement *root = [QRootElement new];
	root.title = @"Yearly";
	root.grouped = YES;
	QSection *section = [QSection new];
	[section addElement:[self extraPaymentAmounts]];
	[section addElement:[self extraPaymentYearlyDate]];
	return root;
}

- (QElement *)extraPaymentYearlyDate {
	NSDateFormatter *dateFormatter = [NSDateFormatter new];
	NSArray *items = [dateFormatter standaloneMonthSymbols];
	QPickerElement *element = [[QPickerElement alloc] initWithTitle:@"Date" items:items value:0];
	return element;
}

- (QElement *)extraPaymentAmounts {
	QEntryElement *element = [[QEntryElement alloc] initWithTitle:@"Amounts" Value:@"" Placeholder:@""];
	element.delegate = self;
	return element;
}

- (QElement *)extraPaymentMonthly {
	QEntryElement *element = [[QEntryElement alloc] initWithTitle:@"Monthly" Value:@"" Placeholder:@""];
	element.delegate = self;
	return element;
}

- (QSection *)advancedSection {
	QSection *section = [QSection new];
	[section addElement:[self startDate]];
	[section addElement:[self notes]];
	return section;
}

- (QElement *)notes {
	QEntryElement *element = [[QEntryElement alloc] initWithTitle:@"Notes" Value:@"" Placeholder:@""];
	element.delegate = self;
	return element;
}

- (QElement *)startDate {
	QEntryElement *element = [[QEntryElement alloc] initWithTitle:@"Start Date" Value:@"" Placeholder:@""];
	element.delegate = self;
	return element;
}

- (QSection *)valueSection {
	QSection *section = [QSection new];
	[section addElement:[self principalElement]];
	[section addElement:[self term]];
	[section addElement:[self interestRate]];
	[section addElement:[self frequency]];
	return section;
}

- (QElement *)frequency {
	QRadioElement *radio = [[QRadioElement alloc] initWithItems:@[@"Weekly", @"Biweekly", @"Monthly", @"Bimonthly", @"Quarterly", @"Semiannually", @"Annually"] selected:2 title:@"Frequency"];
	return radio;
}

- (QElement *)interestRate {
	QEntryElement *element = [[QEntryElement alloc] initWithTitle:@"Interest Rate" Value:@"" Placeholder:@"Annual 0%"];
	element.delegate = self;
	return element;
}

- (QElement *)term {
	QEntryElement *element = [[QEntryElement alloc] initWithTitle:@"Term" Value:@"" Placeholder:@"0 years"];
	element.delegate = self;
	return element;
}

- (QElement *)principalElement {
	QEntryElement *element = [[QEntryElement alloc] initWithTitle:@"Principal" Value:@"" Placeholder:@"$0.00 USD"];
	element.delegate = self;
	return element;
}

- (QSection *)calculateSection {
	QSection *section = [QSection new];
	QElement *calculation = [self calculationElement];
	[section addElement:calculation];
	return section;
}

- (QElement *)calculationElement {
//	QRadioElement *radio = [[QRadioElement alloc] initWithItems: selected:0 title:@"Calculation"];
//
//	QRootElement *root = [QRootElement new];
//	root.grouped = YES;
//	QSelectSection *section = [[QSelectSection alloc] initWithItems:@[@"Down Payment", @"Principal", @"Repayment", @"Term(years)", @"Term(months)"] selected:2];
//	section.onSelected = ^{
//		[]
//	};
//	return radio;
	return nil;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view.
	self.navigationItem.titleView = [self titleView];
	[self leftBarButtonAppsButton];
	[self makeBackButtonEmptyArrow];
}

- (UISegmentedControl *)titleView {
	UISegmentedControl *titleView = [[UISegmentedControl alloc] initWithItems:@[@"Loan", @"Comparison"]];
	titleView.selectedSegmentIndex = 0;
	return titleView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
