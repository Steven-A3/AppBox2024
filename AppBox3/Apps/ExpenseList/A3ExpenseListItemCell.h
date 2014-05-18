//
//  A3ExpenseListItemCell.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A3ExpenseListItemCell;
@protocol A3ExpenseListItemCellDelegate <NSObject>
@required
-(void)itemCellTextFieldBeginEditing:(A3ExpenseListItemCell *)aCell textField:(UITextField *)textField;
-(void)itemCellTextFieldChanged:(A3ExpenseListItemCell *)aCell textField:(UITextField *)textField;
-(void)itemCellTextFieldFinished:(A3ExpenseListItemCell *)aCell textField:(UITextField *)textField;
-(void)itemCellTextFieldDonePressed:(A3ExpenseListItemCell *)aCell;
-(BOOL)upwardRowAvailableFor:(A3ExpenseListItemCell *)sender;
-(BOOL)downwardRowAvailableFor:(A3ExpenseListItemCell *)sender;
-(void)moveUpRowFor:(A3ExpenseListItemCell *)sender textField:(UITextField *)textField;
-(void)moveDownRowFor:(A3ExpenseListItemCell *)sender textField:(UITextField *)textField;
-(void)removeItemForCell:(A3ExpenseListItemCell *)sender responder:(UIResponder *)keyInputDelegate;
@end

@interface A3ExpenseListItemCell : UITableViewCell
@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UITextField *priceTextField;
@property (nonatomic, strong) UITextField *qtyTextField;
@property (nonatomic, strong) UILabel *subTotalLabel;
@property (nonatomic, assign) id<A3ExpenseListItemCellDelegate> delegate;

- (NSString *)defaultCurrencyCode;
@end
