//
//  A3TableViewInputElement.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 20..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3TableViewInputElement.h"
#import "A3JHTableViewEntryCell.h"
#import "A3NumberKeyboardViewController.h"
#import "A3NumberKeyboardViewController_iPhone.h"
#import "A3NumberKeyboardViewController_iPad.h"
#import "A3NumberKeyboardSimpleVC_iPad.h"
#import "A3JHTableViewExpandableHeaderCell.h"
#import "A3TextViewCell.h"
#import "UITableView+utility.h"
#import "A3SearchViewController.h"
#import "A3CalculatorDelegate.h"

@interface A3TableViewInputElement () <UITextFieldDelegate, A3KeyboardDelegate, A3CalculatorDelegate>

@property (nonatomic, weak) UITextField *calculatorTargetTextField;

@end

@implementation A3TableViewInputElement
{
    UITableView *_rootTableView;
    NSIndexPath *_currentIndexPath;
    UITextField *_firstResponder;   // temp...
}

- (UITableViewCell *)cellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *reuseIdentifier = @"A3TableViewInputElement";
	A3JHTableViewEntryCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
	if (!cell) {
		cell = [[A3JHTableViewEntryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        cell.textLabel.font = [UIFont fontWithName:cell.textLabel.font.fontName size:17.0];
		_currentIndexPath = nil;
		_firstResponder = nil;
		_inputViewController = nil;
        cell.textField.adjustsFontSizeToFitWidth = YES;
        cell.textField.minimumFontSize = 13.6;
	}
    
    if (self.inputType == A3TableViewEntryTypeText) {
        [cell.textField setReturnKeyType:UIReturnKeyDefault];
        [cell.textField setTextAlignment:NSTextAlignmentLeft];
        
        CGRect rect = cell.textField.frame;
        rect.size.width = cell.contentView.frame.size.width - rect.origin.x;
        cell.textField.frame = rect;
        
    } else {
        cell.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        cell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [cell.textField setReturnKeyType:UIReturnKeyDefault];
        [cell.textField setTextAlignment:NSTextAlignmentRight];
    }
    
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.textLabel.text = self.title;
	cell.textLabel.textColor = [UIColor blackColor];
	cell.textField.delegate = self;
    
    if (self.placeholder && self.placeholder.length > 0) {
        cell.textField.placeholder = self.placeholder;
    }

	switch (self.inputType) {
		case A3TableViewEntryTypeText:
			cell.textField.text = self.value;
			break;
		case A3TableViewEntryTypeCurrency:
		case A3TableViewEntryTypePercent: {
			NSNumberFormatter *currencyFormatter = [NSNumberFormatter new];

			if ((![self value] || [self.value length] == 0) && [self.placeholder length] > 0) {
				cell.textField.text = @"";
			}
			else {
				if (_valueType == A3TableViewValueTypePercent) {
					cell.textField.text = [NSString stringWithFormat:@"%@%%", [self value]];
				} else {
					[currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
					cell.textField.text = [currencyFormatter stringFromNumber:@([self.value doubleValue])];
				}
			}
			cell.textField.clearButtonMode = UITextFieldViewModeNever;
			break;
		}
		case A3TableViewEntryTypeYears:
		case A3TableViewEntryTypeRealNumber:
		case A3TableViewEntryTypeInteger:
			cell.textField.text = self.value;
			cell.textField.clearButtonMode = UITextFieldViewModeNever;
			break;
	}
	cell.textField.placeholder = self.placeholder;

    _rootTableView = tableView;
    _currentIndexPath = indexPath;
    
	[cell calculateTextFieldFrame];
    
	return cell;
}

-(void)didSelectCellInViewController:(UIViewController<A3JHSelectTableViewControllerProtocol> *)viewController tableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    A3JHTableViewEntryCell *cell = (A3JHTableViewEntryCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.textField) {
        [cell.textField becomeFirstResponder];
    }
}

- (void)setupNumberKeyboardForTextField:(UITextField *)textField keyboardType:(A3TableViewInputType)type {

	switch (type) {
		case A3TableViewEntryTypeText:
			break;
		case A3TableViewEntryTypeCurrency:
		case A3TableViewEntryTypePercent:
			if (IS_IPHONE) {
				_inputViewController = [[A3NumberKeyboardViewController_iPhone alloc] initWithNibName:@"A3NumberKeyboardViewController_iPhone" bundle:nil];
			} else {
				_inputViewController = [[A3NumberKeyboardViewController_iPad alloc] initWithNibName:@"A3NumberKeyboardViewController_iPad" bundle:nil];
			}
			break;
		case A3TableViewEntryTypeYears:
		case A3TableViewEntryTypeRealNumber:
		case A3TableViewEntryTypeInteger:
			if (IS_IPHONE) {
				_inputViewController = [[A3NumberKeyboardViewController_iPhone alloc] initWithNibName:@"A3NumberKeyboardSimplePrevNextClearVC_iPhone" bundle:nil];
			}
			else {
				_inputViewController = [[A3NumberKeyboardSimpleVC_iPad alloc] initWithNibName:@"A3NumberKeyboardSimplePrevNextClearVC_iPad" bundle:nil];
			}
			break;
	}

	_inputViewController.textInputTarget = textField;
	_inputViewController.delegate = self;
	textField.inputView = _inputViewController.view;

	switch (type) {
		case A3TableViewEntryTypeText:
			break;
		case A3TableViewEntryTypeCurrency:
			_inputViewController.keyboardType = A3NumberKeyboardTypeCurrency;
			break;
		case A3TableViewEntryTypePercent:
			_inputViewController.keyboardType = A3NumberKeyboardTypePercent;
			break;
		case A3TableViewEntryTypeYears:
			_inputViewController.keyboardType = A3NumberKeyboardTypeMonthYear;
			break;
		case A3TableViewEntryTypeInteger:
			_inputViewController.keyboardType = A3NumberKeyboardTypeInteger;
			break;
		case A3TableViewEntryTypeRealNumber:
			_inputViewController.keyboardType = A3NumberKeyboardTypeReal;
			break;
	}

	[_inputViewController reloadPrevNextButtons];
}

#pragma mark - Keyboard Event

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	FNLOG();
    _firstResponder = textField;

    [textField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    
	switch (self.inputType) {
		case A3TableViewEntryTypeText:
            textField.inputView = nil;
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
			break;
		case A3TableViewEntryTypeCurrency:
		case A3TableViewEntryTypeYears:
		case A3TableViewEntryTypePercent:
		case A3TableViewEntryTypeRealNumber:
		case A3TableViewEntryTypeInteger:
			[self setupNumberKeyboardForTextField:textField keyboardType:self.inputType];

            textField.text = @"";
            break;
	}
    
    if (_onEditingBegin) {
        _onEditingBegin(self, textField);
    }

	NSIndexPath *indexPath = [_rootTableView indexPathForCellSubview:textField];
	if (indexPath) {
		[self moveTableScrollToIndexPath:indexPath textField:textField ];
	}
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	FNLOG(@"%@, %@", textField.text, string);

    return YES;
}

- (void)textFieldEditingChanged:(UITextField *)textField {
	FNLOG(@"%@", textField.text);
	if ([textField.text doubleValue] == 0.0) {
		textField.text = @"";
	} else {
		NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
		[numberFormatter setUsesGroupingSeparator:NO];
		NSUInteger maximumFractionDigits = 3;
		if (self.inputType == A3TableViewEntryTypeCurrency || (self.inputType == A3TableViewEntryTypePercent && [_inputViewController.bigButton2 isSelected])) {
			[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
			if (self.currencyCode) {
				[numberFormatter setCurrencyCode:self.currencyCode];
			}
			[numberFormatter setCurrencySymbol:@""];
			maximumFractionDigits = numberFormatter.maximumFractionDigits;
		} else {
			[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		}
		NSRange testRange = [textField.text rangeOfString:numberFormatter.decimalSeparator];
		BOOL shouldAddDecimalSeparatorAtTheEnd = NO;
		if (testRange.location == [textField.text length] - 1) {
			shouldAddDecimalSeparatorAtTheEnd = YES;
		}
		if (testRange.location != NSNotFound) {
			NSArray *components = [textField.text componentsSeparatedByString:numberFormatter.decimalSeparator];
			[numberFormatter setMinimumFractionDigits:[components[1] length]];
		}

		// 이 코드가 실제로 값을 바꾸는 코드, 이전은 준비, 이후로는 보완하는 작업임
		textField.text = [numberFormatter stringFromNumber:@([textField.text doubleValue])];

		if (shouldAddDecimalSeparatorAtTheEnd) {
			textField.text = [textField.text stringByAppendingString:numberFormatter.decimalSeparator];
		}
	}

	if (self.coreDataObject && self.coreDataKey) {
		[self.coreDataKey setValue:textField.text forKey:self.coreDataKey];
	}

	if (_onEditingValueChanged) {
		_onEditingValueChanged(self, textField);
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField removeTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];

	if (self.inputType == A3TableViewEntryTypePercent) {
		_valueType = [_inputViewController.bigButton2 isSelected] ? A3TableViewValueTypeCurrency : A3TableViewValueTypePercent;
	}
	_inputViewController = nil;
	_firstResponder = nil;

    if (_onEditingFinishAll) {      // SalesCalc % 관련 부분을 위하여 별도로 추가.
        _onEditingFinishAll(self, textField);
        return;
    }
    
    if (_onEditingFinished) {
        _onEditingFinished(self, textField);
    }
    
	switch (self.inputType) {
		case A3TableViewEntryTypeText: {
            if (self.value == nil && textField.text.length == 0) {
                self.value = @"";
                textField.placeholder = [self placeholder];
            } else {
                textField.text = self.value;
            }
			break;
        }
		case A3TableViewEntryTypeCurrency: {
			NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
			[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
			if (self.currencyCode) {
				[numberFormatter setCurrencyCode:self.currencyCode];
			}
			if ([self.value doubleValue] == 0.0) {
				textField.text = @"";
				textField.placeholder = self.placeholder;
			} else {
				textField.text = [numberFormatter stringFromNumber:@([self.value doubleValue])];
			}
			break;
		}
		case A3TableViewEntryTypePercent:
		{
            NSNumberFormatter *formatter = [NSNumberFormatter new];
            
            if ((![self value] || [textField.text length] == 0) && [self.placeholder length] > 0) {
                textField.text = @"";
                textField.placeholder = self.placeholder;
            }
            else {
                if (self.value == nil && textField.text.length == 0) {
                    self.value = @"0";
                    //textField.placeholder = self.title;
                    if (_valueType == A3TableViewValueTypePercent) {
                        [formatter setNumberStyle:NSNumberFormatterPercentStyle];
                        textField.text = [formatter stringFromNumber:@(0)];
                    }
                    else {
                        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                        textField.text = [formatter stringFromNumber:@(0)];
                    }
                    break;
                }
                
                self.value = [self.value stringByReplacingOccurrencesOfString:@"," withString:@""];
                if (_valueType == A3TableViewValueTypePercent) {
                    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
                    [formatter setRoundingMode:NSNumberFormatterRoundDown];
                    textField.text = [NSString stringWithFormat:@"%@%%", [formatter stringFromNumber:@([self.value doubleValue])]];
                }
                else {
                    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                    [formatter setRoundingMode:NSNumberFormatterRoundDown];
                    textField.text = [formatter stringFromNumber:@([self.value doubleValue])];
                }
            }
			break;
		}

		case A3TableViewEntryTypeRealNumber:
		case A3TableViewEntryTypeInteger:
		case A3TableViewEntryTypeYears:
            textField.text = [NSString stringWithString:self.value];
			break;
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
	switch (self.inputType) {
		case A3TableViewEntryTypeText: {
            self.value = textField.text;
            if (_doneButtonPressed) {
                _doneButtonPressed(self);
            }
			break;
        }
        case A3TableViewEntryTypeCurrency:
            break;
        default:
            break;
    }
    
    return YES;
}

#pragma mark - Keyboard Function Button Event

- (void)handleBigButton1 {
    if (_onEditingValueChanged) {
        _onEditingValueChanged(self, _firstResponder);
    }
}

- (void)handleBigButton2 {
    if (_onEditingValueChanged) {
        _onEditingValueChanged(self, _firstResponder);
    }
}

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
    if ([self.title isEqualToString:@"Split"]) {
        return;
    }
    
    self.value = @"0";
    ((UITextField *)keyInputDelegate).text = @"";
    
//    NSNumberFormatter *currencyFormatter = [NSNumberFormatter new];
//    if (_valueType == A3TableViewValueTypePercent) {
//        [currencyFormatter setNumberStyle:NSNumberFormatterPercentStyle];
//        ((UITextField *)keyInputDelegate).placeholder = [currencyFormatter stringFromNumber:@(0)];
//    }
//    else {
//        [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
//        ((UITextField *)keyInputDelegate).placeholder = [currencyFormatter stringFromNumber:@(0)];
//    }
    
    if (_onEditingValueChanged) {
        _onEditingValueChanged(self, _firstResponder);
    }
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate {
    [keyInputDelegate resignFirstResponder];
    
    if (_doneButtonPressed) {
        _doneButtonPressed(self);
    }
}

- (BOOL)isPreviousEntryExists{
	return _prevEnabled;
}

- (BOOL)isNextEntryExists{
	return _nextEnabled;
}

- (void)prevButtonPressed{
    NSIndexPath *indexPath;
    if (_prevEnabled) {
        indexPath = [NSIndexPath indexPathForRow:_currentIndexPath.row - 1 inSection:_currentIndexPath.section];
        A3JHTableViewCell *cell = (A3JHTableViewCell *)[_rootTableView cellForRowAtIndexPath:indexPath];
        if (!cell || [cell isKindOfClass:[A3JHTableViewExpandableHeaderCell class]]) {
            NSInteger prevSectionRowCount = [_rootTableView numberOfRowsInSection:_currentIndexPath.section - 1];
            indexPath = [NSIndexPath indexPathForRow:prevSectionRowCount-1 inSection:_currentIndexPath.section - 1];
            cell = (A3JHTableViewCell *)[_rootTableView cellForRowAtIndexPath:indexPath];
        }
        
        if (![cell isKindOfClass:[A3JHTableViewEntryCell class]] ) {
            return;
        }
        
        if ([cell isKindOfClass:[A3JHTableViewEntryCell class]]) {
            [((A3JHTableViewEntryCell *)cell).textField becomeFirstResponder];
        }
        else {
            // kjh
            UITextView * tv = (UITextView * )[cell viewWithTag:A3TableViewCell_TextView_Tag];
            if (tv) {
                [tv becomeFirstResponder];
            }
        }
    }
}

- (void)nextButtonPressed{
    NSIndexPath *indexPath;
    
    if (_nextEnabled) {
        indexPath = [NSIndexPath indexPathForRow:_currentIndexPath.row + 1 inSection:_currentIndexPath.section];
        A3JHTableViewCell *cell = (A3JHTableViewCell *)[_rootTableView cellForRowAtIndexPath:indexPath];
        if (!cell) {
            indexPath = [NSIndexPath indexPathForRow:0 inSection:_currentIndexPath.section + 1];
            cell = (A3JHTableViewCell *)[_rootTableView cellForRowAtIndexPath:indexPath];
            if ([cell isKindOfClass:[A3JHTableViewExpandableHeaderCell class]]) {
                indexPath = [NSIndexPath indexPathForRow:1 inSection:_currentIndexPath.section + 1];
                cell = (A3JHTableViewCell *)[_rootTableView cellForRowAtIndexPath:indexPath];
            }
        }
        
        if (![cell isKindOfClass:[A3JHTableViewEntryCell class]] && ![cell isKindOfClass:[A3TextViewCell class]]) {
            return;
        }
        
        if ([cell isKindOfClass:[A3JHTableViewEntryCell class]]) {
            [((A3JHTableViewEntryCell *)cell).textField becomeFirstResponder];
        }
        else {
            // kjh
            [((A3TextViewCell *)cell).textView becomeFirstResponder];
        }
    }
}

#pragma mark - misc

- (void)moveTableScrollToIndexPath:(NSIndexPath *)indexPath textField:(UITextField *)textField {
    CGRect cellRect = [_rootTableView rectForRowAtIndexPath:indexPath];
	CGFloat keyboardHeight;
	if (textField) {
		keyboardHeight = textField.inputView.bounds.size.height + textField.inputAccessoryView.bounds.size.height;
	} else {
		keyboardHeight = _inputViewController.view.bounds.size.height;
	}
    if ((cellRect.origin.y + cellRect.size.height + _rootTableView.contentInset.top) < (_rootTableView.frame.size.height - keyboardHeight)) {
		return;
	}

	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];

	CGFloat offset = (cellRect.origin.y + cellRect.size.height) - (_rootTableView.frame.size.height - keyboardHeight);
    _rootTableView.contentOffset = CGPointMake(0.0, offset);

	[UIView commitAnimations];
}

#pragma mark --- Response to Calculator Button and result

- (UIViewController *)modalPresentingParentViewControllerForCalculator {
	_calculatorTargetTextField = _firstResponder;
	FNLOG(@"%@", _calculatorTargetTextField);

	UIViewController *viewController = nil;
	id <A3TableViewInputElementDelegate> o = self.delegate;
	if ([o respondsToSelector:@selector(containerViewController)]) {
		viewController = [o containerViewController];
	}
	return viewController;
}

- (id <A3CalculatorDelegate>)delegateForCalculator {
	return self;
}

- (void)calculatorViewController:(UIViewController *)viewController didDismissWithValue:(NSString *)value {
	_calculatorTargetTextField.text = value;
	[self textFieldDidEndEditing:_calculatorTargetTextField];
}

#pragma mark --- Response to Currency Select Button and result

- (UIViewController *)modalPresentingParentViewControllerForCurrencySelector {
	[_firstResponder resignFirstResponder];

	UIViewController *viewController = nil;
	id <A3TableViewInputElementDelegate> o = self.delegate;
	if ([o respondsToSelector:@selector(containerViewController)]) {
		viewController = [o containerViewController];
	}
	return viewController;
}

- (id <A3SearchViewControllerDelegate>)delegateForCurrencySelector {
	id<A3SearchViewControllerDelegate> delegate = nil;
	id <A3TableViewInputElementDelegate> o = self.delegate;
	if ([o respondsToSelector:@selector(delegateForCurrencySelector)]) {
		delegate = [o delegateForCurrencySelector];
	}
	return delegate;
}

@end
