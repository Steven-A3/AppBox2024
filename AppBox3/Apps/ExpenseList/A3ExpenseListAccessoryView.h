//
//  A3ExpenseListAccessoryView.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3ExpenseListAccessoryDelegate <NSObject>
@optional
- (void)keyboardAccessoryUndoButtonTouchUp:(id)sender;
- (void)keyboardAccessoryRedoButtonTouchUp:(id)sender;
- (void)keyboardAccessoryPrevButtonTouchUp:(id)sender;
- (void)keyboardAccessoryNextButtonTouchUp:(id)sender;
- (void)keyboardAccessoryEraseButtonTouchUp:(id)sender;

@end

@interface A3ExpenseListAccessoryView : UIView

@property (nonatomic, weak) id<A3ExpenseListAccessoryDelegate> delegate;

@property (nonatomic, strong) UIBarButtonItem *prevButton;

@property (nonatomic, strong) UIBarButtonItem *nextButton;

- (void)undoRedoButtonStateChangeFor:(UITextField *)textField;
- (void)showEraseButton:(BOOL)show;

@end
