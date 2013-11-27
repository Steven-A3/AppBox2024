//
//  A3TableViewEntryElement.m
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 10/22/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import "A3TableViewEntryElement.h"
#import "A3TableViewEntryCell.h"
#import "A3UIDevice.h"
#import "A3NumberKeyboardViewController.h"
#import "A3NumberKeyboardViewController_iPhone.h"
#import "A3NumberKeyboardViewController_iPad.h"

@interface A3TableViewEntryElement () <UITextFieldDelegate, A3KeyboardDelegate>

@property (strong) id inputViewController;


@end

@implementation A3TableViewEntryElement

- (UITableViewCell *)cellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
	NSString *reuseIdentifier = @"A3TableViewEntryElementCell";
	A3TableViewEntryCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (!cell) {
		cell = [[A3TableViewEntryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	}

	cell.selectionStyle = UITableViewCellSelectionStyleNone;

	cell.textLabel.text = self.title;
	cell.textLabel.textColor = [UIColor blackColor];
	cell.textField.text = self.value;
	cell.textField.placeholder = self.placeholder;
	cell.textField.delegate = self;
	[cell.textField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];

	[cell calculateTextFieldFrame];

	if ([self.imageName length]) {
		cell.imageView.image = [UIImage imageNamed:self.imageName];
	}

	return cell;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	switch (self.inputType) {
		case A3TableViewEntryTypeText:
			break;
		case A3TableViewEntryTypeCurrency:
			[self setupNumberKeyboardForTextField:textField keyboardType:A3NumberKeyboardTypeCurrency];
			break;
		case A3TableViewEntryTypeYears:
			[self setupNumberKeyboardForTextField:textField keyboardType:A3NumberKeyboardTypeMonthYear];
			break;
		case A3TableViewEntryTypeInterestRates:
			[self setupNumberKeyboardForTextField:textField keyboardType:A3NumberKeyboardTypePercent];
			break;
	}
	return YES;
}

- (void)setupNumberKeyboardForTextField:(UITextField *)textField keyboardType:(A3NumberKeyboardType)type {
	A3NumberKeyboardViewController *keyboardViewController;
	if (IS_IPHONE) {
		keyboardViewController = [[A3NumberKeyboardViewController_iPhone alloc] initWithNibName:@"A3NumberKeyboardViewController_iPhone" bundle:nil];
	} else {
		keyboardViewController = [[A3NumberKeyboardViewController_iPad alloc] initWithNibName:@"A3NumberKeyboardViewController_iPad" bundle:nil];
	}
	keyboardViewController.keyInputDelegate = textField;
	keyboardViewController.delegate = self;
	keyboardViewController.keyboardType = A3NumberKeyboardTypeCurrency;
	textField.inputView = keyboardViewController.view;
	_inputViewController = keyboardViewController;
}

- (void)textFieldEditingChanged:(UITextField *)textField {
	if (self.coreDataObject && self.coreDataKey) {
		[self.coreDataKey setValue:textField.text forKey:self.coreDataKey];
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	_inputViewController = nil;

	self.value = textField.text;

	switch (self.inputType) {
		case A3TableViewEntryTypeText:
			break;
		case A3TableViewEntryTypeCurrency: {
			NSNumberFormatter *currencyFormatter = [NSNumberFormatter new];
			[currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
			double number = [textField.text floatValue];
			textField.text = [currencyFormatter stringFromNumber:@(number)];
			break;
		}
		case A3TableViewEntryTypeYears: {

			break;
		}
		case A3TableViewEntryTypeInterestRates:
			break;
	}
}

- (void)handleBigButton1 {

}

- (void)handleBigButton2 {

}

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {

}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate {

}

- (BOOL)isPreviousEntryExists {
	return NO;
}

- (BOOL)isNextEntryExists {
	return NO;
}

- (void)prevButtonPressed {

}

- (void)nextButtonPressed {

}

@end
