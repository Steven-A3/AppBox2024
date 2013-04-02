//
//  A3LoanCalcComparisonTableViewDataSource.h
//  AppBox3
//
//  Created by Byeong Kwon Kwak on 3/28/13.
//  Copyright (c) 2013 ALLABOUTAPPS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoanCalcHistory+calculation.h"

@interface A3LoanCalcComparisonTableViewDataSource : NSObject <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic)		BOOL	leftAlignment;
@property (nonatomic)		LoanCalcHistory *object;
@property (nonatomic, weak)	UIScrollView *mainScrollView;
@property (nonatomic, weak)	A3LoanCalcComparisonTableViewDataSource *brother;

- (void)switchSimpleAdvancedForTableView:(UITableView *)tableView buttonAtIndexPath:(NSIndexPath *)indexPath;
- (void)registerKeyboardNotification;
- (void)removeObservers;
- (void)reloadMainScrollViewContentSize;

@end
