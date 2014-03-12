//
//  A3ExpenseListAccessoryView.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol A3ExpenseListAccessoryDelegate <NSObject>
//@required
@optional
-(void)keyboardAccessoryUndoButtonTouchUp:(id)sender;
-(void)keyboardAccessoryRedoButtonTouchUp:(id)sender;
-(void)keyboardAccessoryLeftButtonTouchUp:(id)sender;
-(void)keyboardAccessoryRightButtonTouchUp:(id)sender;
-(void)keyboardAccessoryEraseButtonTouchUp:(id)sender;
-(UITextField *)textFieldBeManaged;
//-(BOOL)enableLeftButton;
//-(BOOL)enableRightButton;

@end

@interface A3ExpenseListAccessoryView : UIView

@property (nonatomic, assign) id<A3ExpenseListAccessoryDelegate> delegate;

-(void)undoRedoButtonStateChangeFor:(UITextField *)textField;
-(void)showEraseButton:(BOOL)show;

@end
