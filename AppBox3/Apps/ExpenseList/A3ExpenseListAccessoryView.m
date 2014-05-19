//
//  A3ExpenseListAccessoryView.m
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import "A3ExpenseListAccessoryView.h"
#import "SFKImage.h"
#import "UIImage+Rotating.h"
#import "A3AppDelegate+appearance.h"

@interface A3ExpenseListAccessoryView() <UITextFieldDelegate>

@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, strong) UIBarButtonItem * undoButton;
@property (nonatomic, strong) UIBarButtonItem * redoButton;
@property (nonatomic, strong) UIBarButtonItem * clearButton;

@end

@implementation A3ExpenseListAccessoryView
{
    UITextField * _firstResponder;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
        [self initializeSubviews];
        [self setupConstraintLayout];
    }
    return self;
}

- (void)initializeSubviews
{
    _toolBar = [[UIToolbar alloc] initWithFrame:self.frame];
    _undoButton = [[UIBarButtonItem alloc] initWithTitle:@"Undo"
                                                   style:UIBarButtonItemStylePlain
                                                  target:self
                                                  action:@selector(undoButtonTouchUp:)];
    _redoButton = [[UIBarButtonItem alloc] initWithTitle:@"Redo"
                                                   style:UIBarButtonItemStylePlain
                                                  target:self
                                                  action:@selector(redoButtonTouchUp:)];
    _clearButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear"
                                                    style:UIBarButtonItemStylePlain
                                                   target:self
                                                   action:@selector(clearButtonTouchUp:)];

	_prevButton = [[UIBarButtonItem alloc] initWithTitle:@"Prev" style:UIBarButtonItemStylePlain target:self action:@selector(prevButtonTouchUp:)];
	_nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStylePlain target:self action:@selector(nextButtonAction:)];
    
    _undoButton.tintColor = [A3AppDelegate instance].themeColor;
    _redoButton.tintColor = [A3AppDelegate instance].themeColor;
    _clearButton.tintColor = [A3AppDelegate instance].themeColor;
    _prevButton.tintColor = [A3AppDelegate instance].themeColor;
    _nextButton.tintColor = [A3AppDelegate instance].themeColor;

    [_toolBar setItems:@[
			self.fixedSpace, _undoButton,
			self.fixedSpace, _redoButton,
			self.fixedSpace, _prevButton,
			self.fixedSpace, _nextButton,
			self.flexibleSpace, _clearButton,
			self.fixedSpace]];
    [self addSubview:_toolBar];
}

- (UIBarButtonItem *)fixedSpace {
	UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
												  target:self
												  action:nil];
	return space;
}

- (UIBarButtonItem *)flexibleSpace {
	return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
												  target:self
												  action:nil];
}

-(void)setupConstraintLayout
{
    [_toolBar makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.left);
        make.trailing.equalTo(self.right);
        make.top.equalTo(self.top);
        make.bottom.equalTo(self.bottom);
    }];
}

#pragma mark - Actions

-(void)undoButtonTouchUp:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardAccessoryUndoButtonTouchUp:)]) {
        [_delegate keyboardAccessoryUndoButtonTouchUp:sender];
    }
}

-(void)redoButtonTouchUp:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardAccessoryRedoButtonTouchUp:)]) {
        [_delegate keyboardAccessoryRedoButtonTouchUp:sender];
    }
}

- (void)prevButtonTouchUp:(UIBarButtonItem *)barButtonItem {
	if ([_delegate respondsToSelector:@selector(keyboardAccessoryPrevButtonTouchUp:)]) {
		[_delegate keyboardAccessoryPrevButtonTouchUp:barButtonItem];
	}
}

- (void)nextButtonAction:(UIBarButtonItem *)barButtonItem {
	if ([_delegate respondsToSelector:@selector(keyboardAccessoryNextButtonTouchUp:)]) {
		[_delegate keyboardAccessoryNextButtonTouchUp:barButtonItem];
	}
}

-(void)clearButtonTouchUp:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardAccessoryEraseButtonTouchUp:)]) {
        [_delegate keyboardAccessoryEraseButtonTouchUp:sender];
    }
}

#pragma mark -

-(void)undoRedoButtonStateChangeFor:(UITextField *)textField {
    [_undoButton setEnabled:[[textField undoManager] canUndo]];
    [_redoButton setEnabled:[[textField undoManager] canRedo]];
}

-(void)showEraseButton:(BOOL)show {
	[_clearButton setEnabled:show];
}

#pragma mark - UITextField Delegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	FNLOG();
    [_undoButton setEnabled:[[textField undoManager] canUndo]];
    [_redoButton setEnabled:[[textField undoManager] canRedo]];
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	FNLOG();
    [_undoButton setEnabled:[[textField undoManager] canUndo]];
    [_redoButton setEnabled:[[textField undoManager] canRedo]];

    return YES;
}

@end
