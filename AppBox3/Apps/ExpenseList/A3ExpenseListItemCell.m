	//
//  A3ExpenseListItemCell.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ExpenseListItemCell.h"
#import "A3ExpenseListAccessoryView.h"
#import "A3NumberKeyboardViewController.h"
#import "A3NumberKeyboardViewController_iPhone.h"
#import "A3NumberKeyboardViewController_iPad.h"
#import "A3CalculatorDelegate.h"
#import "A3NumberKeyboardSimpleVC_iPad.h"
#import "A3ExpenseListMainViewcontroller.h"
#import "NSString+conversion.h"


	@interface A3ExpenseListItemCell() <UITextFieldDelegate, A3KeyboardDelegate, A3ExpenseListAccessoryDelegate, A3CalculatorDelegate>
@property (nonatomic, strong) UIButton *checkButton;
@property (nonatomic, strong) UIView *sep1View;
@property (nonatomic, strong) UIView *sep2View;
@property (nonatomic, strong) UIView *sep3View;
@property (nonatomic, strong) MASConstraint *sep1Const;
@property (nonatomic, strong) MASConstraint *sep2Const;
@property (nonatomic, strong) MASConstraint *sep3Const;
@property (nonatomic, strong) id inputViewController;
@property (nonatomic, strong) A3ExpenseListAccessoryView *keyboardAccessoryView;
@property (nonatomic, weak) UITextField *calculatorTargetTextField;
@property (nonatomic, copy) NSString *textBeforeEditingTextField;
@end

@implementation A3ExpenseListItemCell
{
    UITextField *_firstResponder;
    BOOL _nextColumnAvail, _prevColumnAvail;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self initializeSubviews];
        [self setupConstraintLayout];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
	[self adjustConstraintLayout];
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initializeSubviews
{
    _checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _sep1View = [[UIView alloc] initWithFrame:CGRectZero];
    _sep2View = [[UIView alloc] initWithFrame:CGRectZero];
    _sep3View = [[UIView alloc] initWithFrame:CGRectZero];
    
    _nameTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    _priceTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    _qtyTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    _subTotalLabel = [[UILabel alloc] initWithFrame:CGRectZero];

    _checkButton.layer.borderColor = [[UIColor colorWithRed:227.0/255.0 green:227.0/255.0 blue:229.0/255.0 alpha:1.0] CGColor];
    _checkButton.layer.borderWidth = 0.5;
    [_checkButton addTarget:self action:@selector(checkButtonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    _checkButton.hidden = YES;
    
    _nameTextField.delegate = self;
    _priceTextField.delegate = self;
    _qtyTextField.delegate = self;
    
    //_nameTextField.placeholder = @"item";
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    _priceTextField.placeholder = [formatter stringFromNumber:@0];
    _qtyTextField.placeholder = @"0";
    
    _sep1View.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
    _sep2View.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
    _sep3View.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];

    _nameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _priceTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _qtyTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _nameTextField.textAlignment = NSTextAlignmentLeft;
    _priceTextField.textAlignment = NSTextAlignmentRight;
    _qtyTextField.textAlignment = NSTextAlignmentCenter;
    _subTotalLabel.textAlignment = NSTextAlignmentRight;
    _nameTextField.clearButtonMode = UITextFieldViewModeNever;

    [self.contentView addSubview:_checkButton];
    [self.contentView addSubview:_sep1View];
    [self.contentView addSubview:_sep2View];
    [self.contentView addSubview:_sep3View];
    [self.contentView addSubview:_nameTextField];
    [self.contentView addSubview:_priceTextField];
    [self.contentView addSubview:_qtyTextField];
    [self.contentView addSubview:_subTotalLabel];
}

- (void)setupConstraintLayout
{
	CGFloat leftInset = IS_IPHONE ? 15 : 28;
	CGFloat sep1_Item = ceilf(CGRectGetWidth(self.contentView.frame) * 0.33);
	CGFloat sep2_Price = ceilf(CGRectGetWidth(self.contentView.frame) * 0.26);
	CGFloat sep3_Quantity = ceilf(CGRectGetWidth(self.contentView.frame) * 0.11);
    
	[_checkButton makeConstraints:^(MASConstraintMaker *make) {
		make.leading.equalTo(@15);
		make.centerY.equalTo(self.centerY);
		make.width.equalTo(@21);
		make.height.equalTo(@21);
	}];
    
	[_sep1View makeConstraints:^(MASConstraintMaker *make) {
		_sep1Const = make.leading.equalTo(@(leftInset + sep1_Item));
		make.top.equalTo(self.contentView.top);
		make.width.equalTo(IS_RETINA? @0.5 : @1);
		make.height.equalTo(self.contentView.height);
	}];
    
	[_sep2View makeConstraints:^(MASConstraintMaker *make) {
		_sep2Const = make.leading.equalTo(@(leftInset + sep1_Item + sep2_Price));
		make.top.equalTo(self.contentView.top);
		make.width.equalTo(IS_RETINA? @0.5 : @1);
		make.height.equalTo(self.contentView.height);
	}];
    
	[_sep3View makeConstraints:^(MASConstraintMaker *make) {
		_sep3Const = make.leading.equalTo(@(leftInset + sep1_Item + sep2_Price + sep3_Quantity));
		make.top.equalTo(self.contentView.top);
		make.width.equalTo(IS_RETINA? @0.5 : @1);
		make.height.equalTo(self.contentView.height);
	}];
    
	[_nameTextField makeConstraints:^(MASConstraintMaker *make) {
		if (IS_IPHONE) {
			make.leading.equalTo(@15);
		} else {
			make.leading.equalTo(@28);
		}
		make.trailing.equalTo(_sep1View.left);
        make.centerY.equalTo(self.contentView.centerY);
        make.height.equalTo(@23.0);
    }];
    
    [_priceTextField makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_sep1View.right);
        make.trailing.equalTo(_sep2View.left).with.offset(IS_IPHONE ? -5 : IS_RETINA ? -9.5 : -9);
        make.centerY.equalTo(self.contentView.centerY);
        make.height.equalTo(@23.0);
    }];
    
    [_qtyTextField makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_sep2View.right);
        make.trailing.equalTo(_sep3View.left);
        make.centerY.equalTo(self.contentView.centerY);
        make.height.equalTo(@23.0);
    }];
    
    [_subTotalLabel makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(_sep3View.right);
        make.trailing.equalTo(self.contentView.right).with.offset(IS_IPHONE ? -5 : IS_RETINA ? -9.5 : -9);
        make.centerY.equalTo(self.contentView.centerY);
        make.height.equalTo(@23.0);
    }];
}

- (void)adjustConstraintLayout
{
	CGFloat leftInset = IS_IPHONE ? 15 : 28;
	CGFloat sep1_Item = ceilf(CGRectGetWidth(self.contentView.frame) * 0.33);
	CGFloat sep2_Price = ceilf(CGRectGetWidth(self.contentView.frame) * 0.26);
	CGFloat sep3_Quantity = ceilf(CGRectGetWidth(self.contentView.frame) * 0.11);
    
	if (IS_IPAD) {
		_nameTextField.font = [UIFont systemFontOfSize:17.0];
		_priceTextField.font = [UIFont systemFontOfSize:17.0];
		_qtyTextField.font = [UIFont systemFontOfSize:17.0];
		_subTotalLabel.font = [UIFont systemFontOfSize:17.0];
	}
	else {
		_nameTextField.font = [UIFont systemFontOfSize:13.0];
		_priceTextField.font = [UIFont systemFontOfSize:13.0];
		_qtyTextField.font = [UIFont systemFontOfSize:13.0];
		_subTotalLabel.font = [UIFont systemFontOfSize:13.0];
	}
    
	_sep1Const.equalTo(@(leftInset + sep1_Item));
	_sep2Const.equalTo(@(leftInset + sep1_Item + sep2_Price));
	_sep3Const.equalTo(@(leftInset + sep1_Item + sep2_Price + sep3_Quantity));
}

#pragma mark - Actions

- (void)checkButtonTouchUp:(id)sender
{
    _checkButton.selected = !_checkButton.selected;
    [_checkButton setImage:[UIImage imageNamed: _checkButton.selected? @"check_02" : nil] forState:UIControlStateNormal];
}

- (void)doneButtonTouchUp:(id)sender
{
    [_firstResponder resignFirstResponder];
    
    if ([_delegate respondsToSelector:@selector(itemCellTextFieldDonePressed:)]) {
        [_delegate itemCellTextFieldDonePressed:self];
    }
}

#pragma mark - TextField

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([_delegate respondsToSelector:@selector(itemCellTextFieldBeginEditing:textField:)]) {
        [_delegate itemCellTextFieldBeginEditing:self textField:textField];
    }
    
    if (textField == _nameTextField) {
		textField.returnKeyType = UIReturnKeyDefault;
        textField.inputAccessoryView = [self keyboardAccessoryView];
        [self.keyboardAccessoryView undoRedoButtonStateChangeFor:textField];
        
    }
    else if (textField == _priceTextField) {
        A3NumberKeyboardViewController *keyboardViewController;
        if (IS_IPHONE) {
            keyboardViewController = [[A3NumberKeyboardViewController_iPhone alloc] initWithNibName:@"A3NumberKeyboardSimpleVC_iPhone" bundle:nil];
        } else {
            keyboardViewController = [[A3NumberKeyboardSimpleVC_iPad alloc] initWithNibName:@"A3NumberKeyboardSimpleVC_iPad" bundle:nil];
        }
        
        keyboardViewController.textInputTarget = textField;
        keyboardViewController.delegate = self;
        textField.inputView = keyboardViewController.view;
		textField.inputAccessoryView = [self keyboardAccessoryView];
		keyboardViewController.currencyCode = self.defaultCurrencyCode;
        keyboardViewController.keyboardType = A3NumberKeyboardTypeCurrency;
		[keyboardViewController.clearButton setTitle:@"" forState:UIControlStateNormal];
		[keyboardViewController.clearButton setEnabled:NO];

		_inputViewController = keyboardViewController;
        
    }
    else if (textField == _qtyTextField) {
        A3NumberKeyboardViewController *keyboardViewController;
        if (IS_IPHONE) {
            keyboardViewController = [[A3NumberKeyboardViewController_iPhone alloc] initWithNibName:@"A3NumberKeyboardSimpleVC_iPhone" bundle:nil];
        } else {
            keyboardViewController = [[A3NumberKeyboardSimpleVC_iPad alloc] initWithNibName:@"A3NumberKeyboardSimpleVC_iPad" bundle:nil];
        }
        
        keyboardViewController.textInputTarget = textField;
        keyboardViewController.delegate = self;
        textField.inputView = keyboardViewController.view;
		textField.inputAccessoryView = [self keyboardAccessoryView];
        keyboardViewController.keyboardType = A3NumberKeyboardTypeInteger;
		[keyboardViewController.clearButton setTitle:@"" forState:UIControlStateNormal];
		[keyboardViewController.clearButton setEnabled:NO];

        _inputViewController = keyboardViewController;
    }

    return YES;
}

	- (NSString *)defaultCurrencyCode {
		NSString *currencyCode = [[NSUserDefaults standardUserDefaults] objectForKey:A3ExpenseListCurrencyCode];
		if (!currencyCode) {
			currencyCode = [[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode];
		}
		return currencyCode;
	}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	_firstResponder = textField;
	_textBeforeEditingTextField = textField.text;

	if (_nameTextField != textField) {
		if (textField == _qtyTextField) {
			textField.placeholder = @"1";
		} else {
			textField.placeholder = @"";
		}
		textField.text = @"";
	}

	[self.keyboardAccessoryView undoRedoButtonStateChangeFor:textField];
	[self showEraseButtonIfNeeded];
	[self changeDirectionButtonStateFor:textField];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self.keyboardAccessoryView undoRedoButtonStateChangeFor:textField];
    [self changeDirectionButtonStateFor:textField];

	NSMutableString *resultString = [textField.text mutableCopy];
	[resultString replaceCharactersInRange:range withString:string];
	FNLOG(@"%@", resultString);
	[self.keyboardAccessoryView showEraseButton:[resultString length] || [_textBeforeEditingTextField length]];

    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if (textField != _nameTextField && [textField.text length] == 0) {
		textField.text = _textBeforeEditingTextField;
	}

	if ([_delegate respondsToSelector:@selector(itemCellTextFieldFinished:textField:)]) {
		[_delegate itemCellTextFieldFinished:self textField:textField];
	}

	_firstResponder = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //[self doneButtonTouchUp:textField];
	[textField resignFirstResponder];

    return YES;
}

#pragma mark - TextField Related

- (A3ExpenseListAccessoryView *)keyboardAccessoryView {
    if (!_keyboardAccessoryView) {
        _keyboardAccessoryView = [[A3ExpenseListAccessoryView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 45.0)];
    }
    
    _keyboardAccessoryView.delegate = self;
    
    return _keyboardAccessoryView;
}

- (void)showEraseButtonIfNeeded
{
	[self.keyboardAccessoryView showEraseButton:[_firstResponder.text length] || [_textBeforeEditingTextField length]];
}

- (void)changeDirectionButtonStateFor:(UITextField *)textField
{
    _prevColumnAvail = YES;
	_nextColumnAvail = YES;

	if (textField == _nameTextField) {
		if ([_delegate respondsToSelector:@selector(upwardRowAvailableFor:)]) {
			_prevColumnAvail = [_delegate upwardRowAvailableFor:self];
		}
	}
    else if (textField == _qtyTextField) {
        if ([_delegate respondsToSelector:@selector(downwardRowAvailableFor:)]) {
            _nextColumnAvail = [_delegate downwardRowAvailableFor:self];
        }
    }
	[self.keyboardAccessoryView.prevButton setEnabled:_prevColumnAvail];
	[self.keyboardAccessoryView.nextButton setEnabled:_nextColumnAvail];
}

#pragma mark - NumberKeyboard

- (void)handleBigButton1 {
    if (_firstResponder == _priceTextField) {
    } else if (_firstResponder == _qtyTextField) {
        ((A3NumberKeyboardViewController *)_inputViewController).bigButton1.selected = NO;
        ((A3NumberKeyboardViewController *)_inputViewController).bigButton2.selected = NO;
    }
}

- (void)handleBigButton2 {
    if (_firstResponder == _priceTextField) {
        ((A3NumberKeyboardViewController *)_inputViewController).bigButton1.selected = YES;
        ((A3NumberKeyboardViewController *)_inputViewController).bigButton2.selected = NO;
    } else if (_firstResponder == _qtyTextField) {
        ((A3NumberKeyboardViewController *)_inputViewController).bigButton1.selected = NO;
        ((A3NumberKeyboardViewController *)_inputViewController).bigButton2.selected = NO;
    }
}

- (void)A3KeyboardController:(id)controller doneButtonPressedTo:(UIResponder *)keyInputDelegate {
    [self doneButtonTouchUp:keyInputDelegate];
}

- (BOOL)isPreviousEntryExists{
	return _prevColumnAvail;
}

- (BOOL)isNextEntryExists{
	return _nextColumnAvail;
}

- (void)prevButtonPressed{
	[self keyboardAccessoryPrevButtonTouchUp:nil];
}

- (void)nextButtonPressed {
	[self keyboardAccessoryNextButtonTouchUp:nil];
}

- (void)moveUpRow {
    if ([_delegate respondsToSelector:@selector(moveUpRowFor:textField:)]) {
        [_delegate moveUpRowFor:self textField:_firstResponder];
    }
}

- (void)moveDownRow {
    if ([_delegate respondsToSelector:@selector(moveDownRowFor:textField:)]) {
        [_delegate moveDownRowFor:self textField:_firstResponder];
    }
}

#pragma mark - KeyboardAccessoryView Delegate

- (void)keyboardAccessoryUndoButtonTouchUp:(id)sender {
    if ([[_firstResponder undoManager] canUndo]) {
        [[_firstResponder undoManager] undo];

		[self.keyboardAccessoryView undoRedoButtonStateChangeFor:_firstResponder];
		[self showEraseButtonIfNeeded];
    }
}

- (void)keyboardAccessoryRedoButtonTouchUp:(id)sender {
    if ([[_firstResponder undoManager] canRedo]) {
        [[_firstResponder undoManager] redo];

		[self.keyboardAccessoryView undoRedoButtonStateChangeFor:_firstResponder];
		[self showEraseButtonIfNeeded];
    }
}

- (void)keyboardAccessoryPrevButtonTouchUp:(id)sender {
    if (_firstResponder == _qtyTextField) {
        [_priceTextField becomeFirstResponder];
    } else if (_firstResponder == _priceTextField) {
        [_nameTextField becomeFirstResponder];
    } else if (_firstResponder == _nameTextField) {
        [self moveUpRow];
    }
}

- (void)keyboardAccessoryNextButtonTouchUp:(id)sender {
	if (_firstResponder == _nameTextField) {
		[_priceTextField becomeFirstResponder];
	} else if (_firstResponder == _priceTextField) {
		[_qtyTextField becomeFirstResponder];
	} else if (_firstResponder == _qtyTextField) {
		[self moveDownRow];
	}
}

- (void)keyboardAccessoryEraseButtonTouchUp:(id)sender {
	_textBeforeEditingTextField = @"";
	if ([_firstResponder.text length]) {
		[self setFirstResponderText:@""];
		[self.keyboardAccessoryView undoRedoButtonStateChangeFor:_firstResponder];
	}
	[self showEraseButtonIfNeeded];
}

- (void)setFirstResponderText:(NSString *)newText
{
	[[_firstResponder.undoManager prepareWithInvocationTarget:self] setFirstResponderText:_firstResponder.text];
    _firstResponder.text = newText;
}

- (UIViewController *)modalPresentingParentViewControllerForCalculator {
	UIViewController *viewController = nil;
	if ([_delegate respondsToSelector:@selector(modalPresentingViewControllerForCalculator)]) {
		viewController = [_delegate modalPresentingViewControllerForCalculator];
	}
	return viewController;
}

- (id <A3CalculatorDelegate>)delegateForCalculator {
	_calculatorTargetTextField = _firstResponder;
	return self;
}

- (void)calculatorViewController:(UIViewController *)viewController didDismissWithValue:(NSString *)value {
	_calculatorTargetTextField.text = value;
	[self textFieldDidEndEditing:_calculatorTargetTextField];
}

@end
