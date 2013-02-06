//
//  A3ExpenseListTableViewCell.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 2/6/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSCheckBoxView;

@interface A3ExpenseListTableViewCell : UITableViewCell

@property (nonatomic, strong) SSCheckBoxView *checkBox;
@property (nonatomic, strong) UILabel *item, *price, *qty, *subtotal;

@end
