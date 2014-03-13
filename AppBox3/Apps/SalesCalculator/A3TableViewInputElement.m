



//
//  A3TableViewInputElement.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 20..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3TableViewInputElement.h"
#import "A3JHTableViewEntryCell.h"
#import "A3UIDevice.h"
#import "A3NumberKeyboardViewController.h"
#import "A3NumberKeyboardViewController_iPhone.h"
#import "A3NumberKeyboardViewController_iPad.h"
#import "A3NumberKeyboardSimpleVC_iPad.h"
#import "A3TableViewInputElement.h"
#import "A3JHTableViewRootElement.h"
#import "A3JHTableViewExpandableElement.h"
#import "A3JHTableViewExpandableHeaderCell.h"
#import "A3TextViewCell.h"

@interface A3TableViewInputElement () <UITextFieldDelegate, A3KeyboardDelegate>
{
}

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
	//cell.textField.placeholder = self.placeholder;
	cell.textField.delegate = self;
    
//    if (!self.placeholder || self.placeholder.length==0) {
//        cell.textField.placeholder = self.title;
//    } else {
//        cell.textField.placeholder = self.placeholder;
//    }
    if (self.placeholder && self.placeholder.length > 0) {
        cell.textField.placeholder = self.placeholder;
    }
    
    if (self.inputType == A3TableViewEntryTypeCurrency) {
        NSNumberFormatter *currencyFormatter = [NSNumberFormatter new];
        
        if ([self.value isKindOfClass:[NSNumber class]]) {
            NSLog(@"asdfasdf");
        }
        
        if ((![self value] || [self.value length] == 0) && [self.placeholder length] > 0) {
            cell.textField.text = @"";
            cell.textField.placeholder = self.placeholder;
        }
        else {
            if (_valueType == A3TableViewValueTypePercent) {
//                [currencyFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
//                cell.textField.text = [NSString stringWithFormat:@"%@%%", [currencyFormatter stringFromNumber:@([self.value doubleValue])]];
                cell.textField.text = [NSString stringWithFormat:@"%@%%", [self value]];
            } else {
                [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                cell.textField.text = [currencyFormatter stringFromNumber:@([self.value doubleValue])];
            }
        }
        
        cell.textField.clearButtonMode = UITextFieldViewModeNever;
    }
//    else if (self.inputType == A3TableViewEntryTypeSimpleNumber) {
//        cell.textField.text = [self.value stringValue];
//    }
    else {
        cell.textField.text = self.value;
    }
    
    if ([_delegate respondsToSelector:@selector(tableElementRootDataSource)]) {
        
        A3JHTableViewRootElement *rootElement = [_delegate tableElementRootDataSource];
        
        if (indexPath.section==1 && indexPath.row==1) {
            A3JHTableViewExpandableElement *expandable = (A3JHTableViewExpandableElement *) rootElement.sectionsArray[1][2];
            _nextEnabled = expandable.collapsed == NO ? YES : NO;
        }
    }
    
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

-(void)keyboardWillShow:(NSNotification *)aNoti
{
    NSNumber *animationCurve = [aNoti.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey];
    NSNumber *animationDuration = [aNoti.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey];

    [UIView beginAnimations:@"KeyboardWillShow" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationCurve:[animationCurve intValue]];
    [UIView setAnimationDuration:[animationDuration doubleValue]];
    
    [self moveTableScrollToIndexPath:_currentIndexPath];

    [UIView commitAnimations];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)setupNumberKeyboardForTextField:(UITextField *)textField keyboardType:(A3TableViewInputType)type {

    if (type == A3TableViewEntryTypeSimpleNumber) {
        if (IS_IPHONE) {
            _inputViewController = [[A3NumberKeyboardViewController_iPhone alloc] initWithNibName:@"A3NumberKeyboardSimpleVC_iPhone" bundle:nil];
            _inputViewController.textInputTarget = textField;
            _inputViewController.delegate = self;
            textField.inputView = _inputViewController.view;
        }
        else {
            _inputViewController = [[A3NumberKeyboardSimpleVC_iPad alloc] initWithNibName:@"A3NumberKeyboardSimpleVC_iPad" bundle:nil];
            _inputViewController.prevBtnTitleText = @"UP";
            _inputViewController.nextBtnTitleText = @"DOWN";
            _inputViewController.textInputTarget = textField;
            _inputViewController.delegate = self;
            textField.inputView = _inputViewController.view;
            [((A3NumberKeyboardViewController_iPad *)_inputViewController).prevButton setTitle:@"UP" forState:UIControlStateNormal];
            [((A3NumberKeyboardViewController_iPad *)_inputViewController).nextButton setTitle:@"DOWN" forState:UIControlStateNormal];

			// TODO: 아래 한줄의 용도를 정환이에게 확인해야 함
//            [((A3NumberKeyboardViewController_iPad *)_inputViewController).prevButton removeTarget:self action:@selector(clearButtonAction) forControlEvents:UIControlEventTouchUpInside];
//            _inputViewController.prevBtnTitleText = @"UP";
//            _inputViewController.nextBtnTitleText = @"DOWN";
        }

//        _inputViewController.keyInputDelegate = textField;
//        _inputViewController.delegate = self;
//        textField.inputView = _inputViewController.view;
    }
    else {
        if (IS_IPHONE) {
            _inputViewController = [[A3NumberKeyboardViewController_iPhone alloc] initWithNibName:@"A3NumberKeyboardViewController_iPhone" bundle:nil];
            _inputViewController.textInputTarget = textField;
            _inputViewController.delegate = self;
            textField.inputView = _inputViewController.view;
            _inputViewController.keyboardType = A3NumberKeyboardTypeCurrency;
        }
        else {
            _inputViewController = [[A3NumberKeyboardViewController_iPad alloc] initWithNibName:@"A3NumberKeyboardViewController_iPad" bundle:nil];
            _inputViewController.prevBtnTitleText = @"UP";
            _inputViewController.nextBtnTitleText = @"DOWN";
            _inputViewController.textInputTarget = textField;
            _inputViewController.delegate = self;
            textField.inputView = _inputViewController.view;
            _inputViewController.keyboardType = A3NumberKeyboardTypeCurrency;
            [((A3NumberKeyboardViewController_iPad *)_inputViewController).prevButton setTitle:@"UP" forState:UIControlStateNormal];
            [((A3NumberKeyboardViewController_iPad *)_inputViewController).nextButton setTitle:@"DOWN" forState:UIControlStateNormal];
        }
    }

    [_inputViewController reloadPrevNextButtons];
}

#pragma mark - Keyboard Event

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    NSLog(@"textFieldShouldBeginEditing");
    _firstResponder = textField;
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [textField addTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    
	switch (self.inputType) {
		case A3TableViewEntryTypeText:
        {
            textField.inputView = nil;
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        }
			break;
            
		case A3TableViewEntryTypeCurrency:
        {
			[self setupNumberKeyboardForTextField:textField keyboardType:A3TableViewEntryTypeCurrency];

            textField.text = @"";
        }
            break;
            
		case A3TableViewEntryTypeYears:
        {
			[self setupNumberKeyboardForTextField:textField keyboardType:A3TableViewEntryTypeSimpleNumber];
        }
			break;
            
		case A3TableViewEntryTypeInterestRates:
        {
			[self setupNumberKeyboardForTextField:textField keyboardType:A3TableViewEntryTypeSimpleNumber];
        }
			break;
            
        case A3TableViewEntryTypeSimpleNumber:
        {
            [self setupNumberKeyboardForTextField:textField keyboardType:A3TableViewEntryTypeSimpleNumber];
            
            textField.text = @"";
        }
            break;

        default:
        {
            FNLOG(@"set keyboard type");
        }
            break;
	}
    
    if (_onEditingBegin) {
        _onEditingBegin(self, textField);
    }
    
	return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"%@", string);
    return YES;
}

- (void)textFieldEditingChanged:(UITextField *)textField {
    NSLog(@"textFieldEditingChanged");
	if (self.coreDataObject && self.coreDataKey) {
		[self.coreDataKey setValue:textField.text forKey:self.coreDataKey];
	}

    // KJH
    // 소수점 체크
    if (_inputType == A3TableViewEntryTypeCurrency) {
        NSArray *decimalCheck = [textField.text componentsSeparatedByString:@"."];
        if (decimalCheck.count>2) {
            textField.text = [NSString stringWithFormat:@"%@", @(textField.text.doubleValue)];
            return;
        }
        if (decimalCheck.count==2 && [decimalCheck[1] length]==0) {
            return;
        }
        
        if (decimalCheck.count == 2 && ((NSString *)decimalCheck[1]).length > 3) {
            NSNumberFormatter *formatter = [NSNumberFormatter new];
            if (_valueType == A3TableViewValueTypePercent) {
                [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
                [formatter setRoundingMode:NSNumberFormatterRoundDown];
                textField.text = [NSString stringWithFormat:@"%@%%", [formatter stringFromNumber:@([self.value doubleValue])]];
                textField.text = [textField.text stringByReplacingOccurrencesOfString:[formatter percentSymbol] withString:@""];
            }
            else {
                [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
                [formatter setRoundingMode:NSNumberFormatterRoundDown];
                textField.text = [formatter stringFromNumber:@([self.value doubleValue])];
                textField.text = [textField.text stringByReplacingOccurrencesOfString:[formatter currencySymbol] withString:@""];
            }
            
            return;
        }
    }
    else if (_inputType == A3TableViewEntryTypeSimpleNumber) {
        
    }


    if (_onEditingValueChanged) {
        _onEditingValueChanged(self, textField);
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField removeTarget:self action:@selector(textFieldEditingChanged:) forControlEvents:UIControlEventEditingChanged];
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
        }
			break;
		case A3TableViewEntryTypeCurrency: {
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
                
                if ([self.value isKindOfClass:[NSNumber class]]) {
                    NSLog(@"asdfasdf");
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
            
		case A3TableViewEntryTypeSimpleNumber: {
            textField.text = [NSString stringWithString:self.value];
			break;
		}
            
		case A3TableViewEntryTypeYears: {
            
			break;
		}
            
		case A3TableViewEntryTypeInterestRates:
			break;
            
        default:
            break;
	}
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
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

-(NSString *)stringForBigButton1 {
    if (_bigButton1Type == A3TableViewBigButtonTypeCurrency) {
        _inputViewController.bigButton1.selected = _valueType == A3TableViewValueTypeCurrency ? YES : NO;
        NSNumberFormatter *nf = [NSNumberFormatter new];
        return [NSString stringWithFormat:@"%@", [nf currencyCode]];
        
    } else if (_bigButton1Type == A3TableViewBigButtonTypePercent) {
        _inputViewController.bigButton1.selected = _valueType == A3TableViewValueTypePercent ? YES : NO;
        return @"%";
    }
    
    return @"";
}

-(NSString *)stringForBigButton2 {
    
    if (_bigButton2Type == A3TableViewBigButtonTypeCalculator) {
        UIImage *image = [UIImage imageNamed:@"calculator.png"];
        [_inputViewController.bigButton2 setImage:image forState:UIControlStateNormal];
        [_inputViewController.bigButton2 setTitle:@"" forState:UIControlStateNormal];
        return @"";
        
    } else if (_bigButton2Type == A3TableViewBigButtonTypeCurrency) {
        _inputViewController.bigButton2.selected = _valueType == A3TableViewValueTypeCurrency ? YES : NO;
        NSNumberFormatter *nf = [NSNumberFormatter new];
        //return [NSString stringWithFormat:@"%@", [nf currencyCode]];
        [_inputViewController.bigButton2 setImage:nil forState:UIControlStateNormal];
        return [NSString stringWithFormat:@"%@", [nf currencySymbol]];
        
    } else if (_bigButton2Type == A3TableViewBigButtonTypePercent) {
        [_inputViewController.bigButton2 setImage:nil forState:UIControlStateNormal];
        _inputViewController.bigButton2.selected = _valueType == A3TableViewValueTypePercent ? YES : NO;
        return @"%";
    }
    
    return @"";
}

- (NSString *)stringForPrevButton:(NSString *)current {
    if (IS_IPAD) {
        return @"Up";
    }
    
    return current;
}

- (NSString *)stringForNextButton:(NSString *)current {
    if (IS_IPAD) {
        return @"Down";
    }
    
    return current;
}

- (void)handleBigButton1 {
    switch (_bigButton1Type) {
        case A3TableViewBigButtonTypeCurrency:
            _valueType = A3TableViewValueTypeCurrency;
            break;
        case A3TableViewBigButtonTypePercent:
            _valueType = A3TableViewValueTypePercent;
            break;
        default:
            break;
    }
    
    _inputViewController.bigButton1.selected = YES;
    _inputViewController.bigButton2.selected = NO;

    if (_onEditingValueChanged) {
        _onEditingValueChanged(self, _firstResponder);
    }
}

- (void)handleBigButton2 {
    
    switch (_bigButton2Type) {
        case A3TableViewBigButtonTypeCurrency:
            _valueType = A3TableViewValueTypeCurrency;
            break;
        case A3TableViewBigButtonTypePercent:
            _valueType = A3TableViewValueTypePercent;
            break;
        case A3TableViewBigButtonTypeCalculator:
        {
            if (_inputViewController) {
                _inputViewController.bigButton1.selected = YES;
                _inputViewController.bigButton2.selected = NO;
                return;
            }
        }
            break;
        default:
            break;
    }
    
    _inputViewController.bigButton1.selected = NO;
    _inputViewController.bigButton2.selected = YES;
    
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
        
        [self moveTableScrollToIndexPath:indexPath];
        
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
        
        [self moveTableScrollToIndexPath:indexPath];
        
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

- (void)moveTableScrollToIndexPath:(NSIndexPath *)indexPath
{
//    [UIView beginAnimations:@"KeyboardWillShow" context:nil];
//    [UIView setAnimationBeginsFromCurrentState:YES];
//    [UIView setAnimationCurve:7];
//    [UIView setAnimationDuration:0.35];
    
    FNLOG(@"rootTableView: %@", _rootTableView);
    FNLOG(@"inputViewController: %@", _inputViewController);
    CGRect cellRect = [_rootTableView rectForRowAtIndexPath:indexPath];
    if ((cellRect.origin.y + cellRect.size.height + _rootTableView.contentInset.top) < (_rootTableView.frame.size.height-((A3NumberKeyboardViewController *)_inputViewController).view.bounds.size.height))
        return;
    CGFloat offset = (cellRect.origin.y + cellRect.size.height) - (_rootTableView.frame.size.height - ((A3NumberKeyboardViewController *)_inputViewController).view.bounds.size.height);
    _rootTableView.contentOffset = CGPointMake(0.0, offset);
    
//    [UIView commitAnimations];
}

@end
