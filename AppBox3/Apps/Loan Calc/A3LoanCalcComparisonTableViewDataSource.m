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
#import "A3ButtonTextField.h"
#import "A3Formatter.h"
#import "A3NumberKeyboardViewController_iPad.h"
#import "A3FrequencyKeyboardViewController.h"
#import "A3DateKeyboardViewController.h"
#import "A3LoanCalcString.h"
#import "NSString+conversion.h"
#import "common.h"
#import "A3UIDevice.h"
#import "A3NumberKeyboardViewController_iPhone.h"
#import "A3FrequencyKeyboardViewController_iPhone.h"
#import "A3DateKeyboardViewController_iPad.h"
#import "A3DateKeyboardViewController_iPhone.h"

@interface A3LoanCalcComparisonTableViewDataSource () <A3KeyboardDelegate, A3FrequencyKeyboardDelegate, A3DateKeyboardDelegate>
@property (nonatomic, strong) NSMutableArray *contentsKeyIndex;
@property (nonatomic, strong) NSMutableArray *contentsTypeIndex;
@property (nonatomic, strong) NSMutableArray *textFields;
@property (nonatomic, strong) A3ButtonTextField *extraPaymentYearlyMonth, *extraPaymentOneTimeYearMonth;
@property (nonatomic, weak) UITextField *editingTextField;
@property (nonatomic, strong) A3NumberKeyboardViewController *numberKeyboardViewController;
@property (nonatomic, strong) A3FrequencyKeyboardViewController *frequencyKeyboardViewController;
@property (nonatomic, strong) A3DateKeyboardViewController *dateKeyboardViewController;
@property (nonatomic, strong) A3DateKeyboardViewController *dateKeyboardForMonthInput;
@property (nonatomic, strong) A3DateKeyboardViewController *dateKeyboardForYearMonthInput;
@property (nonatomic, strong) NSNumberFormatter *currencyNumberFormatter;
@property (nonatomic, strong) NSNumberFormatter *percentNumberFormatter;

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

- (NSMutableArray *)textFields {
	if (nil == _textFields) {
		_textFields = [[NSMutableArray alloc] init];
	}
	return _textFields;
}

- (UITextField *)textFieldWithTag:(NSInteger)tag {
	UITextField *textField;
	for (textField in _textFields) {
		if (textField.tag == tag) {
			return textField;
		}
	}

	textField= [[UITextField alloc] initWithFrame:CGRectZero];
	textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	textField.delegate = self;
	textField.textAlignment = _leftAlignment ? NSTextAlignmentLeft : NSTextAlignmentRight;
	textField.font = [self textFont];
	textField.tag = tag;
	textField.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	textField.textColor = [UIColor colorWithRed:115.0/255.0 green:115.0/255.0 blue:115.0/255.0 alpha:1.0];
	[textField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
	return textField;
}

- (void)insertFrequency {
	for (NSString *key in _contentsKeyIndex) {
		if ([key isEqualToString:A3LC_KEY_FREQUENCY]) {
			return;
		}
	}
	NSUInteger insertAt = _object.showDownPayment.boolValue ? 4 : 3;
	[_contentsKeyIndex insertObject:A3LC_KEY_FREQUENCY atIndex:insertAt];
	[_contentsTypeIndex insertObject:[NSNumber numberWithUnsignedInteger:A3LCEntryFrequency] atIndex:insertAt];
	UITextField *textField = [self textFieldWithTag:A3LCEntryFrequency];
	textField.placeholder = @"Monthly";
	textField.text = [A3LoanCalcString stringForFrequencyValue:_object.frequency];
	[_textFields insertObject:textField atIndex:insertAt];
}

- (void)insertStartDate {
	for (NSString *key in _contentsKeyIndex) {
		if ([key isEqualToString:A3LC_KEY_START_DATE]) {
			return;
		}
	}
	NSUInteger insertAt = _object.showDownPayment.boolValue ? 5 : 4;
	[_contentsKeyIndex insertObject:A3LC_KEY_START_DATE atIndex:insertAt];
	[_contentsTypeIndex insertObject:[NSNumber numberWithUnsignedInteger:A3LCEntryStartDate] atIndex:insertAt];
	UITextField *textField = [self textFieldWithTag:A3LCEntryStartDate];
	textField.placeholder = [A3Formatter mediumStyleDateStringFromDate:[NSDate date]];
	textField.text = [A3Formatter mediumStyleDateStringFromDate:_object.startDate];
	[_textFields insertObject:textField atIndex:insertAt];
}

- (void)insertNotes {
	for (NSString *key in _contentsKeyIndex) {
		if ([key isEqualToString:A3LC_KEY_NOTES]) {
			return;
		}
	}
	NSUInteger insertAt = _object.showDownPayment.boolValue ? 6 : 5;
	[_contentsKeyIndex insertObject:A3LC_KEY_NOTES atIndex:insertAt];
	[_contentsTypeIndex insertObject:[NSNumber numberWithUnsignedInteger:A3LCEntryNotes] atIndex:insertAt];
	UITextField *textField = [self textFieldWithTag:A3LCEntryNotes];
	textField.placeholder = @"(Optional)";
	textField.text = _object.notes;
	[_textFields insertObject:textField atIndex:insertAt];
}

- (void)buildArray {
	_contentsKeyIndex = nil; _contentsTypeIndex = nil; _textFields = nil;
	[self contentsKeyIndex];
	[self contentsTypeIndex];
	[self textFields];

	A3LoanCalcCalculationFor calculationFor = (A3LoanCalcCalculationFor) [_object.calculationFor unsignedIntegerValue];
	if (calculationFor != A3_LCCF_Principal) {
		[_contentsKeyIndex addObject:A3LC_KEY_PRINCIPAL];
		[_contentsTypeIndex addObject:[NSNumber numberWithUnsignedInteger:A3LCEntryPrincipal]];
		UITextField *textField = [self textFieldWithTag:A3LCEntryPrincipal];
		textField.placeholder = [A3Formatter stringWithCurrencyFormatFromNumber: @0.0 ];
		textField.text = _object.principal;
		[_textFields addObject:textField];
	}
	if ([self.object.showDownPayment boolValue] && (calculationFor != A3_LCCF_DownPayment)) {
		[_contentsKeyIndex addObject:A3LC_KEY_DOWN_PAYMENT];
		[_contentsTypeIndex addObject:[NSNumber numberWithUnsignedInteger:A3LCEntryDownPayment]];
		UITextField *textField = [self textFieldWithTag:A3LCEntryDownPayment];
		textField.placeholder = [A3Formatter stringWithCurrencyFormatFromNumber: @0.0 ];
		textField.text = _object.downPayment;
		[_textFields addObject:textField];
	}
	if (calculationFor != A3_LCCF_MonthlyPayment) {
		[_contentsKeyIndex addObject:A3LC_KEY_MONTHLY_PAYMENT];
		[_contentsTypeIndex addObject:[NSNumber numberWithUnsignedInteger:A3LCEntryMonthlyPayment]];
		UITextField *textField = [self textFieldWithTag:A3LCEntryMonthlyPayment];
		textField.placeholder = [A3Formatter stringWithCurrencyFormatFromNumber: @0.0 ];
		textField.text = _object.monthlyPayment;
		[_textFields addObject:textField];
	}
	if ((calculationFor != A3_LCCF_TermMonths) && (calculationFor != A3_LCCF_TermYears)) {
		[_contentsKeyIndex addObject:A3LC_KEY_TERM];
		[_contentsTypeIndex addObject:[NSNumber numberWithUnsignedInteger:A3LCEntryTerm]];
		UITextField *textField = [self textFieldWithTag:A3LCEntryTerm];
		textField.placeholder = @"years or months";
		textField.text = _object.term;
		[_textFields addObject:textField];
	}
	{
		[_contentsKeyIndex addObject:A3LC_KEY_INTEREST_RATE];
		[_contentsTypeIndex addObject:[NSNumber numberWithUnsignedInteger:A3LCEntryInterestRate]];
		UITextField *textField = [self textFieldWithTag:A3LCEntryInterestRate];
		textField.placeholder = [A3Formatter stringWithPercentFormatFromNumber:[NSNumber numberWithInteger:0]];
		textField.text = _object.interestRate;
		[_textFields addObject:textField];
	}

	if (_object.showAdvanced.boolValue) {
		[self insertFrequency];
		[self insertStartDate];
		[self insertNotes];
	}

	[_contentsTypeIndex addObject:[NSNumber numberWithUnsignedInteger:A3LCEntryButton]];

	[_textFields addObject:[self textFieldWithTag:A3LCEntryExtraPaymentMonthly]];
	[_contentsKeyIndex addObject:A3LC_KEY_EXTRA_PAYMENT_MONTHLY];

	if (_leftAlignment) {
		[_textFields addObject:[self textFieldWithTag:A3LCEntryExtraPaymentYearly]];
		[_textFields addObject:self.extraPaymentYearlyMonth];
		[_textFields addObject:[self textFieldWithTag:A3LCEntryExtraPaymentOneTime]];
		[_textFields addObject:self.extraPaymentOneTimeYearMonth];

		[_contentsKeyIndex addObject:A3LC_KEY_EXTRA_PAYMENT_YEARLY];
		[_contentsKeyIndex addObject:A3LC_KEY_EXTRA_PAYMENT_YEARLY_MONTH];
		[_contentsKeyIndex addObject:A3LC_KEY_EXTRA_PAYMENT_ONETIME];
		[_contentsKeyIndex addObject:A3LC_KEY_EXTRA_PAYMENT_ONETIME_YEAR_MONTH];
	} else {
		[_textFields addObject:self.extraPaymentYearlyMonth];
		[_textFields addObject:[self textFieldWithTag:A3LCEntryExtraPaymentYearly]];
		[_textFields addObject:self.extraPaymentOneTimeYearMonth];
		[_textFields addObject:[self textFieldWithTag:A3LCEntryExtraPaymentOneTime]];

		[_contentsKeyIndex addObject:A3LC_KEY_EXTRA_PAYMENT_YEARLY_MONTH];
		[_contentsKeyIndex addObject:A3LC_KEY_EXTRA_PAYMENT_YEARLY];
		[_contentsKeyIndex addObject:A3LC_KEY_EXTRA_PAYMENT_ONETIME_YEAR_MONTH];
		[_contentsKeyIndex addObject:A3LC_KEY_EXTRA_PAYMENT_ONETIME];
	}
}

- (void)setTableView:(UITableView *)tableView {
	_tableView = tableView;
	tableView.rowHeight = IS_IPAD ? A3_TABLE_VIEW_ROW_HEIGHT_IPAD : A3_TABLE_VIEW_ROW_HEIGHT_IPHONE;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSInteger numberOfSection = 1;
//	if (_object.showExtraPayment)
//		numberOfSection = 2;
	FNLOG(@"Number of Section %d", numberOfSection);
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
	FNLOG(@"Number of rows in section %d in section %d", numberOfRows, section);
	return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	FNLOG(@"%@", indexPath);
	UITableViewCell *cell = nil;
	switch (indexPath.section) {
		case 0:
			cell = [self configureCellforRow:indexPath.row];
			break;
		case 1:
			cell = [self configureExtraPaymentCellforRow:indexPath.row];
			break;
	}
	// TODO:
//	cell.backgroundColor = ;
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return IS_IPAD ? A3_TABLE_VIEW_ROW_HEIGHT_IPAD : A3_TABLE_VIEW_ROW_HEIGHT_IPHONE;
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
		sectionTitleLabel.font = [UIFont boldSystemFontOfSize:IS_IPAD ? 24.0 : 18.0];
		sectionTitleLabel.textColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1.0];
		sectionTitleLabel.text = @"Extra Payments";
		[sectionHeaderView addSubview:sectionTitleLabel];

		return sectionHeaderView;
	}
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	[self switchSimpleAdvancedForTableView:tableView buttonAtIndexPath:indexPath];
	[self.brother switchSimpleAdvancedForTableView:self.brother.tableView buttonAtIndexPath:indexPath];
	[self reloadMainScrollViewContentSize];
}

- (void)switchSimpleAdvancedForTableView:(UITableView *)tableView buttonAtIndexPath:(NSIndexPath *)indexPath {
	[_editingTextField resignFirstResponder];

	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	if (cell.tag != A3LCEntryButton) {
		return;
	}
	if (_object.showAdvanced.boolValue) {
		cell.textLabel.text = @"Advanced";
	} else {
		cell.textLabel.text = @"Simple";
	}

	NSUInteger indexFrom = _object.showDownPayment.boolValue ? 4 : 3;
	NSArray *indexPaths = @[[NSIndexPath indexPathForRow:indexFrom inSection:0], [NSIndexPath indexPathForRow:indexFrom + 1 inSection:0], [NSIndexPath indexPathForRow:indexFrom + 2 inSection:0]];
	if (_object.showAdvanced.boolValue) {
		NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(indexFrom, 3)];
		[_contentsKeyIndex removeObjectsAtIndexes:indexSet];
		[_contentsTypeIndex removeObjectsAtIndexes:indexSet];
		[_textFields removeObjectsAtIndexes:indexSet];
		_object.showAdvanced = [NSNumber numberWithBool:NO];

		[tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
	} else {
		[self insertFrequency];
		[self insertStartDate];
		[self insertNotes];
		_object.showAdvanced = [NSNumber numberWithBool:YES];

		[tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
	}
}

- (NSString *)imagePathForEntry:(A3LoanCalculatorEntry)entry {
	static NSArray *imageNames = nil;
	if (imageNames == nil) {
		imageNames = @[@"comparison_principal_", @"comparison_principal_", @"comparison_principal_",
		@"comparison_term_", @"comparison_rate_", @"comparison_frequency_", @"comparison_startdate_",
		@"comparison_note_", @"", @"comparison_extra_monthly_", @"comparison_extra_yearly_",
		@"comparison_extra_onetime_"];
	}
	NSString *imageName = [NSString stringWithFormat:@"%@%@", [imageNames objectAtIndex:entry - 1], IS_IPAD ? @"32" : @"24"];
	NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
	return path;
}

- (CGRect)textFieldFrameForCell:(UITableViewCell *)cell {
	CGRect frame;
	if (IS_IPAD) {
		frame = CGRectInset(cell.contentView.bounds, 15.0, 10.0);
	} else {
		frame = CGRectInset(cell.contentView.bounds, 32.0, 10.0);
	}
	return frame;
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
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;

			textField = [self textFieldWithTag:entry];
			[textField removeFromSuperview];

			textField.frame = [self textFieldFrameForCell:cell];
			[cell addSubview:textField];

			if (!_leftAlignment) {
				NSString *imagePath = [self imagePathForEntry:entry];
				UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
				UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
				imageView.frame = [self imageViewFrame];
				[cell addSubview:imageView];
			}

			break;
		case A3LCEntryButton:
			cell = [_tableView dequeueReusableCellWithIdentifier:buttonCellIdentifier];
			if (nil == cell) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:buttonCellIdentifier];
				cell.tag = A3LCEntryButton;
			}
			cell.textLabel.text = [_object.showAdvanced boolValue] ? @"Simple" : @"Advanced";
			cell.textLabel.textAlignment = _leftAlignment ? NSTextAlignmentLeft : NSTextAlignmentRight;
			cell.textLabel.font = [self textFont];
			cell.textLabel.textColor = [self textColor];
			break;
		default:
			break;
	}
	return cell;
}

- (UIColor *)textColor {
	return [UIColor colorWithRed:115.0/255.0 green:115.0/255.0 blue:115.0/255.0 alpha:1.0];
}

- (UIFont *)textFont {
	UIFont *font;
	if (IS_IPAD) {
		font = [UIFont boldSystemFontOfSize:23.0];
	} else {
		font = [UIFont boldSystemFontOfSize:16.0];
	}
	return font;
}

- (UITableViewCell *)configureExtraPaymentCellforRow:(NSInteger)row {
	FNLOG(@"Chedk");
	UITableViewCell *cell;
	cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	UITextField *textField;
	switch (row) {
		case 0:
			textField = [self textFieldWithTag:A3LCEntryExtraPaymentMonthly];
			textField.frame = [self textFieldFrameForCell:cell];
			break;
		case 1:
		{
			textField = [self textFieldWithTag:A3LCEntryExtraPaymentYearly];
			CGRect frame = [self textFieldFrameForCell:cell];
			if (IS_IPAD) {
				if (_leftAlignment) {
					frame.size.width = 173.0;
				} else {
					frame.origin.x = 116.0;
					frame.size.width = 189.0;
				}
			} else {
				if (_leftAlignment) {
					frame.size.width = 100.0;
				} else {
					frame.origin.x = 116.0;
					frame.size.width = 189.0;
				}
			}
			textField.frame = frame;

			frame = self.extraPaymentYearlyMonth.frame;
			if (IS_IPAD) {
				frame.origin.x = _leftAlignment ? 188.0 : 20.0;
				frame.origin.y = 15.0;
			} else {
				frame.origin.x = _leftAlignment ? 100.0 : 20.0;
				frame.origin.y = 8.0;
				frame.size.width = 40.0;
			}
			_extraPaymentYearlyMonth.frame = frame;
			[cell addSubview:_extraPaymentYearlyMonth];
			break;
		}
		case 2:{
			textField = [self textFieldWithTag:A3LCEntryExtraPaymentOneTime];
			CGRect frame = [self textFieldFrameForCell:cell];
			if (IS_IPAD) {
				if (_leftAlignment) {
					frame.size.width = 135.0;
				} else {
					frame.origin.x = 152.0;
					frame.size.width = 153.0;
				}
			} else {
				if (_leftAlignment) {
				} else {
					frame.origin.x = 70.0;
				}
				frame.size.width = 70.0;
			}
			textField.frame = frame;

			frame = self.extraPaymentOneTimeYearMonth.frame;
			if (IS_IPAD) {
				frame.origin.x = _leftAlignment ? 150.0 : 20.0;
				frame.origin.y = 15.0;
			} else {
				frame.origin.x = _leftAlignment ? 70.0 : 20.0;
				frame.origin.y = 8.0;
				frame.size.width = 70.0;
			}
			_extraPaymentOneTimeYearMonth.frame = frame;
			[cell addSubview:_extraPaymentOneTimeYearMonth];
			break;
		}
	}
	textField.placeholder = [A3Formatter stringWithCurrencyFormatFromNumber:[NSNumber numberWithInteger:0]];
	[cell addSubview:textField];

	if (!_leftAlignment) {
		NSString *imagePath = [self imagePathForEntry:textField.tag];
		UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
		UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
		imageView.frame = [self imageViewFrame];
		[cell addSubview:imageView];
	}

	return cell;
}

- (CGRect)imageViewFrame {
	CGRect frame;
	if (IS_IPAD) {
		frame = CGRectMake(-15.0, 13.0, 32.0, 32.0);
	} else {
		frame = CGRectMake(-8.0, 13.0, 24.0, 24.0);
	}
	return frame;
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

- (NSString *)currencyFormattedString:(NSString *)source {
	if ([source floatValue] == 0.0) return @"";
	return [self.currencyNumberFormatter stringFromNumber:[NSNumber numberWithFloat:[source floatValue]]];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	UITableViewCell *cell = (UITableViewCell *)textField.superview;
	cell.backgroundColor = [UIColor whiteColor];

	FNLOG(@"Check");
	_editingTextField = textField;
	if (textField == _extraPaymentYearlyMonth) {
		textField.inputView = self.dateKeyboardForMonthInput.view;
		return YES;
	} else if (textField == _extraPaymentOneTimeYearMonth) {
		textField.inputView = self.dateKeyboardForYearMonthInput.view;
		return YES;
	}
	A3LoanCalculatorEntry entryType = (A3LoanCalculatorEntry) textField.tag;
	switch (entryType) {
		case A3LCEntryPrincipal:
		case A3LCEntryDownPayment:
		case A3LCEntryMonthlyPayment:
		case A3LCEntryExtraPaymentMonthly:
		case A3LCEntryExtraPaymentYearly:
		case A3LCEntryExtraPaymentOneTime: {
			textField.inputView = self.numberKeyboardViewController.view;
			_numberKeyboardViewController.keyboardType = A3NumberKeyboardTypeCurrency;
			_numberKeyboardViewController.keyInputDelegate = textField;

			textField.text = [textField.text stringByDecimalConversion];

			[_numberKeyboardViewController reloadPrevNextButtons];
			break;
		}
		case A3LCEntryTerm: {
			textField.inputView = self.numberKeyboardViewController.view;
			_numberKeyboardViewController.keyboardType = A3NumberKeyboardTypeMonthYear;
			_numberKeyboardViewController.keyInputDelegate = textField;
			_numberKeyboardViewController.bigButton1.selected = !_object.termTypeMonth.boolValue;
			_numberKeyboardViewController.bigButton2.selected = _object.termTypeMonth.boolValue;

			textField.text = [textField.text stringByDecimalConversion];

			[_numberKeyboardViewController reloadPrevNextButtons];
			break;
		}
		case A3LCEntryInterestRate:
			textField.inputView = self.numberKeyboardViewController.view;
			_numberKeyboardViewController.keyboardType = A3NumberKeyboardTypeInterestRate;
			_numberKeyboardViewController.keyInputDelegate = textField;
			_numberKeyboardViewController.bigButton1.selected = _object.interestRatePerYear.boolValue;
			_numberKeyboardViewController.bigButton2.selected = !_object.interestRatePerYear.boolValue;

			textField.text = [textField.text stringByDecimalConversion];

			[_numberKeyboardViewController reloadPrevNextButtons];
			break;
		case A3LCEntryFrequency:
			textField.inputView = self.frequencyKeyboardViewController.view;
			textField.clearButtonMode = UITextFieldViewModeNever;
			_frequencyKeyboardViewController.delegate = self;
			_frequencyKeyboardViewController.selectedFrequency = _object.frequency;
			[_frequencyKeyboardViewController reloadPrevNextButtons];
			break;
		case A3LCEntryStartDate:
			if (_object.startDate == nil) {
				_object.startDate = [NSDate date];
				textField.text = [A3Formatter mediumStyleDateStringFromDate:_object.startDate];
			}
			textField.inputView = self.dateKeyboardViewController.view;
			_dateKeyboardViewController.date = _object.startDate;
			[_dateKeyboardViewController resetToDefaultState];
			textField.clearButtonMode = UITextFieldViewModeNever;
			[_dateKeyboardViewController reloadPrevNextButtons];
			break;
		case A3LCEntryNotes:
			textField.returnKeyType = _object.showExtraPayment.boolValue ? UIReturnKeyNext : UIReturnKeyDone;
			break;
		case A3LCEntryButton:
			break;
	}
	if ([_delegate respondsToSelector:@selector(loanCalcComparisonTableViewValueChanged)]) {
		[_delegate loanCalcComparisonTableViewValueChanged];
	}
	return YES;
}

- (void)textFieldEditingChanged:(UITextField *)textField {
	FNLOG(@"Check");
	A3LoanCalculatorEntry entryType = (A3LoanCalculatorEntry) textField.tag;
	switch (entryType) {
		case A3LCEntryPrincipal:
		case A3LCEntryMonthlyPayment:
		case A3LCEntryDownPayment: {
			NSUInteger row = [_textFields indexOfObject:textField];
			[_object setValue:[self currencyFormattedString:textField.text] forKey:[_contentsKeyIndex objectAtIndex:row]];
			break;
		}
		case A3LCEntryTerm:
			[self updateTermValueFromText:textField.text];
			break;
		case A3LCEntryInterestRate:
			[self updateInterestValueFromText:textField.text];
			break;
		case A3LCEntryNotes:
			[_object setValue:textField.text forKey:A3LC_KEY_NOTES];
			break;
		case A3LCEntryExtraPaymentMonthly:
			[_object setValue:textField.text forKey:A3LC_KEY_EXTRA_PAYMENT_MONTHLY];
			break;
		case A3LCEntryExtraPaymentYearly:
			[_object setValue:textField.text forKey:A3LC_KEY_EXTRA_PAYMENT_YEARLY];
			break;
		case A3LCEntryExtraPaymentOneTime:
			[_object setValue:textField.text forKey:A3LC_KEY_EXTRA_PAYMENT_ONETIME];
			break;
		case A3LCEntryFrequency:
		case A3LCEntryStartDate:
		case A3LCEntryButton:
			break;
	}
	[_object calculate];
	if ([_delegate respondsToSelector:@selector(loanCalcComparisonTableViewValueChanged)]) {
		[_delegate loanCalcComparisonTableViewValueChanged];
	}
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	FNLOG(@"Check");
	A3LoanCalculatorEntry entryType = (A3LoanCalculatorEntry) textField.tag;
	switch (entryType) {
		case A3LCEntryPrincipal:
		case A3LCEntryMonthlyPayment:
		case A3LCEntryDownPayment:
		case A3LCEntryExtraPaymentMonthly:
		case A3LCEntryExtraPaymentYearly:
		case A3LCEntryExtraPaymentOneTime:
		{
			NSUInteger row = [_textFields indexOfObject:textField];
			textField.text = [self currencyFormattedString:textField.text];
			[_object setValue:textField.text forKey:[_contentsKeyIndex objectAtIndex:row]];
			break;
		}
		case A3LCEntryTerm:
			[self updateTermValueFromText:textField.text];
			textField.text = _object.term;
			break;
		case A3LCEntryInterestRate:
			[self updateInterestValueFromText:textField.text];
			textField.text = _object.interestRate;
			break;
		case A3LCEntryNotes:
			[_object setValue:textField.text forKey:A3LC_KEY_NOTES];
			break;
		case A3LCEntryFrequency:
		case A3LCEntryStartDate:
		case A3LCEntryButton:
			break;
	}
	UITableViewCell *cell = (UITableViewCell *)textField.superview;
	if ([_delegate respondsToSelector:@selector(tableViewBackgroundColor)]) {
		cell.backgroundColor = [_delegate tableViewBackgroundColor];
	}
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField.tag == A3LCEntryNotes) {
		[self nextButtonPressedWithElement:nil];
	}
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
		FNLOG(@"origin = %f, height = %f", frame.origin.y, frame.size.height);
		frame = [self.mainScrollView convertRect:frame fromView:nil];
		FNLOG(@"origin = %f, height = %f", frame.origin.y, frame.size.height);
		frame.origin.y -= 15.0;
		frame.size.height += 30.0;
		[self.mainScrollView scrollRectToVisible:frame animated:YES];
	}
}

- (void)keyboardDidHide:(NSNotification*)aNotification {
}

- (A3NumberKeyboardViewController *)numberKeyboardViewController {
	if (nil == _numberKeyboardViewController) {
		if (IS_IPAD) {
			_numberKeyboardViewController = [[A3NumberKeyboardViewController_iPad alloc] init];
		} else {
			_numberKeyboardViewController = [[A3NumberKeyboardViewController_iPhone alloc] init];
		}
		_numberKeyboardViewController.delegate = self;
	}
	return _numberKeyboardViewController;
}

- (void)updateTermValueFromText:(NSString *)text {
	NSNumberFormatter *decimalStyleNumberFormatter = [[NSNumberFormatter alloc] init];
	[decimalStyleNumberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	float value = [text floatValue];
	_object.termTypeMonth = [NSNumber numberWithBool:_numberKeyboardViewController.bigButton2.selected];
	if (value == 0.0) {
		_object.term = @"";
	} else {
		_object.term = _numberKeyboardViewController.bigButton1.selected ?
				[A3LoanCalcString stringFromTermInYears:value] : [A3LoanCalcString stringFromTermInMonths:value];
	}
}

- (void)updateInterestValueFromText:(NSString *)text {
	float value = [text floatValue] / 100.0;
	_object.interestRatePerYear = [NSNumber numberWithBool:_numberKeyboardViewController.bigButton1.selected];
	if (value != 0.0) {
		NSString *termType = _numberKeyboardViewController.bigButton1.selected ? @"Annual" : @"Monthly";
		_object.interestRate = [NSString stringWithFormat:@"%@ %@", termType, [self.percentNumberFormatter stringFromNumber:[NSNumber numberWithFloat:value]]];
	} else {
		_object.interestRate = @"";
	}
}

- (A3FrequencyKeyboardViewController *)frequencyKeyboardViewController {
	if (nil == _frequencyKeyboardViewController) {
		if (IS_IPAD) {
			_frequencyKeyboardViewController = [[A3FrequencyKeyboardViewController alloc] initWithNibName:@"A3FrequencyKeyboardViewController_iPad" bundle:nil];
		} else {
			_frequencyKeyboardViewController = [[A3FrequencyKeyboardViewController_iPhone alloc] initWithNibName:@"A3FrequencyKeyboardViewController_iPhone" bundle:nil];
		}
		_frequencyKeyboardViewController.delegate = self;
	}
	return _frequencyKeyboardViewController;
}

- (A3DateKeyboardViewController *)dateKeyboardViewController {
	if (nil == _dateKeyboardViewController) {
		if (IS_IPAD) {
			_dateKeyboardViewController = [[A3DateKeyboardViewController_iPad alloc] initWithNibName:@"A3DateKeyboardViewController_iPad" bundle:nil];
		} else {
			_dateKeyboardViewController = [[A3DateKeyboardViewController_iPhone alloc] initWithNibName:@"A3DateKeyboardViewController_iPhone" bundle:nil];
		}
		_dateKeyboardViewController.workingMode = A3DateKeyboardWorkingModeYearMonthDay;
		_dateKeyboardViewController.delegate = self;
	}
	return _dateKeyboardViewController;
}

- (A3DateKeyboardViewController *)dateKeyboardForMonthInput {
	if (nil == _dateKeyboardForMonthInput) {
		if (IS_IPAD) {
			_dateKeyboardForMonthInput = [[A3DateKeyboardViewController_iPad alloc] initWithNibName:@"A3DateKeyboardViewController_iPad" bundle:nil];
		} else {
			_dateKeyboardForMonthInput = [[A3DateKeyboardViewController_iPhone alloc] initWithNibName:@"A3DateKeyboardViewController_iPhone" bundle:nil];
		}
		_dateKeyboardForMonthInput.workingMode = A3DateKeyboardWorkingModeMonth;
		_dateKeyboardForMonthInput.delegate = self;
	}
	return _dateKeyboardForMonthInput;
}

- (A3DateKeyboardViewController *)dateKeyboardForYearMonthInput {
	if (nil == _dateKeyboardForYearMonthInput) {
		if (IS_IPAD) {
			_dateKeyboardForYearMonthInput = [[A3DateKeyboardViewController_iPad alloc] initWithNibName:@"A3DateKeyboardViewController_iPad" bundle:nil];
		} else {
			_dateKeyboardForYearMonthInput = [[A3DateKeyboardViewController_iPhone alloc] initWithNibName:@"A3DateKeyboardViewController_iPhone" bundle:nil];
		}
		_dateKeyboardForYearMonthInput.workingMode = A3DateKeyboardWorkingModeYearMonth;
		_dateKeyboardForYearMonthInput.delegate = self;
	}
	return _dateKeyboardForYearMonthInput;
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
	}
	return _percentNumberFormatter;
}

- (void)handleBigButton1 {

}

- (void)handleBigButton2 {

}

- (NSString *)stringForBigButton1 {
	return nil;
}

- (NSString *)stringForBigButton2 {
	return nil;
}

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
	if (_editingTextField) {
		_editingTextField.text = @"";
		NSUInteger index = [_textFields indexOfObject:_editingTextField];
		[_object setValue:@"" forKey:[_contentsKeyIndex objectAtIndex:index]];

		if ([_delegate respondsToSelector:@selector(loanCalcComparisonTableViewValueChanged)]) {
			[_delegate loanCalcComparisonTableViewValueChanged];
		}
	}
}

- (BOOL)prevAvailableForElement:(QEntryElement *)element {
	return [_textFields indexOfObject:_editingTextField] != 0;
}

- (BOOL)nextAvailableForElement:(QEntryElement *)element {
	return [_textFields lastObject] != _editingTextField;
}

- (void)prevButtonPressedWithElement:(QEntryElement *)element {
	NSUInteger currentIndex = [_textFields indexOfObject:_editingTextField];
	FNLOG(@"%d %@", currentIndex, _textFields);
	UITextField *newResponder = [_textFields objectAtIndex:(NSUInteger) MAX(currentIndex - 1, 0)];
	if (_editingTextField != newResponder) {
		[_editingTextField resignFirstResponder];
		[newResponder becomeFirstResponder];
	}
}

- (void)nextButtonPressedWithElement:(QEntryElement *)element {
	NSUInteger currentIndex = [_textFields indexOfObject:_editingTextField];
	UITextField *newResponder = [_textFields objectAtIndex:MIN(currentIndex + 1, [_textFields count] - 1)];
	if (_editingTextField != newResponder) {
		[_editingTextField resignFirstResponder];
		[newResponder becomeFirstResponder];
	}
}

- (void)dateKeyboardValueChangedDate:(NSDate *)date element:(QEntryElement *)element {
	NSUInteger index = [_textFields indexOfObject:_editingTextField];
	if (index != NSNotFound) {
		NSString *key = [_contentsKeyIndex objectAtIndex:index];
		[_object setValue:date forKey:key];
		if ([key isEqualToString:A3LC_KEY_START_DATE]) {
			_editingTextField.text = [A3Formatter mediumStyleDateStringFromDate:date];
		} else if (_editingTextField == _extraPaymentYearlyMonth) {
			_editingTextField.text = [A3Formatter fullStyleMonthSymbolFromDate:date];
		} else if (_editingTextField == _extraPaymentOneTimeYearMonth) {
			_editingTextField.text = [A3Formatter fullStyleYearMonthStringFromDate:date];
		}
		if ([_delegate respondsToSelector:@selector(loanCalcComparisonTableViewValueChanged)]) {
			[_delegate loanCalcComparisonTableViewValueChanged];
		}
	}
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate {
	FNLOG(@"Check");
	[_editingTextField resignFirstResponder];
}

- (void)frequencySelected:(NSNumber *)frequencyObject cell:(QEntryTableViewCell *)cell {
	_object.frequency = frequencyObject;
	_editingTextField.text = [A3LoanCalcString stringForFrequencyValue:frequencyObject];

	if ([_delegate respondsToSelector:@selector(loanCalcComparisonTableViewValueChanged)]) {
		[_delegate loanCalcComparisonTableViewValueChanged];
	}
}

- (void)reloadMainScrollViewContentSize {
	CGFloat height = IS_IPAD ? 289.0 : 192.0;
	CGFloat tableViewHeight = 0.0, rowHeight = IS_IPAD ? A3_TABLE_VIEW_ROW_HEIGHT_IPAD : A3_TABLE_VIEW_ROW_HEIGHT_IPHONE;
	tableViewHeight += _object.showAdvanced.boolValue ?  rowHeight * 7.0 : rowHeight * 4.0;
	tableViewHeight += _object.showDownPayment.boolValue ? rowHeight : 0.0;
//	tableViewHeight += _object.showExtraPayment.boolValue ? 53.0 + rowHeight * 3.0 : 0.0;
	tableViewHeight += 20.0;

	FNLOG(@"tableViewHeight %f", tableViewHeight);

	CGRect frame = self.brother.tableView.frame;
	frame.size.height = tableViewHeight;
	self.brother.tableView.frame = frame;

	frame = self.tableView.frame;
	frame.size.height = tableViewHeight;
	self.tableView.frame = frame;

	self.mainScrollView.contentSize = CGSizeMake(IS_IPAD ? 714.0 : 320.0, height + tableViewHeight);
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[_numberKeyboardViewController rotateToInterfaceOrientation:toInterfaceOrientation];
	[_frequencyKeyboardViewController rotateToInterfaceOrientation:toInterfaceOrientation];
	[_dateKeyboardViewController rotateToInterfaceOrientation:toInterfaceOrientation];
	[_dateKeyboardForMonthInput rotateToInterfaceOrientation:toInterfaceOrientation];
	[_dateKeyboardForYearMonthInput rotateToInterfaceOrientation:toInterfaceOrientation];
}

@end
