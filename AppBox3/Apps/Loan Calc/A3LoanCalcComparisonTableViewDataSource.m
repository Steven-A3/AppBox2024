//
//  A3LoanCalcComparisonTableViewDataSource.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 3/28/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "A3LoanCalcComparisonTableViewDataSource.h"
#import "CommonUIDefinitions.h"
#import "A3LoanCalcPreferences.h"
#import "A3UIStyle.h"
#import "A3ButtonTextField.h"
#import "A3Formatter.h"
#import "common.h"

@interface A3LoanCalcComparisonTableViewDataSource ()
@property (nonatomic, strong) NSMutableArray *contentsKeyIndex;
@property (nonatomic, strong) NSMutableArray *contentsTypeIndex;
@property (nonatomic, strong) NSMutableArray *textFieldsInSection1;
@property (nonatomic, strong) A3ButtonTextField *extraPaymentYearlyMonth, *extraPaymentOneTimeYearMonth;
@property (nonatomic, weak) LoanCalcHistory *leftObject, *rightObject;
@property (nonatomic, weak) UITextField *editingTextField;

@end

@implementation A3LoanCalcComparisonTableViewDataSource

- (void)setObject:(LoanCalcHistory *)object {
	_object = object;
	[self buildArray];
}

- (NSMutableArray *)contentsKeyIndex {
	if (nil == _contentsKeyIndex) {
		_contentsKeyIndex = [[NSMutableArray alloc] init];
	}
	return _contentsKeyIndex;
}

- (NSMutableArray *)contentsTypeIndex {
	if (nil == _contentsTypeIndex) {
		_contentsTypeIndex = [[NSMutableArray alloc] init];
	}
	return _contentsTypeIndex;
}

- (NSMutableArray *)textFieldsInSection1 {
	if (nil == _textFieldsInSection1) {
		_textFieldsInSection1 = [[NSMutableArray alloc] init];
	}
	return _textFieldsInSection1;
}

- (UITextField *)textFieldWithTag:(NSInteger)tag {
	UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
	textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	textField.delegate = self;
	textField.textAlignment = _leftAlignment ? NSTextAlignmentLeft : NSTextAlignmentRight;
	textField.font = [A3UIStyle fontForTableViewEntryCellTextField];
	textField.tag = tag;
	textField.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	textField.textColor = [UIColor colorWithRed:115.0/255.0 green:115.0/255.0 blue:115.0/255.0 alpha:1.0];
	return textField;
}

- (void)buildArray {
	_contentsKeyIndex = nil; _contentsTypeIndex = nil; _textFieldsInSection1 = nil;
	[self contentsKeyIndex];
	[self contentsTypeIndex];
	[self textFieldsInSection1];

	A3LoanCalcCalculationFor calculationFor = (A3LoanCalcCalculationFor) [_object.calculationFor unsignedIntegerValue];
	if (calculationFor != A3_LCCF_Principal) {
		[_contentsKeyIndex addObject:A3LC_KEY_PRINCIPAL];
		[_contentsTypeIndex addObject:[NSNumber numberWithUnsignedInteger:A3LCEntryPrincipal]];
		UITextField *textField = [self textFieldWithTag:A3LCEntryPrincipal];
		textField.placeholder = [A3Formatter stringWithCurrencyFormatFromNumber:[NSNumber numberWithInteger:0]];
		[_textFieldsInSection1 addObject:textField];
	}
	if ([self.object.showDownPayment boolValue] && (calculationFor != A3_LCCF_DownPayment)) {
		[_contentsKeyIndex addObject:A3LC_KEY_DOWN_PAYMENT];
		[_contentsTypeIndex addObject:[NSNumber numberWithUnsignedInteger:A3LCEntryDownPayment]];
		UITextField *textField = [self textFieldWithTag:A3LCEntryDownPayment];
		textField.placeholder = [A3Formatter stringWithCurrencyFormatFromNumber:[NSNumber numberWithInteger:0]];
		[_textFieldsInSection1 addObject:textField];
	}
	if (calculationFor != A3_LCCF_MonthlyPayment) {
		[_contentsKeyIndex addObject:A3LC_KEY_MONTHLY_PAYMENT];
		[_contentsTypeIndex addObject:[NSNumber numberWithUnsignedInteger:A3LCEntryMonthlyPayment]];
		UITextField *textField = [self textFieldWithTag:A3LCEntryMonthlyPayment];
		textField.placeholder = [A3Formatter stringWithCurrencyFormatFromNumber:[NSNumber numberWithInteger:0]];
		[_textFieldsInSection1 addObject:textField];
	}
	if ((calculationFor != A3_LCCF_TermMonths) && (calculationFor != A3_LCCF_TermYears)) {
		[_contentsKeyIndex addObject:A3LC_KEY_TERM];
		[_contentsTypeIndex addObject:[NSNumber numberWithUnsignedInteger:A3LCEntryTerm]];
		UITextField *textField = [self textFieldWithTag:A3LCEntryTerm];
		textField.placeholder = @"years or months";
		[_textFieldsInSection1 addObject:textField];
	}
	{
		[_contentsKeyIndex addObject:A3LC_KEY_INTEREST_RATE];
		[_contentsTypeIndex addObject:[NSNumber numberWithUnsignedInteger:A3LCEntryInterestRate]];
		UITextField *textField = [self textFieldWithTag:A3LCEntryInterestRate];
		textField.placeholder = [A3Formatter stringWithPercentFormatFromNumber:[NSNumber numberWithInteger:0]];
		[_textFieldsInSection1 addObject:textField];
	}

	{
		[_contentsKeyIndex addObject:A3LC_KEY_FREQUENCY];
		[_contentsTypeIndex addObject:[NSNumber numberWithUnsignedInteger:A3LCEntryFrequency]];
		UITextField *textField = [self textFieldWithTag:A3LCEntryFrequency];
		textField.placeholder = @"Monthly";
		[_textFieldsInSection1 addObject:textField];
	}

	{
		[_contentsKeyIndex addObject:A3LC_KEY_START_DATE];
		[_contentsTypeIndex addObject:[NSNumber numberWithUnsignedInteger:A3LCEntryStartDate]];
		UITextField *textField = [self textFieldWithTag:A3LCEntryStartDate];
		textField.placeholder = [A3Formatter mediumStyleDateStringFromDate:[NSDate date]];
		[_textFieldsInSection1 addObject:textField];
	}

	{
		[_contentsKeyIndex addObject:A3LC_KEY_NOTES];
		[_contentsTypeIndex addObject:[NSNumber numberWithUnsignedInteger:A3LCEntryNotes]];
		UITextField *textField = [self textFieldWithTag:A3LCEntryNotes];
		textField.placeholder = @"(Optional)";
		[_textFieldsInSection1 addObject:textField];
	}

	[_contentsKeyIndex addObject:@"BUTTON"];
	[_contentsTypeIndex addObject:[NSNumber numberWithUnsignedInteger:A3LCEntryButton]];
}

- (void)setTableView:(UITableView *)tableView {
	_tableView = tableView;
	tableView.rowHeight = A3_LOAN_CALC_ROW_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSInteger numberOfSection = 1;
	if (_object.showExtraPayment)
		numberOfSection = 2;
	return numberOfSection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger numberOfRows = 0;
	switch (section) {
		case 0:
			numberOfRows = [_contentsTypeIndex count];
			break;
		case 1:
			numberOfRows = 3;
			break;
	}
	return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	switch (indexPath.section) {
		case 0:
			cell = [self configureCellforRow:indexPath.row];
			break;
		case 1:
			cell = [self configureExtraPaymentCellforRow:indexPath.row];
			break;
	}
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return A3_LOAN_CALC_ROW_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return section == 1 ? 40.0 : 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if (_leftAlignment && (section == 1)) {
		CGRect frame = tableView.bounds;
		frame.size.height = 40.0;
		UIView *sectionHeaderView = [[UIView alloc] initWithFrame:frame];
		sectionHeaderView.backgroundColor = [UIColor clearColor];
		frame = CGRectInset(frame, 20.0, 00.0);
		UILabel *sectionTitleLabel = [[UILabel alloc] initWithFrame:frame];
		sectionTitleLabel.backgroundColor = [UIColor clearColor];
		sectionTitleLabel.font = [UIFont boldSystemFontOfSize:24.0];
		sectionTitleLabel.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
		sectionTitleLabel.text = @"Extra Payments";
		[sectionHeaderView addSubview:sectionTitleLabel];

		return sectionHeaderView;
	}
	return nil;
}

- (UITableViewCell *)configureCellforRow:(NSInteger)row {
	UITableViewCell *cell;
	static NSString *identifier = nil, *buttonCellIdentifier = nil;
	if (nil == identifier) {
		identifier = [NSString stringWithFormat:@"A3LoanCalcComparisonEntryCell%@", _leftAlignment ? @"A" : @"B"];
	}
	if (nil == buttonCellIdentifier) {
		buttonCellIdentifier = @"A3LoanCalcComparisonButtonCell";
	}
	A3LoanCalculatorEntry entry = (A3LoanCalculatorEntry) [[_contentsTypeIndex objectAtIndex:row] unsignedIntegerValue];
	UITextField *textField;
	switch (entry) {
		case A3LCEntryPrincipal:
		case A3LCEntryMonthlyPayment:
		case A3LCEntryDownPayment:
		case A3LCEntryTerm:
		case A3LCEntryInterestRate:
		case A3LCEntryFrequency:
		case A3LCEntryStartDate:
		case A3LCEntryNotes:
			cell = [_tableView dequeueReusableCellWithIdentifier:identifier];
			if (nil == cell) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
			}
			textField = [_textFieldsInSection1 objectAtIndex:row];
			[textField removeFromSuperview];
			textField.frame = CGRectInset(cell.contentView.bounds, 15.0, 10.0);
			[cell.contentView addSubview:textField];
			break;
		case A3LCEntryButton:
			cell = [_tableView dequeueReusableCellWithIdentifier:buttonCellIdentifier];
			if (nil == cell) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:buttonCellIdentifier];
			}
			cell.textLabel.text = [_object.showAdvanced boolValue] ? @"Simple" : @"Advanced";
			cell.textLabel.textAlignment = _leftAlignment ? NSTextAlignmentLeft : NSTextAlignmentRight;
			cell.textLabel.font = [A3UIStyle fontForTableViewEntryCellTextField];
			cell.textLabel.textColor = [UIColor colorWithRed:40.0/255.0 green:70.0/255.0 blue:115.0/255.0 alpha:1.0];
			break;
		default:
			break;
	}
	return cell;
}

- (UITableViewCell *)configureExtraPaymentCellforRow:(NSInteger)row {
	UITableViewCell *cell;
	cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	UITextField *textField;
	switch (row) {
		case 0:
			textField = [self textFieldWithTag:A3LCEntryExtraPaymentMonthly];
			break;
		case 1:
		{
			textField = [self textFieldWithTag:A3LCEntryExtraPaymentYearly];

			CGRect frame = self.extraPaymentYearlyMonth.frame;
			frame.origin.x = _leftAlignment ? 188.0 : 20.0;
			frame.origin.y = 15.0;
			_extraPaymentYearlyMonth.frame = frame;
			[cell.contentView addSubview:_extraPaymentYearlyMonth];
			break;
		}
		case 2:{
			textField = [self textFieldWithTag:A3LCEntryExtraPaymentOneTime];

			CGRect frame = self.extraPaymentOneTimeYearMonth.frame;
			frame.origin.x = _leftAlignment ? 150.0 : 20.0;
			frame.origin.y = 15.0;
			_extraPaymentOneTimeYearMonth.frame = frame;
			[cell.contentView addSubview:_extraPaymentOneTimeYearMonth];
			break;
		}
	}
	textField.placeholder = [A3Formatter stringWithCurrencyFormatFromNumber:[NSNumber numberWithInteger:0]];
	textField.frame = CGRectInset(cell.contentView.bounds, 15.0, 10.0);
	[cell.contentView addSubview:textField];

	return cell;
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	_editingTextField = textField;
	return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	return YES;
}

- (void)registerKeyboardNotification {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidShow:)
												 name:UIKeyboardDidShowNotification object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidHide:)
												 name:UIKeyboardDidHideNotification object:nil];
}

- (void)removeObservers {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardDidShow:(NSNotification *)notification {
	if (_editingTextField) {
		CGRect frame = [_editingTextField.superview convertRect:_editingTextField.frame toView:nil];
		frame = [self.mainScrollView convertRect:frame fromView:nil];
		frame.size.height += 15.0;
		[self.mainScrollView scrollRectToVisible:frame animated:YES];
	}
}

- (void)keyboardDidHide:(NSNotification*)aNotification {
}

@end
