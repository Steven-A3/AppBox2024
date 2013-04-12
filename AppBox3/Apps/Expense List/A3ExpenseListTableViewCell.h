//
//  A3ExpenseListTableViewCell.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/6/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, A3ExpenseListTextFields) {
	A3ExpenseListTextFieldItem = 1,
	A3ExpenseListTextFieldPrice,
	A3ExpenseListTextFieldQuantity
};

@class SSCheckBoxView;

@interface A3ExpenseListTableViewCell : UITableViewCell

@property (nonatomic, strong) SSCheckBoxView *checkBox;
@property (nonatomic, strong) UILabel *subtotal;
@property (nonatomic, strong) UITextField *item, *price, *qty;

@end
