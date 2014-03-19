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
#import "A3ExpenseListDefines.h"

@interface A3ExpenseListItemCell() <UITextFieldDelegate, A3KeyboardDelegate, A3ExpenseListAccessoryDelegate>
@property (nonatomic, strong) UIButton *checkButton;
@property (nonatomic, strong) UIView *sep1View;
@property (nonatomic, strong) UIView *sep2View;
@property (nonatomic, strong) UIView *sep3View;
@property (nonatomic, strong) MASConstraint *sep1Const;
@property (nonatomic, strong) MASConstraint *sep2Const;
@property (nonatomic, strong) MASConstraint *sep3Const;
@property (strong) id inputViewController;
@property (nonatomic, strong) A3ExpenseListAccessoryView *keyboardAccessoryView;
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

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self adjustConstraintLaout];
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)initializeSubviews
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

-(void)setupConstraintLayout
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

-(void)adjustConstraintLaout
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

#pragma mark - View Event

//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    UITouch * touche = [event.allTouches anyObject];
//    CGPoint point = [touche locationInView:self];
//
//    if (point.x < _sep1View.frame.origin.x) {
//        [_nameTextField becomeFirstResponder];
//    } else if ( point.x > _sep1View.frame.origin.x && point.x < _sep2View.frame.origin.x) {
//        [_priceTextField becomeFirstResponder];
//    } else if ( point.x > _sep2View.frame.origin.x && point.x < _sep3View.frame.origin.x) {
//        [_qtyTextField becomeFirstResponder];
//    }
//}

#pragma mark - Actions

-(void)checkButtonTouchUp:(id)sender
{
    _checkButton.selected = !_checkButton.selected;
    [_checkButton setImage:[UIImage imageNamed: _checkButton.selected? @"check_02" : nil] forState:UIControlStateNormal];
}

-(void)doneButtonTouchUp:(id)sender
{
    [_firstResponder resignFirstResponder];
    
    if ([_delegate respondsToSelector:@selector(itemCellTextFieldDonePressed:)]) {
        [_delegate itemCellTextFieldDonePressed:self];
    }
}

#pragma mark - TextField
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    // KeyboardAccessoryView 상태 변경.
    [self changeDirectionButtonStateFor:textField];
    [self showEraseButtonIfNeeded];
    
    if ([_delegate respondsToSelector:@selector(itemCellTextFieldBeginEditing:textField:)]) {
        [_delegate itemCellTextFieldBeginEditing:self textField:textField];
    }
    
    textField.returnKeyType = UIReturnKeyNext;

    if (textField.text.length != 0 && _nameTextField != textField) {
        textField.placeholder = textField.text;
        textField.text = @"";
    }
    else {
        if (textField == _priceTextField) {
            NSNumberFormatter *formatter = [NSNumberFormatter new];
            [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            textField.placeholder = [formatter stringFromNumber:@0];
        }
        else if (textField == _qtyTextField) {
            textField.placeholder = @"0";
        }
    }

    if (textField == _nameTextField) {
        textField.inputAccessoryView = [self keyboardAccessoryView];
        [self.keyboardAccessoryView undoRedoButtonStateChangeFor:textField];
        
    }
    else if (textField == _priceTextField) {
        A3NumberKeyboardViewController *keyboardViewController;
        if (IS_IPHONE) {
            keyboardViewController = [[A3NumberKeyboardViewController_iPhone alloc] initWithNibName:@"A3NumberKeyboardViewController_iPhone" bundle:nil];
        } else {
            keyboardViewController = [[A3NumberKeyboardViewController_iPad alloc] initWithNibName:@"A3NumberKeyboardViewController_iPad" bundle:nil];
        }
        
        keyboardViewController.textInputTarget = textField;
        keyboardViewController.delegate = self;
        textField.inputView = keyboardViewController.view;
        keyboardViewController.keyboardType = A3NumberKeyboardTypeCurrency;
        keyboardViewController.bigButton1.selected = YES;

        UIImage *image = [UIImage imageNamed:@"calculator.png"];
        [keyboardViewController.bigButton2 setImage:image forState:UIControlStateNormal];
        [keyboardViewController.bigButton2 setTitle:@"" forState:UIControlStateNormal];
        
        _inputViewController = keyboardViewController;
        
    }
    else if (textField == _qtyTextField) {
        A3NumberKeyboardViewController *keyboardViewController;
        if (IS_IPHONE) {
            keyboardViewController = [[A3NumberKeyboardViewController_iPhone alloc] initWithNibName:@"A3NumberKeyboardViewController_iPhone" bundle:nil];
        } else {
            keyboardViewController = [[A3NumberKeyboardViewController_iPad alloc] initWithNibName:@"A3NumberKeyboardViewController_iPad" bundle:nil];
        }
        
        keyboardViewController.textInputTarget = textField;
        keyboardViewController.delegate = self;
        textField.inputView = keyboardViewController.view;
        keyboardViewController.keyboardType = A3NumberKeyboardTypeCurrency;
        keyboardViewController.bigButton1.selected = NO;
        
        //UIImage *image = [UIImage imageNamed:@"calculator.png"];
        [keyboardViewController.bigButton1 setImage:nil forState:UIControlStateNormal];
        [keyboardViewController.bigButton2 setImage:nil forState:UIControlStateNormal];
        [keyboardViewController.bigButton1 setTitle:@"" forState:UIControlStateNormal];
        [keyboardViewController.bigButton2 setTitle:@"" forState:UIControlStateNormal];
        
        [keyboardViewController reloadPrevNextButtons];
        
        _inputViewController = keyboardViewController;
    }

    _firstResponder = textField;
    
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self.keyboardAccessoryView undoRedoButtonStateChangeFor:textField];
    [self changeDirectionButtonStateFor:textField];
    [self showEraseButtonIfNeeded];
    
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField==_qtyTextField && textField.text.length==0) {
        textField.text = textField.placeholder;
    }
    
    if ([_delegate respondsToSelector:@selector(itemCellTextFieldFinished:textField:)]) {
        [_delegate itemCellTextFieldFinished:self textField:textField];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //[self doneButtonTouchUp:textField];
    [self keyboardAccessoryRightButtonTouchUp:textField];
    return YES;
}

#pragma mark - TextField Related
-(A3ExpenseListAccessoryView *)keyboardAccessoryView {
    if (!_keyboardAccessoryView) {
        _keyboardAccessoryView = [[A3ExpenseListAccessoryView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, 45.0)];
    }
    
    _keyboardAccessoryView.delegate = self;
    
    return _keyboardAccessoryView;
}

- (void)showEraseButtonIfNeeded
{
    if (self.nameTextField.text.length==0) {
        [self.keyboardAccessoryView showEraseButton:NO];
    } else {
        [self.keyboardAccessoryView showEraseButton:YES];
    }
}

- (void)changeDirectionButtonStateFor:(UITextField *)textField
{
    _prevColumnAvail = YES;
    
    if (textField == _qtyTextField) {
        if ([_delegate respondsToSelector:@selector(downwardRowAvailableFor:)]) {
            _nextColumnAvail = [_delegate downwardRowAvailableFor:self];
            [_inputViewController reloadPrevNextButtons];
        }
    } else {
        _nextColumnAvail = YES;
    }
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

- (void)A3KeyboardController:(id)controller clearButtonPressedTo:(UIResponder *)keyInputDelegate {
    if ([_delegate respondsToSelector:@selector(removeItemForCell:responder:)]) {
        [_delegate removeItemForCell:self responder:keyInputDelegate];
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

-(NSString *)stringForPrevButton:(NSString *)current {
    return @"Prev";
}

- (NSString *)stringForNextButton:(NSString *)current {
    return @"Next";
}

- (void)prevButtonPressed{
    [self keyboardAccessoryLeftButtonTouchUp:nil];
}

- (void)nextButtonPressed {
    [self keyboardAccessoryRightButtonTouchUp:nil];
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
-(UITextField *)textFieldShallBeManaged {
    return _firstResponder;
}

-(void)keyboardAccessoryUndoButtonTouchUp:(id)sender {
    if ([[_firstResponder undoManager] canUndo]) {
        [[_firstResponder undoManager] undo];
    }
}

-(void)keyboardAccessoryRedoButtonTouchUp:(id)sender {
    if ([[_firstResponder undoManager] canRedo]) {
        [[_firstResponder undoManager] redo];
    }
}

-(void)keyboardAccessoryLeftButtonTouchUp:(id)sender {
    if (_firstResponder == _qtyTextField) {
        [_priceTextField becomeFirstResponder];
    } else if (_firstResponder == _priceTextField) {
        [_nameTextField becomeFirstResponder];
    } else if (_firstResponder == _nameTextField) {
        [self moveUpRow];
    }
}

-(void)keyboardAccessoryRightButtonTouchUp:(id)sender {
    if (_firstResponder == _nameTextField) {
        [_priceTextField becomeFirstResponder];
    } else if (_firstResponder == _priceTextField) {
        [_qtyTextField becomeFirstResponder];
    } else if (_firstResponder == _qtyTextField) {
        [self moveDownRow];
    }
}

-(void)keyboardAccessoryEraseButtonTouchUp:(id)sender {
    [[self.nameTextField.undoManager prepareWithInvocationTarget:self] undoClear:self.nameTextField.text];
    self.nameTextField.text = @"";
    [self.keyboardAccessoryView undoRedoButtonStateChangeFor:self.nameTextField];
    [self showEraseButtonIfNeeded];
}

-(void)undoClear:(NSString *)textToRestore
{
    self.nameTextField.text = textToRestore;
}

@end
