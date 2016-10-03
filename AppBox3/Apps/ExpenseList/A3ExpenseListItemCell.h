//
//  A3ExpenseListItemCell.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3ExpenseListAccessoryView.h"
#import "A3NumberKeyboardViewController.h"

@class A3ExpenseListItemCell;

@protocol A3ExpenseListItemCellDelegate <NSObject>

@required
- (BOOL)cell:(A3ExpenseListItemCell *)cell textFieldShouldBeginEditing:(UITextField *)textField;
- (void)cell:(A3ExpenseListItemCell *)cell textFieldDidBeginEditing:(UITextField *)textField;
- (void)cell:(A3ExpenseListItemCell *)cell textFieldValueDidChange:(UITextField *)textField;
- (BOOL)cell:(A3ExpenseListItemCell *)cell textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
- (void)cell:(A3ExpenseListItemCell *)cell textFieldDidEndEditing:(UITextField *)textField;
- (void)cell:(A3ExpenseListItemCell *)aCell textFieldDidPressDoneButton:(UITextField *)textField;

- (BOOL)upwardRowAvailableFor:(A3ExpenseListItemCell *)sender;
- (BOOL)downwardRowAvailableFor:(A3ExpenseListItemCell *)sender;
- (void)moveUpRowFor:(NSIndexPath *)indexPath textField:(UITextField *)textField;
- (void)moveDownRowFor:(NSIndexPath *)indexPath textField:(UITextField *)textField;
- (void)removeItemForCell:(A3ExpenseListItemCell *)sender responder:(UIResponder *)keyInputDelegate;

@end

@interface A3ExpenseListItemCell : UITableViewCell

@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) UITextField *priceField;
@property (nonatomic, strong) UITextField *quantityField;
@property (nonatomic, strong) UILabel *subTotalLabel;
@property (nonatomic, weak) id<A3ExpenseListItemCellDelegate> delegate;

@end
