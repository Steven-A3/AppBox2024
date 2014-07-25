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
#import "A3WalletNoteCell.h"

@interface A3TableViewInputElement () <UITextFieldDelegate, A3KeyboardDelegate>

@property (nonatomic, strong) NSNumberFormatter *currencyFormatter;
@property (nonatomic, strong) NSNumberFormatter *percentFormatter;
@property (nonatomic, strong) NSNumberFormatter *decimalFormatter;

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
			if ((![self value] || [self.value length] == 0) && [self.placeholder length] > 0) {
				cell.textField.text = @"";
			}
			else {
				if (_valueType == A3TableViewValueTypePercent) {
					NSNumber *value = [self.decimalFormatter numberFromString:self.value];
                    cell.textField.text = [self.percentFormatter stringFromNumber:@([value doubleValue] / 100.0)];
				} else {
					NSNumberFormatter *decimalFormatter = [NSNumberFormatter new];
					[decimalFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
					NSNumber *number = [decimalFormatter numberFromString:self.value];
					cell.textField.text = [self.currencyFormatter stringFromNumber:number];
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
	_inputViewController.currencyCode = self.currencyCode;

	switch (type) {
		case A3TableViewEntryTypeText:
			break;
		case A3TableViewEntryTypeCurrency:
			_inputViewController.keyboardType = A3NumberKeyboardTypeCurrency;
			break;
		case A3TableViewEntryTypePercent:
			_inputViewController.keyboardType = A3NumberKeyboardTypePercent;
			[_inputViewController.bigButton1 setSelected:_valueType == A3TableViewValueTypePercent];
			[_inputViewController.bigButton2 setSelected:_valueType == A3TableViewValueTypeCurrency];
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
	if (_onEditingBegin) {
		_onEditingBegin(self, textField);
	}

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
            break;
	}
    
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	FNLOG();

//	if (_onEditingBegin) {
//		_onEditingBegin(self, textField);
//	}

	switch (self.inputType) {
		case A3TableViewEntryTypeText:
			break;
		case A3TableViewEntryTypeCurrency:
		case A3TableViewEntryTypeYears:
		case A3TableViewEntryTypePercent:
		case A3TableViewEntryTypeRealNumber:
		case A3TableViewEntryTypeInteger:
			textField.text = @"";
			textField.placeholder = @"";
			break;
	}

//	NSIndexPath *indexPath = [_rootTableView indexPathForCellSubview:textField];
//	if (indexPath) {
//		[self moveTableScrollToIndexPath:indexPath textField:textField ];
//	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	FNLOG(@"%@, %@", textField.text, string);

    return YES;
}

- (void)textFieldEditingChanged:(UITextField *)textField {
	if (self.coreDataObject && self.coreDataKey) {
		[self.coreDataKey setValue:textField.text forKey:self.coreDataKey];
	}

	if (_onEditingValueChanged) {
		_onEditingValueChanged(self, textField);
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	FNLOG(@"%@", textField.text);
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
			if ([self.value doubleValue] == 0.0) {
				if ([self.placeholder length]) {
					textField.text = @"";
					textField.placeholder = self.placeholder;
				} else {
					textField.text = [self.currencyFormatter stringFromNumber:@0];
				}
			} else {
				//textField.text = [self.currencyFormatter stringFromNumber:@([self.value doubleValue])];
                textField.text = [self.currencyFormatter stringFromNumber:[self.decimalFormatter numberFromString:[self value]]];
                //textField.text = [self.currencyFormatter stringFromNumber:@([self.value floatValue])];
			}
			break;
		}
		case A3TableViewEntryTypePercent:
		{
            if ((![self value] || [textField.text length] == 0) && [self.placeholder length] > 0) {
				if ([self.placeholder length]) {
					textField.text = @"";
					textField.placeholder = self.placeholder;
				} else {
					textField.text = [self.percentFormatter stringFromNumber:@0];
				}
            }
            else {
				if (self.value == nil && textField.text.length == 0) {
                    self.value = @"0";
                    if (_valueType == A3TableViewValueTypePercent) {
                        textField.text = [self.percentFormatter stringFromNumber:@(0)];
                    }
                    else {
                        textField.text = [self.currencyFormatter stringFromNumber:@(0)];
                    }
                    break;
                }
                
                if (_valueType == A3TableViewValueTypePercent) {
					NSNumber *value = [self.decimalFormatter numberFromString:self.value];
                    textField.text = [self.percentFormatter stringFromNumber:@([value doubleValue] / 100.0)];
                }
                else {
					NSNumber *value = [self.decimalFormatter numberFromString:self.value];
                    textField.text = [self.currencyFormatter stringFromNumber:value];
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
    self.value = @"0";
    ((UITextField *)keyInputDelegate).text = @"";
    
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
        
        if (![cell isKindOfClass:[A3JHTableViewEntryCell class]] && ![cell isKindOfClass:[A3TextViewCell class]] && ![cell isKindOfClass:[A3WalletNoteCell class]]
            ) {
            return;
        }
        
        if ([cell isKindOfClass:[A3JHTableViewEntryCell class]]) {
            [((A3JHTableViewEntryCell *)cell).textField becomeFirstResponder];
        }
        else if ([cell isKindOfClass:[A3WalletNoteCell class]]) {
            [((A3WalletNoteCell *)cell).textView becomeFirstResponder];
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

#pragma mark --- Response to Currency Select Button and result

- (NSNumberFormatter *)currencyFormatter {
	id <A3TableViewInputElementDelegate> delegate = self.delegate;
	if ([delegate respondsToSelector:@selector(currencyFormatterForTableViewInputElement)]) {

		return [delegate currencyFormatterForTableViewInputElement];
	}
	if (!_currencyFormatter) {
		_currencyFormatter = [NSNumberFormatter new];
		[_currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
		[_currencyFormatter setRoundingMode:NSNumberFormatterRoundDown];
		if (self.currencyCode) {
			[_currencyFormatter setCurrencyCode:self.currencyCode];
		}
	}
	return _currencyFormatter;
}

- (NSNumberFormatter *)percentFormatter {
	if (!_percentFormatter) {
		_percentFormatter = [NSNumberFormatter new];
		[_percentFormatter setNumberStyle:NSNumberFormatterPercentStyle];
		[_percentFormatter setRoundingMode:NSNumberFormatterRoundDown];
		[_percentFormatter setMaximumFractionDigits:3];
	}
	return _percentFormatter;
}

- (NSNumberFormatter *)decimalFormatter {
	if (!_decimalFormatter) {
		_decimalFormatter = [NSNumberFormatter new];
		[_decimalFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [_decimalFormatter setMaximumFractionDigits:3];
	}
	return _decimalFormatter;
}

@end
