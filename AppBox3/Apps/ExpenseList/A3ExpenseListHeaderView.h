//
//  A3ExpenseListHeaderView.h
//  A3TeamWork
//
//  Created by jeonghwan kim on 13. 11. 21..
//  Copyright (c) 2013년 ALLABOUTAPPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ExpenseListBudget;
@interface A3ExpenseListHeaderView : UIView

@property (nonatomic, strong) UIButton *detailInfoButton;

@property (nonatomic, weak) NSNumberFormatter *currencyFormatter;

//-(void)setResult:(ExpenseListBudget *)budget;
-(void)setResult:(ExpenseListBudget *)budget withAnimation:(BOOL)animation;
@end
