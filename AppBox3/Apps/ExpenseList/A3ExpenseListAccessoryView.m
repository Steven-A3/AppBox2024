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

@interface A3ExpenseListAccessoryView() <UITextFieldDelegate>

@property (nonatomic, strong) UIToolbar *toolBar;
@property (nonatomic, strong) UIBarButtonItem * undoButton;
@property (nonatomic, strong) UIBarButtonItem * redoButton;
//@property (nonatomic, strong) UIBarButtonItem * leftButton;
//@property (nonatomic, strong) UIBarButtonItem * rightButton;
@property (nonatomic, strong) UIBarButtonItem * clearButton;

@property (nonatomic, strong) UIBarButtonItem * paddingItem1;
@property (nonatomic, strong) UIBarButtonItem * paddingItem2;
@property (nonatomic, strong) UIBarButtonItem * paddingItem3;
@property (nonatomic, strong) UIBarButtonItem * paddingItem4;

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
        [self getFirstResponder];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self adjustConstraintLaout];
    [super layoutSubviews];
}

-(void)initializeSubviews
{
    _toolBar = [[UIToolbar alloc] initWithFrame:self.frame];
    
//    [SFKImage setDefaultFont:[UIFont fontWithName:@"appbox" size:36.0]];
//    [SFKImage setDefaultColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
    
//    _undoButton = [[UIBarButtonItem alloc] initWithImage:[SFKImage imageNamed:@"l"]
//                                                   style:UIBarButtonItemStylePlain
//                                                  target:self
//                                                  action:@selector(undoButtonTouchUp:)];
//    _redoButton = [[UIBarButtonItem alloc] initWithImage:[SFKImage imageNamed:@"m"]
//                                                   style:UIBarButtonItemStylePlain
//                                                  target:self
//                                                  action:@selector(redoButtonTouchUp:)];
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
    
//    _leftButton = [[UIBarButtonItem alloc] initWithImage:[[SFKImage imageNamed:@"g"] rotateInDegrees:90]
//                                                   style:UIBarButtonItemStylePlain
//                                                  target:self
//                                                  action:@selector(leftButtonTouchUp:)];
//    _rightButton = [[UIBarButtonItem alloc] initWithImage:[[SFKImage imageNamed:@"g"] rotateInDegrees:270]
//                                                    style:UIBarButtonItemStylePlain
//                                                   target:self
//                                                   action:@selector(rightButtonTouchUp:)];
//    _clearButton = [[UIBarButtonItem alloc] initWithImage:[SFKImage imageNamed:@"p"]
//                                                    style:UIBarButtonItemStylePlain
//                                                   target:self
//                                                   action:@selector(eraseButtonTouchUp:)];
    
    
    /* UIToolBar Items 의 기본 origin x 값, 최초/마지막 아이템 16, 중간 10 의 기본 사이즈 */
    _paddingItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                  target:self
                                                                  action:nil];
    _paddingItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                  target:self
                                                                  action:nil];
    _paddingItem3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                  target:self
                                                                  action:nil];
    _paddingItem4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                  target:self
                                                                  action:nil];
//    _paddingItem1.width = -13.0;
//    _paddingItem2.width = -10.0;
    _paddingItem1.width = -9.0; // 기본 사이즈 : 0.0 => 16
    _paddingItem2.width = 0.0;  // 기본 사이즈 : 0.0 => 10
    _paddingItem4.width = -9.0; // 기본 사이즈 : 0.0 => 16
    
    [_toolBar setItems:@[_paddingItem1, _undoButton,
                         _paddingItem2, _redoButton,
                         //_paddingItem3, _leftButton, _paddingItem2, _rightButton,
                         _paddingItem3,
                        _clearButton, _paddingItem4]];
    [self addSubview:_toolBar];
    
//    if (IS_IPHONE) {
//
//        _toolBar = [[UIToolbar alloc] initWithFrame:self.frame];
//
//        [SFKImage setDefaultFont:[UIFont fontWithName:@"appbox" size:36.0]];
//        [SFKImage setDefaultColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
//        
//        _undoButton = [[UIBarButtonItem alloc] initWithImage:[SFKImage imageNamed:@"l"]
//                                                       style:UIBarButtonItemStylePlain
//                                                      target:self
//                                                      action:@selector(undoButtonTouchUp:)];
//        _redoButton = [[UIBarButtonItem alloc] initWithImage:[SFKImage imageNamed:@"m"]
//                                                       style:UIBarButtonItemStylePlain
//                                                      target:self
//                                                      action:@selector(redoButtonTouchUp:)];
//        _leftButton = [[UIBarButtonItem alloc] initWithImage:[[SFKImage imageNamed:@"g"] rotateInDegrees:90]
//                                                       style:UIBarButtonItemStylePlain
//                                                      target:self
//                                                      action:@selector(leftButtonTouchUp:)];
//        _rightButton = [[UIBarButtonItem alloc] initWithImage:[[SFKImage imageNamed:@"g"] rotateInDegrees:270]
//                                                        style:UIBarButtonItemStylePlain
//                                                       target:self
//                                                       action:@selector(rightButtonTouchUp:)];
//        _eraseButton = [[UIBarButtonItem alloc] initWithImage:[SFKImage imageNamed:@"p"]
//                                                        style:UIBarButtonItemStylePlain
//                                                       target:self
//                                                       action:@selector(eraseButtonTouchUp:)];
//        
//        /* UIToolBar Items 의 기본 origin x 값, 최초 아이템 16, 이후 10 */
//        UIBarButtonItem * paddingItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
//                                                                                       target:self
//                                                                                       action:nil];
//        UIBarButtonItem * paddingItem2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
//                                                                                       target:self
//                                                                                       action:nil];
//        UIBarButtonItem * paddingItem3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
//                                                                                       target:self
//                                                                                       action:nil];
//        UIBarButtonItem * paddingItem4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
//                                                                                       target:self
//                                                                                       action:nil];
//        paddingItem1.width = -13.0;
//        paddingItem2.width = -10.0;
//        paddingItem3.width = 34.0;
//        
//        [_toolBar setItems:@[paddingItem1, _undoButton, paddingItem2, _redoButton, paddingItem3, _leftButton, paddingItem2, _rightButton, paddingItem4, _eraseButton]];
//        [self addSubview:_toolBar];
//        
//    } else {
//        [SFKImage setDefaultFont:[UIFont fontWithName:@"appbox" size:26.0]];
//        [SFKImage setDefaultColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
//        UIImage *erase = [SFKImage imageNamed:@"p"];
//        
//        _undoRedoSegmentButton = [[UISegmentedControl alloc] initWithItems:@[@"  Undo  ", @"  Redo  "]];
//        _leftRightSegmentButton = [[UISegmentedControl alloc] initWithItems :@[@" Previous ", @"Next"]];
//        _eraserSegmentButton = [[UISegmentedControl alloc] initWithItems:@[erase]];
//        
//
//        [self addSubview:_undoRedoSegmentButton];
//        [self addSubview:_leftRightSegmentButton];
//        [self addSubview:_eraserSegmentButton];
//    }

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

-(void)adjustConstraintLaout
{
    if (IS_IPHONE) {
//        _undoRedoSegmentButton.center = CGPointMake(51.0, self.center.y);
//        _leftRightSegmentButton.center = CGPointMake(157.0, self.center.y);
//        _eraserSegmentButton.center = CGPointMake(235.0, self.center.y);
//        _doneButton.center = CGPointMake(292.0, self.center.y);
    } else {
//        _undoRedoSegmentButton.center = CGPointMake(84.0, self.center.y);
//        _leftRightSegmentButton.center = CGPointMake(235.0, self.center.y);
//        _eraserSegmentButton.center = CGPointMake(343.0, self.center.y);
    }
}

-(void)getFirstResponder {
    if ([_delegate respondsToSelector:@selector(textFieldBeManaged)]) {
        _firstResponder = [_delegate textFieldBeManaged];
        _firstResponder.delegate = self;
    }
}

#pragma mark - Properties
-(UIBarButtonItem *)clearButton {
    if (!_clearButton) {
        _clearButton = [[UIBarButtonItem alloc] initWithImage:[SFKImage imageNamed:@"p"]
                                                        style:UIBarButtonItemStylePlain
                                                       target:self
                                                       action:@selector(clearButtonTouchUp:)];
    }
    
    return _clearButton;
}

#pragma mark - Actions

-(void)undoButtonTouchUp:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardAccessoryUndoButtonTouchUp:)]) {
        [_delegate keyboardAccessoryUndoButtonTouchUp:sender];
    }
    
    [self getFirstResponder];
}

-(void)redoButtonTouchUp:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardAccessoryRedoButtonTouchUp:)]) {
        [_delegate keyboardAccessoryRedoButtonTouchUp:sender];
    }
    
    [self getFirstResponder];
}

-(void)leftButtonTouchUp:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardAccessoryLeftButtonTouchUp:)]) {
        [_delegate keyboardAccessoryLeftButtonTouchUp:sender];
    }
    
    [self getFirstResponder];
}

-(void)rightButtonTouchUp:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardAccessoryRightButtonTouchUp:)]) {
        [_delegate keyboardAccessoryRightButtonTouchUp:sender];
    }
    
    [self getFirstResponder];
}

-(void)clearButtonTouchUp:(id)sender {
    if ([_delegate respondsToSelector:@selector(keyboardAccessoryEraseButtonTouchUp:)]) {
        [_delegate keyboardAccessoryEraseButtonTouchUp:sender];
    }
    
    [self getFirstResponder];
}

#pragma mark -

-(void)undoRedoButtonStateChangeFor:(UITextField *)textField {
    [_undoButton setEnabled:[[textField undoManager] canUndo]];
    [_redoButton setEnabled:[[textField undoManager] canRedo]];
}

//-(void)enableLeftButton:(BOOL)avail {
//    [_leftButton setEnabled:avail];
//}
//
//-(void)enableRightButton:(BOOL)avail {
//    [_rightButton setEnabled:avail];
//}

-(void)showEraseButton:(BOOL)show {
    if (show) {
        //_eraseButton.width = 44.0;
//        [_toolBar setItems:@[_paddingItem1, _undoButton,
//                             _paddingItem2, _redoButton,
//                             //_paddingItem3, _leftButton, _paddingItem2, _rightButton,
//                             _paddingItem3, _clearButton, _paddingItem4]];
        _clearButton.enabled = YES;
    } else {
        //_eraseButton.width = 0.0;
//        [_toolBar setItems:@[_paddingItem1, _undoButton,
//                             _paddingItem2, _redoButton
//                             //_paddingItem3, _leftButton, _paddingItem2, _rightButton, _paddingItem3
//                             ]];
        _clearButton.enabled = NO;
    }
}

#pragma mark - UITextField Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [_undoButton setEnabled:[[textField undoManager] canUndo]];
    [_redoButton setEnabled:[[textField undoManager] canRedo]];
    return YES;
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [_undoButton setEnabled:[[textField undoManager] canUndo]];
    [_redoButton setEnabled:[[textField undoManager] canRedo]];

    return YES;
}
@end
